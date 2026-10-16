/**
 Canned bodies of the record (Catat) responses, written from the backend's spec, and a decoder for what the
 client sent. Instants carry milliseconds, as the API writes them.
 */
import Foundation
import Testing

@testable import APIClient

/** 16 October 2026, 12.41 WIB. */
let recordNow = Date(timeIntervalSince1970: 1_792_129_260)
let recordNowJSON = "2026-10-16T05:41:00.000Z"

let usageJSON =
    #"{"aiMessages":{"used":1,"limit":30},"receipts":{"used":0,"limit":10},"#
    + #""voiceSeconds":{"used":0,"limit":0},"resetsOn":"2026-11-01"}"#

let draftJSON =
    #"{"id":"d-1","type":"expense","name":"Iced Latte","amount":25000,"category":"coffee","#
    + #""occurredAt":"\#(recordNowJSON)","spanStart":0,"spanEnd":9}"#

/** A Kira reply with every field a message can carry. */
let replyJSON =
    #"{"id":"m-2","sender":"kira","kind":"drafts","body":null,"createdAt":"\#(recordNowJSON)","#
    + #""replyToId":"m-1","drafts":[\#(draftJSON)],"draftStatus":"committed","parser":"slang_rules","#
    + #""inputMethod":"keyboard","batchId":"b-1","transactionIds":["t-1"],"committedAt":"\#(recordNowJSON)","#
    + #""itemCount":1,"remaining":1840000,"perDay":184000}"#

/** A person's message with only the fields its kind uses. */
let personJSON =
    #"{"id":"m-1","sender":"person","kind":"person_text","body":"iced latte 25rb","#
    + #""createdAt":"\#(recordNowJSON)","replyToId":null,"drafts":null,"draftStatus":null,"parser":null,"#
    + #""inputMethod":null,"batchId":null,"transactionIds":null,"committedAt":null,"itemCount":null,"#
    + #""remaining":null,"perDay":null}"#

let transactionJSON =
    #"{"id":"t-1","type":"expense","amount":18000,"category":"transport","name":"Grab ke Kantor","#
    + #""occurredAt":"\#(recordNowJSON)","note":null,"source":"chat","sourceMessageId":"m-1"}"#

/** Decodes a sent body whose instants are ISO 8601 strings with milliseconds. */
func decodeSent<Body: Decodable>(_ type: Body.Type, from request: RecordedRequest) throws -> Body {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
        let text = try decoder.singleValueContainer().decode(String.self)
        return try Date(text, strategy: .iso8601.year().month().day().time(includingFractionalSeconds: true))
    }
    return try decoder.decode(type, from: request.body ?? Data())
}

/** One failing answer a call must turn into the problem it carries. */
struct FailureCase: Sendable, CustomTestStringConvertible {
    /** The call and the status, for the test's name. */
    let name: String
    let status: Int
    let call: @Sendable (KiraAPI) async throws -> Void

    var testDescription: String { "\(name) answering \(status)" }

    /** The problem the call must throw: the canned one, or the generic one for an undocumented status. */
    func expectedProblem(documented: Bool) -> AppProblem {
        documented ? AppProblem(type: AppProblem.typeBase + "X_CODE", code: "X_CODE", requestId: "r-1") : AppProblem()
    }
}

/** Each declared error status of a call, plus 500, which no Catat route declares. */
func failureCases(
    _ name: String, statuses: [Int], call: @escaping @Sendable (KiraAPI) async throws -> Void
) -> [FailureCase] {
    (statuses + [500]).map { FailureCase(name: name, status: $0, call: call) }
}
