import Foundation

/** What a person allowed Kira to do with their data: the API's `GET /me/consents`. */
package struct ConsentSettings: Equatable, Sendable {
    /** The latest decision per purpose. */
    package let items: [ConsentItem]

    /** The decisions as the API sends them. */
    package init(items: [ConsentItem]) {
        self.items = items
    }

    /** Whether `purpose` is allowed; the core purpose always is. */
    package func isGranted(_ purpose: ConsentPurpose) -> Bool {
        purpose == .core || items.contains { $0.purpose == purpose && $0.granted }
    }
}

/** One decision: its purpose and the answer. */
package struct ConsentItem: Equatable, Sendable {
    /** What the data is used for. */
    package let purpose: ConsentPurpose
    /** Whether the person allowed it. */
    package let granted: Bool

    /** A decision about `purpose`. */
    package init(purpose: ConsentPurpose, granted: Bool) {
        self.purpose = purpose
        self.granted = granted
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
    /** The file's bytes, UTF-8 with an Indonesian header row. */
    package let csv: Data

    /** An export named `fileName`. */
    package init(fileName: String, csv: Data) {
        self.fileName = fileName
        self.csv = csv
    }
}
