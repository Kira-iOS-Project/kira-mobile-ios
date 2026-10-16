/**
 The canvas's contacts behind CareService, so Kira Peduli runs in previews and in the app before
 the API client implements the protocol. `isOffline` answers like a lost connection, to show the
 shipped list standing in.
 */
import APIClient
import Domain
import Features

struct PreviewCareService: CareService {
    var isOffline = false

    func contacts() throws -> CareContactList {
        if isOffline { throw AppProblem() }
        return .shipped
    }
}
