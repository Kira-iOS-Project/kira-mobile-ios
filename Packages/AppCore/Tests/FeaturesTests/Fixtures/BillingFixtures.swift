/** Billing and Beasiswa Kira answers, as the backend sends them, for the live services' tests. */

let plansJSON = #"""
    {"plans":[{"id":"free","monthlyPrice":0,"yearlyPrice":0,"yearlySaving":0,"aiMessages":30,"receipts":10,\#
    "voiceSeconds":0,"voiceAndImport":false},{"id":"plus","monthlyPrice":29000,"yearlyPrice":290000,\#
    "yearlySaving":58000,"aiMessages":300,"receipts":150,"voiceSeconds":10800,"voiceAndImport":true}],\#
    "current":{"plan":"plus","period":"yearly"}}
    """#

/** A subscription paid with `method` (JSON: a quoted value or null). */
func subscriptionJSON(method: String = #""qris""#) -> String {
    #"""
    {"id":"s-1","plan":"plus","period":"monthly","source":"purchase","price":29000,"paymentMethod":\#(method),\#
    "currentPeriodStart":"2026-10-16T05:00:00.000Z","renewsOn":"2026-11-16","reminderOn":"2026-11-13",\#
    "cancelAtPeriodEnd":false,"usage":{"aiMessages":{"used":3,"limit":300},"receipts":{"used":0,"limit":150},\#
    "voiceSeconds":{"used":0,"limit":10800},"resetsOn":"2026-11-16"}}
    """#
}

let invoicesJSON = #"""
    {"items":[{"id":"i-1","plan":"plus","period":"yearly","amount":290000,"paymentMethod":"app_store",\#
    "periodStart":"2026-10-16","createdAt":"2026-10-16T05:00:00.000Z"}]}
    """#

let acceptedApplicationJSON = #"""
    {"id":"a-1","status":"accepted","situations":["income_stopped","medical_costs"],"story":"Baru kena PHK.",\#
    "submittedAt":"2026-10-16T05:00:00.000Z","decideBy":"2026-10-21","decidedAt":"2026-10-17T05:00:00.000Z",\#
    "grantStart":"2026-10-17","grantEnd":"2027-01-16","extensionFrom":"2027-01-02"}
    """#

let pendingApplicationJSON = #"""
    {"id":"a-2","status":"in_review","situations":["chased_by_lender"],"story":null,\#
    "submittedAt":"2026-10-16T05:00:00.000Z","decideBy":"2026-10-21","decidedAt":null,\#
    "grantStart":null,"grantEnd":null,"extensionFrom":null}
    """#

/** `GET /scholarship` with `application` (JSON or null). */
func scholarshipJSON(application: String) -> String {
    #"{"eligible":false,"ineligibleReason":"has_scholarship","quota":{"remaining":1,"total":4},"#
        + #""application":\#(application)}"#
}
