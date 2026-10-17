/**
 Telling a refused session from an API that did not answer: the first ends the session and goes to
 Masuk, the second keeps it for the next try (AGENTS.md Rule 13).
 */
import HTTPTypes
import OpenAPIRuntime

extension AppProblem {
    /**
     Whether `error` is the API refusing the session: a problem coded `AUTH_REFRESH_INVALID` or
     `AUTH_UNAUTHENTICATED`, or a 401 answered without a problem body (a proxy's page). A lost
     connection or any other status is not.
     */
    package static func isSessionRefusal(_ error: any Error) -> Bool {
        let code = AppProblem(error).knownCode
        if code == .authRefreshInvalid || code == .authUnauthenticated { return true }
        return (error as? ClientError)?.response?.status == .unauthorized
    }
}
