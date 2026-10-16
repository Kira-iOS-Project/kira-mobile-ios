/** Canned Catat answers, written from the backend's spec. Instants carry milliseconds, as the API sends them. */
import Foundation

/** 16 October 2026, 12.41 WIB. */
let liveNow = Date(timeIntervalSince1970: 1_792_129_260)
private let liveNowJSON = "2026-10-16T05:41:00.000Z"

let liveUsageJSON =
    #"{"aiMessages":{"used":1,"limit":30},"receipts":{"used":0,"limit":10},"#
    + #""voiceSeconds":{"used":0,"limit":0},"resetsOn":"2026-11-01"}"#

/** `GET /me` for Dinda on Kira Gratis, period 25 September – 24 Oktober. */
let liveMeJSON =
    #"{"id":"u-1","email":"dinda@email.com","displayName":"Dinda","focus":"track_spending","#
    + #""payday":{"day":25,"endOfMonth":false},"hideBalances":false,"consented":true,"#
    + #""healthCheckCompleted":true,"plan":{"id":"free","source":null,"renewsOn":null},"#
    + #""usage":\#(liveUsageJSON),"period":{"start":"2026-09-25","end":"2026-10-24","#
    + #""nextPayday":"2026-10-25","daysUntilPayday":9},"lastCategories":{"expense":"food","income":null},"#
    + #""debtAccountCount":0,"aiEnabled":true,"weeklySummaryEnabled":false,"debtEmergencyActive":false}"#

let liveDraftJSON =
    #"{"id":"d-1","type":"expense","name":"Iced Latte","amount":25000,"category":"coffee","#
    + #""occurredAt":"\#(liveNowJSON)","spanStart":0,"spanEnd":9}"#

/** A Kira reply with every field a message can carry. */
let liveReplyJSON =
    #"{"id":"m-2","sender":"kira","kind":"drafts","body":null,"createdAt":"\#(liveNowJSON)","#
    + #""replyToId":"m-1","drafts":[\#(liveDraftJSON)],"draftStatus":"committed","parser":"slang_rules","#
    + #""inputMethod":"keyboard","batchId":"b-1","transactionIds":["t-1"],"committedAt":"\#(liveNowJSON)","#
    + #""itemCount":1,"remaining":1840000,"perDay":184000}"#

/** A person's message with only the fields its kind uses. */
let livePersonJSON =
    #"{"id":"m-1","sender":"person","kind":"person_text","body":"iced latte 25rb","#
    + #""createdAt":"\#(liveNowJSON)","replyToId":null,"drafts":null,"draftStatus":null,"parser":null,"#
    + #""inputMethod":null,"batchId":null,"transactionIds":null,"committedAt":null,"itemCount":null,"#
    + #""remaining":null,"perDay":null}"#

let liveSentJSON =
    #"{"person":\#(livePersonJSON),"reply":\#(liveReplyJSON),"quotaExhausted":false,"usage":\#(liveUsageJSON)}"#

let liveTransactionJSON =
    #"{"id":"t-1","type":"expense","amount":18000,"category":"transport","name":"Grab ke Kantor","#
    + #""occurredAt":"\#(liveNowJSON)","note":"pagi","source":"bank_import","sourceMessageId":null}"#

/** A transaction detail whose source is a receipt: its quote has no text, only a store name in `body`. */
let liveDetailJSON =
    String(liveTransactionJSON.dropLast())
    + #","sourceMessage":{"id":"m-1","body":null,"createdAt":"\#(liveNowJSON)","spanStart":null,"spanEnd":null}}"#
