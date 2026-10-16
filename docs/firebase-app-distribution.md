# Firebase App Distribution

`.github/workflows/firebase-distribution.yml` sends every merge into `prod` to the testers:

1. **build** (macOS, Xcode 27): imports the Apple Distribution certificate into a throwaway keychain
   with a random password, installs the Ad Hoc profile, archives the `Release` configuration,
   exports `Kira.ipa` and keeps it as a one-day artifact. The build number is the workflow's run
   number. This job sees the Apple secrets only.
2. **distribute** (Linux): signs in to Google Cloud, uploads the IPA through the
   [App Distribution REST API](https://firebase.google.com/docs/reference/app-distribution/rest)
   with `curl`, writes release notes (build number, commit, pull request) and distributes it to
   the tester groups. This job sees the Google credential only. No npm package runs here.

The app embeds no Firebase SDK and needs no `GoogleService-Info.plist`: App Distribution works on
the IPA alone. Add the SDK later only for a feature that needs it (Crashlytics, for example).

## One-Time Setup

### 1. Apple Developer

The bundle identifier is `com.kira.finance` (the `Kira` target, `PRODUCT_BUNDLE_IDENTIFIER`).
Change it in the project before registering anything if you want another one.

1. **Identifiers** → register the App ID `com.kira.finance` (explicit).
2. **Devices** → register every tester's iPhone (UDID). Firebase can collect them: App Distribution
   → Testers & Groups → enable device registration, then export the UDIDs for Apple.
3. **Certificates** → an **Apple Distribution** certificate. Export it from Keychain Access with
   its private key as a `.p12`, protected by a strong password.
4. **Profiles** → an **Ad Hoc** profile for `com.kira.finance` with that certificate and the
   devices. Download the `.mobileprovision`. The workflow reads the team ID and the profile name
   from the file itself, and refuses a profile for another app or one without devices.

### 2. Firebase

1. Firebase console → add a project (or use one), then **Add app → iOS** with the bundle ID
   `com.kira.finance`. Skip the SDK and `GoogleService-Info.plist` steps.
2. Project settings → your iOS app → copy the **App ID** (`1:<project-number>:ios:<hex>`).
3. Release & Monitor → **App Distribution** → Get started. Under **Testers & Groups**, create a
   group (its alias, for example `internal-testers`) and add the testers.
4. Google Cloud console for the same project → enable the **Firebase App Distribution API**
   (`firebaseappdistribution.googleapis.com`).

### 3. Google Credential (Choose One)

**A. Workload Identity Federation (recommended: no long-lived key exists anywhere).** With
`gcloud` (or Cloud Shell), in the Firebase project:

```bash
PROJECT_ID=<firebase-project-id>
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')
REPO=Kira-iOS-Project/kira-mobile-ios

gcloud services enable iamcredentials.googleapis.com --project "$PROJECT_ID"
gcloud iam service-accounts create kira-distributor --project "$PROJECT_ID" \
  --display-name "Kira App Distribution (GitHub Actions)"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member "serviceAccount:kira-distributor@$PROJECT_ID.iam.gserviceaccount.com" \
  --role roles/firebaseappdistro.admin

gcloud iam workload-identity-pools create github --project "$PROJECT_ID" --location global
# Only a pull-request workflow of this repository, targeting prod, can get a token.
gcloud iam workload-identity-pools providers create-oidc kira-mobile-ios --project "$PROJECT_ID" \
  --location global --workload-identity-pool github \
  --issuer-uri https://token.actions.githubusercontent.com \
  --attribute-mapping 'google.subject=assertion.sub,attribute.repository=assertion.repository' \
  --attribute-condition "assertion.repository == '$REPO' && assertion.event_name == 'pull_request' && assertion.base_ref == 'prod'"
gcloud iam service-accounts add-iam-policy-binding \
  "kira-distributor@$PROJECT_ID.iam.gserviceaccount.com" --project "$PROJECT_ID" \
  --role roles/iam.workloadIdentityUser \
  --member "principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github/attribute.repository/$REPO"
```

Then set the two variables in step 4 (`GCP_WORKLOAD_IDENTITY_PROVIDER` is
`projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/github/providers/kira-mobile-ios`).

**B. A service account key (as in Jeda).** Create the same service account with the role
**Firebase App Distribution Admin**, create a JSON key, store it as the
`FIREBASE_SERVICE_ACCOUNT_JSON` secret, and delete the downloaded file. A key never expires on its
own: rotate it, and prefer A when you can.

### 4. GitHub Repository Settings

From the repo folder, with the GitHub CLI (the values are read from files or prompts, never typed
into the shell history):

```bash
base64 -i Distribution.p12 | gh secret set BUILD_CERTIFICATE_BASE64
gh secret set P12_PASSWORD                      # prompts for the .p12 password
base64 -i Kira_Ad_Hoc.mobileprovision | gh secret set BUILD_PROVISION_PROFILE_BASE64

gh variable set FIREBASE_APP_ID --body '1:<project-number>:ios:<hex>'
gh variable set FIREBASE_TESTER_GROUPS --body 'internal-testers'

# Option A
gh variable set GCP_WORKLOAD_IDENTITY_PROVIDER --body 'projects/<number>/locations/global/workloadIdentityPools/github/providers/kira-mobile-ios'
gh variable set GCP_SERVICE_ACCOUNT --body 'kira-distributor@<project-id>.iam.gserviceaccount.com'
# Option B instead
gh secret set FIREBASE_SERVICE_ACCOUNT_JSON < service-account.json
```

| Name | Kind | What it holds |
| --- | --- | --- |
| `BUILD_CERTIFICATE_BASE64` | secret | the Apple Distribution `.p12`, base64 |
| `P12_PASSWORD` | secret | its password |
| `BUILD_PROVISION_PROFILE_BASE64` | secret | the Ad Hoc `.mobileprovision`, base64 |
| `FIREBASE_APP_ID` | variable | `1:<project-number>:ios:<hex>` |
| `FIREBASE_TESTER_GROUPS` | variable | comma-separated group aliases |
| `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` | variables | option A |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | secret | option B |
| `CI_RUNNER_MACOS` | variable, optional | another macOS runner label (default `xcode-27`) |

The workflow checks every input before it uses one and names what is missing.

## Running It

Merge a pull request into `prod`. The run appears under Actions → Firebase App Distribution, and
the testers get an email from Firebase. Until the `FIREBASE_APP_ID` variable is set, both jobs are
skipped: the variable is the switch that turns distribution on. A run that failed (an expired certificate, say) is
re-run from its page once the secret is fixed.

## Keeping It Working

- **A new tester device**: register it at Apple, add it to the Ad Hoc profile, download the
  profile again and update `BUILD_PROVISION_PROFILE_BASE64`.
- **Expiry**: the distribution certificate and the profile expire (a year at most). Renew both and
  update the two secrets; the build job fails with a clear message until then.
- **Environments**: the repository is public, so it can have environments on the free plan. Moving
  the five secrets into one (for example `firebase-distribution`, with `environment:` on both jobs)
  is a follow-up to test first: the workflow runs on a `pull_request` event, whose ref is the pull
  request's merge ref, so a branch rule of `prod` alone may not admit it.
