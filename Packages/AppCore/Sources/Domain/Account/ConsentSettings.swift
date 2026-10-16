import Foundation

/** What a person allowed Kira to do with their data: the API's `GET /me/consents`. */
package struct ConsentSettings: Equatable, Sendable {
    /** The privacy policy version the decisions were made under. */
    package let policyVersion: String
    package let items: [ConsentItem]

    package init(policyVersion: String, items: [ConsentItem]) {
        self.policyVersion = policyVersion
        self.items = items
    }

    /** Whether `purpose` is allowed; the core purpose always is. */
    package func isGranted(_ purpose: ConsentPurpose) -> Bool {
        purpose == .core || items.contains { $0.purpose == purpose && $0.granted }
    }
}

/** One decision: its purpose, the answer and when it was given. */
package struct ConsentItem: Equatable, Sendable {
    package let purpose: ConsentPurpose
    package let granted: Bool
    package let decidedAt: Date?

    package init(purpose: ConsentPurpose, granted: Bool, decidedAt: Date? = nil) {
        self.purpose = purpose
        self.granted = granted
        self.decidedAt = decidedAt
    }
}

/** Why data is used: the backend's `CONSENT_PURPOSE` values. */
package enum ConsentPurpose: String, CaseIterable, Codable, Sendable {
    /** Recording and the Kira Score: the service itself, always on. */
    case core
    /** Kira AI reading chats and receipts. */
    case aiProcessing = "ai_processing"
    /** The weekly summary inside the app. */
    case weeklySummary = "weekly_summary"
}

/** The person's records as a CSV file (`GET /me/export`), saved to the device. */
package struct DataExport: Equatable, Sendable {
    /** `kira-data-YYYY-MM-DD.csv`, as the API names it. */
    package let fileName: String
    package let csv: Data

    package init(fileName: String, csv: Data) {
        self.fileName = fileName
        self.csv = csv
    }
}
