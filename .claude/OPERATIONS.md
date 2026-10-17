# Operations — Hooks, GitHub and CI, Reviews, MCP, Deploys, Access

> **Listed in the CLAUDE.md "On-demand references" table; never `@`-import it.** An import loads
> the whole file into every session.
>
> Each entry names a trap and how to avoid it. Read the section that matches the task before
> acting, and add to it through `/agent-core:learn-session`: one entry per learning, with its
> reason.

## Claude Code hooks

**The contract.** The tool call arrives as JSON on **stdin**. Exit **2** blocks a PreToolUse call,
and its stderr is the reason Claude reads; every other exit code lets the call through, `1`
included. PostToolUse stdout is only logged: findings reach Claude as
`hookSpecificOutput.additionalContext`. Claude Code never sets `CLAUDE_TOOL_INPUT_*` environment
variables, so a hook that reads them does nothing and exits 0 every time.

**Hooks on one event run in parallel**, and start in the session's current directory:

- Reference every hook as `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/<name>.sh"` with a `timeout`,
  so a `cd` earlier in the session cannot break it. Installed as the agent-config-kit plugins, the
  hooks live in the plugins, which wire them as `bash "${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh"`;
  this repo's `.claude/settings.json` then wires none of them (`/agent-core:sync --check` fails on
  a hook wired twice).
- Two PostToolUse hooks on the same file race. Format and lint run in one script (`post-edit.sh`),
  in that order.
- SessionStart and UserPromptSubmit hooks end in `|| true`: a failure there must never erase a
  prompt.

| Script               | Event                             | Job                                                                                                |
| -------------------- | --------------------------------- | -------------------------------------------------------------------------------------------------- |
| `lib.sh`             | —                                 | shared helpers and the shell-command analyzer (quoting, heredocs, `$( )`, `bash -c`)               |
| `session-start.sh`   | SessionStart                      | makes zsh behave like bash on unmatched globs, `=word` and word splitting                          |
| `prompt-intent.sh`   | UserPromptSubmit                  | points `/debug` at `/agent-core:rca`; prunes idle sessions' hook state                             |
| `safety-check.sh`    | PreToolUse (Bash)                 | destructive commands, protected-branch pushes, skipped hooks, `.env*` reads and writes, the unlock |
| `mcp-guard.sh`       | PreToolUse (GitHub MCP writes)    | GitHub MCP writes straight onto a protected branch                                                 |
| `db-guard.sh`        | PreToolUse (production SQL tool)  | SQL that may write, until the user runs `unlock db` (`docs/unlock.md`)                             |
| `generated-guard.sh` | PreToolUse (Write, Edit, Serena)  | hand edits to generated output (frontends and docs sites)                                          |
| `migration-guard.sh` | PreToolUse (Write, Edit, Serena)  | hand edits to generated migrations (backends and pipelines that own a schema)                      |
| `post-commit.sh`     | PostToolUse (Bash)                | shows what a commit carried; warns on paths its pathspec did not name                              |
| `post-edit.sh`       | PostToolUse (Write, Edit, Serena) | format, then lint, in one script so they cannot race                                               |

A hook whose tool or folder the repo does not have switches itself off, so one copy serves every
stack. Per-repo settings live in `.claude/agent-config.json` (see
`.claude/agent-config.example.json`), every key optional; a key the file sets replaces its default
whole:

| Key                        | Default                                        | Read by                                  |
| -------------------------- | ---------------------------------------------- | ---------------------------------------- |
| `protectedBranches`        | `dev`, `prod`, `main`, `master`                | `safety-check.sh`, `mcp-guard.sh`        |
| `protectedPaths`           | source, test, script and agent-config folders  | `safety-check.sh` (destructive commands) |
| `generatedPaths`           | a generated API client and an OpenAPI contract | `generated-guard.sh`                     |
| `migrationsDirs`           | the usual drizzle and Alembic folders          | `migration-guard.sh`                     |
| `appendOnlyMigrationsDirs` | none                                           | `migration-guard.sh`: merged files fixed |
| `commandWrappers`          | none                                           | `safety-check.sh`: wrappers peeled off   |
| `localePairs`              | none                                           | `post-edit.sh`: files that change as one |

`commandWrappers` names commands that run another command (a secrets loader, an output filter), so
the analyzer judges the command they wrap. Multi-repo workspaces stay off unless
`AGENT_WORKSPACE_ROOT` names the folder that holds the repos.

**How the guards fail.** They fail closed: a payload that is not a JSON object, a `python3` that
crashes or runs past its cap, or SQL `db-guard` cannot read refuses the call; only a machine with no
`python3` falls back to plain-text rules for the most dangerous cases (`.env*` names, the unlock,
the guard files themselves). Each guard keeps one deadline for its whole run, inside Claude Code's
hook timeout (which would let the call through), and says so when it runs out of time. The command
analyzer reaches `python3` through a file descriptor, never as an argument, because Linux caps one
argument's size. Every `git` a hook starts disables `core.fsmonitor`, a linked worktree is guarded
like its main checkout, and a symlink is judged both as named and as the file it points to.

**A guard the agent could rewrite would guard nothing.** The shell may read, run and copy out the
guard scripts, the probes, the unlock script and `scripts/env/`, and only read the settings files;
every write route the analyzer can read (redirects, `tee`, `cp`/`mv`, `sed -i`, inline `python -c`,
`git checkout -- <file>`, …) is refused. A change goes through the Edit tool, where the user sees
the diff, or the user runs it with `!`.

**No hook reads permission from the prompt.** What is costly to undo stays refused whoever asks: a
push to a protected branch (the user runs it with `!`), deleting one,
`gh pr merge --delete-branch`, skipped hooks (`--no-verify`, `HUSKY=0`, `core.hooksPath`),
`alembic downgrade` in a repo that has `alembic.ini`, shell writes to `.env` files, and destructive
commands. When to commit is the working agreements' call, not a hook's.

**Prove every rule both ways.** `scripts/check/hook-probes.sh` and `scripts/check/hook-probes.tsv`
hold what each hook must stop and what it must let through; pre-commit runs them when a hook
changes, and CI runs them on every pull request. A new rule adds a probe of each kind. Beyond the
probes, verify a hook by its effect: run `claude -p` in a disposable copy whose git remote is
removed.

## GitHub organization

The code repositories live in `Kira-iOS-Project`, on GitHub's **free** plan, beside `.github`
(public: the organization's profile README and logo) and `.github-private` (the profile README
members see). The avatar is `kira-ikon-1024.png` from the Kira design system. As set on 2026-10-16:

- **Visibility**: `kira-backend` and `kira-mobile-ios` are **public**, because the code is a
  submission. The default branch is `prod`, which strip-ai keeps free of the agent configuration;
  `dev` and its history stay visible, by the owner's decision. No license file: all rights reserved.
- **Pull requests still target `dev`**: `/agent-core:create-pr` passes `--base dev`; by hand, pass
  it too. `scripts/ops/pr-ready.sh` judges heads against the default branch unless told the flow:
  run it with `PR_READY_FLOW="prod=dev"`.
- **Members**: base permission *read*; only owners create repositories. Turn on *Require two-factor
  authentication* (Settings → Authentication security); the API cannot.
- **Actions**, at the organization and on each repository: only GitHub's own actions and
  `adhibuchori/*`, `oven-sh/setup-bun`, `astral-sh/setup-uv`, `zizmorcore/zizmor-action` and
  `google-github-actions/auth` run; the `GITHUB_TOKEN` is read-only unless a job asks for more;
  Actions never approves a pull request; a fork's pull request runs workflows only after an owner
  approves it (every external contributor); logs and artifacts are kept 30 days. A new third-party
  action is refused until its pattern is added in both places.
- **Repositories**: merge commits only (no squash, no rebase), no wiki, projects or issues (tickets
  live in Linear).
- **Protection**: secret scanning with push protection; Dependabot alerts, with security updates off
  (they would open pull requests against the default branch, `prod`); CodeQL and dependency review
  on every pull request. The ruleset *dev and prod* forbids deleting or force-pushing either branch.
  It has no PR-only or required-check rule: a repository ruleset cannot exempt GitHub Actions, and
  strip-ai pushes to `prod` and back-merges into `dev`. So the kit's hooks (Claude never pushes to
  them) and working through pull requests still hold both branches.
- **Minutes**: GitHub's standard runners, macOS included, are free for public repositories. Larger
  runners (`-xlarge`) are paid on every plan: never use one.

## GitHub and CI

- Never write GitHub's skip-CI marker anywhere in a commit message, PR title or PR body, not even to
  describe it. It matches anywhere in the text, and in a promotion PR title it silences the
  production deploy. No command writes it: the workflows run only on pull request events, so a push
  has no run to skip.
- Merge with `--merge`, and turn squash merging off in the repository settings. A merge commit keeps
  every commit and its own date; squash re-dates the work to the merge day, and leaves the merged
  branch "ahead" of `dev`, so `/agent-core:branch-cleanup`'s merged check can never pass for it.
- Branches follow the branch model in CLAUDE.md § Branching: `internal/{scope}` → `dev` → `prod`.
  The head of a promotion PR is `dev` itself: never `gh pr merge --delete-branch`. Delete an
  `internal/*` head by name after the merge, once `headRefName` has been printed, unless the user
  keeps it as a long-lived scope branch.
- Know what a promotion PR runs. If the gate is skipped or reduced for `dev` → `prod`, the real
  signal is the gate on the last PR into `dev`, or the full gate run locally on merged `dev`.
- A long-lived `internal/<scope>` branch falls behind `dev` after each promotion. When it is zero
  commits ahead, fast-forward it: `git push origin origin/dev:refs/heads/internal/<scope>`, then
  confirm `git rev-list --count origin/internal/<scope>..origin/dev` prints 0.
- Workflows run on pull request events only (`pull_request`, a merged PR's `closed`,
  `workflow_call`; a docs site's optional changelog also takes the documented app's
  `repository_dispatch`). No `push` trigger and no scheduled
  (cron) workflow: nothing runs or opens a pull request on its own. Update dependencies by hand
  (`pinact run -u` for actions, the package manager for packages); dependency review checks them on
  the pull request.
- Read check results unfiltered: `gh pr checks <n>` (`rtk proxy gh pr checks <n>` where RTK is
  installed), never through an output wrapper whose summary shifts between calls.
  `bash scripts/ops/pr-ready.sh <n>` reads a PR's checks, mergeability,
  unresolved threads and head branch in one call, and exits 0 only when it can be merged. A skipped
  or neutral check is not a pass: it blocks until the user confirms it is expected, and then
  `--allow-skipped` accepts it.
- A review bot that fetches the diff media type is refused past GitHub's diff size limit (HTTP 406),
  and may trigger only on some PR events. Record its absence on the PR; never read it as a pass.
- A gitleaks negative test needs a genuinely random value: documented examples are allowlisted
  upstream, and low-entropy strings fail the entropy check.
- Every job sets `timeout-minutes`. Runner pools and their variables are in
  `.claude/CI-RUNNERS.md`.

## Reviews

- `/security-review` diffs the whole branch against its base. On a long-lived branch, scope review
  subagents to `git diff $(git merge-base HEAD <base>)...HEAD -- <source dirs>` and exclude the
  agent-config folders (`.agent/`, `.agents/`, `.claude/`).
- Tell a review subagent which gates are already green, so it spends its budget on judgement.
- Rank findings by whether they assert something checkable, and run the cheapest check first.
- Re-read the approved plan against the diff; an unimplemented item never announces itself.
- A handler duplicated across two components usually hides a second defect. Look for it before
  fixing the first.
- Report "consistent but wrong" idioms as observations with a reason, not as drive-by diffs.
- Decline a bot's finding with evidence, after verifying the one sub-point that could be right.

## MCP servers

**Pin every server.** `.mcp.json` pins each `npx`/`uvx` package to an exact version (`@x.y.z`,
`@vX`, `==x.y.z`); `scripts/check/ai-config.sh` fails on an unpinned one. Hosted HTTP servers carry
no version: the endpoint is the provider's. Upgrade deliberately: change the pin, restart the
session, and confirm the handshake with `claude mcp list`.

| Server              | Pin                                                                     | Note                                              |
| ------------------- | ----------------------------------------------------------------------- | ------------------------------------------------- |
| `serena`            | the v1.7.0 commit, `serena@949a27ef…` (a tag can move; a commit cannot) | symbol-level search and edits                     |
| `github`            | hosted HTTP                                                             | `GITHUB_PERSONAL_ACCESS_TOKEN_KIRA` in the shell  |
| `context7`          | `@upstash/context7-mcp@4.1.1`                                           | current library docs                              |
| `linear`            | hosted HTTP, `https://mcp.linear.app/mcp`                               | OAuth: run `/mcp` once in a session to sign in    |

**Rarely used servers load on demand.** Every configured server adds its tool list to each
session. A server you reach for once a month lives in `.claude/mcp/<name>.json` instead, loaded for
one session with `claude --mcp-config .claude/mcp/<name>.json`. Three examples ship:
`deploy-platform.example.json`, `vps-provider.example.json` and `cloudflare.example.json` (a hosted
server; it reads `CLOUDFLARE_API_TOKEN` from your shell). Copy one to `<name>.json`, fill the
placeholders, and pin the package to the exact version you verified. The pin check skips the
`*.example.json` templates and reads every copy, so a copy still carrying `<pinned-version>` fails
until it names a real version.

- The example env names (`DEPLOY_PLATFORM_URL`, `DEPLOY_PLATFORM_API_KEY`,
  `VPS_PROVIDER_API_TOKEN`) stand for whatever names your package reads: rename the keys to its
  own, and keep the `${VARIABLE}` values pointing at your shell.
- A package that ships several servers (hosting, DNS, domains) is one entry per server you need,
  each `npx --package=<package>@<version> <server-command>` at the same pin. Load only those.
- If the deploy platform's server can redact environment values in its output, turn that on: a
  tool result is part of the transcript.
- Disable the server's tool groups your plan cannot use. They fail when called, and they cost tokens
  in every session that loads the server.
- Secrets are `${VARIABLE}` references resolved from your shell, never literals. Claude Code expands
  them; a `curl` copied from the file sends the literal text and gets a 401.

**Permissions for MCP tools live in `.claude/settings.json`, never in `.mcp.json`**, which has no
permission field Claude Code reads (`alwaysAllow` there is ignored). `mcp__db-prod__execute_sql` is
an `ask` rule here too, though this app configures no database server.

## Releases

There is no server to deploy: a release is an Ad Hoc build for the testers. A pull request merged
into `prod` runs `.github/workflows/firebase-distribution.yml`, which archives the `Release`
configuration on the `xcode-27` runner, signs it with the Apple Distribution certificate and the
Ad Hoc profile (repository secrets), and uploads the IPA to Firebase App Distribution for the groups
in `FIREBASE_TESTER_GROUPS`. Inputs, Apple and Firebase steps, and renewals:
`docs/firebase-app-distribution.md`.

- **Verify a release by the Firebase console** (App Distribution → Releases, newest first, with the
  build number = the workflow's run number), never by a green run alone.
- **Only the Release configuration signs**, and only in CI: the `Kira` target's Release settings
  name `$(KIRA_PROVISIONING_PROFILE)`, which only the workflow sets. Local builds use Debug on the
  simulator, unsigned (`bash scripts/ios/app.sh`).
- **The backend is a separate repository** (`kira-backend`): its deploys, database and server
  access are in its own `.claude/OPERATIONS.md`.

## Skill scanning

`scripts/check/skills.sh` runs SkillSpector, pinned by the script, over skills, commands
(`_workflow-source/`), subagents and hooks.

| Command                                             | When                                                                    |
| --------------------------------------------------- | ----------------------------------------------------------------------- |
| `bash scripts/check/skills.sh --staged`             | pre-commit, when a skill, command, subagent or hook is staged           |
| `bash scripts/check/skills.sh --changed origin/dev` | the CI gate, only when the PR touches one                               |
| `bash scripts/check/skills.sh`                      | full static scan                                                        |
| `bash scripts/check/skills.sh --llm`                | adding or upgrading a vendored skill; sends the scanned text to a model |

The gate fails on any unsuppressed finding at MEDIUM or above, and on a target it could not read.
Triage every finding as a claim:

1. **Real, in your own content** — fix the source (`_workflow-source/`, then sync).
2. **In a vendored skill, real or not** — never edit it; its lock hash pins it. Decide with the
   user: turn it off, remove it, or accept it under `vendored:` in `.skillspector-baseline.yaml`
   with the reason and the tree hash the gate prints.
3. **A false positive in your own content** — a narrow `rules:` entry (rule id, file, matched text)
   with a `reason`. Never suppress a whole rule id.

A `vendored:` entry stops blocking only while the recorded hash matches, so an upgrade fails the
gate until it is triaged again.

## Unlock

`.env*` files and production writes are locked by default and only the user opens them, for a few
minutes (`bun unlock env`, `bun unlock db`; `npm run unlock …` where there is no bun). While `env`
is open the agent changes one value with `scripts/env/set.sh`, reading the value from stdin so it
never enters the transcript; `scripts/env/show.sh` prints every key with secrets masked, locked or
not. The whole flow, what it does not stop, and the per-package-manager commands: `docs/unlock.md`.

## Secret scan

`bash scripts/check/secrets.sh` runs `gitleaks` over the staged changes on every commit (the gates
list, or `.pre-commit-config.yaml`) with the repo's `.gitleaks.toml`, so a secret is refused before
it is committed, not found after it is pushed. It fails, never skips, when gitleaks is missing; a
release other than the one CI pins still scans, with a warning. CI scans the pushed history again.

