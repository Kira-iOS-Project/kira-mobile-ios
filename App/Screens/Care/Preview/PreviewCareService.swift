/**
 The canvas's contacts behind CareService, so Kira Peduli runs in previews and in the app before
 the API client implements the protocol. By default it lists a sample Layanan Kira Peduli (a
 placeholder number, debug only, never in the shipped list), so previews and audits draw its card,
 the Layanan Kira card in the help sheet and PED-04's buttons. `listsKiraCare = false` shows the shipped
 list as production does until the number exists; `isOffline` answers like a lost connection.
 */
import APIClient
import Domain
import Features

struct PreviewCareService: CareService {
    var isOffline = false
    var listsKiraCare = true

    func contacts() throws -> CareContactList {
        if isOffline { throw AppProblem() }
        guard listsKiraCare else { return .shipped }
        let kiraCare = CareContact(
            key: .kiraCare, name: "Layanan Kira Peduli", phone: "080000000000", whatsApp: "080000000000")
        return CareContactList(
            verifiedOn: CareContactList.shipped.verifiedOn, contacts: [kiraCare] + CareContactList.shipped.contacts)
    }
}
