/** The API's answers for Dinda, as the backend sends them, for the live services' tests. */

let usageJSON = #"""
    {"aiMessages":{"used":3,"limit":30},"receipts":{"used":0,"limit":10},\#
    "voiceSeconds":{"used":0,"limit":0},"resetsOn":"2026-11-01"}
    """#

let periodJSON = #"{"start":"2026-09-25","end":"2026-10-24","nextPayday":"2026-10-25","daysUntilPayday":9}"#

/** `GET /me` with the account's onboarding flags and plan. */
func meJSON(consented: Bool = true, healthCheck: Bool = true, hideBalances: Bool = false, plan: String? = nil)
    -> String
{
    let planJSON = plan ?? #"{"id":"plus","source":"scholarship","renewsOn":"2027-01-16"}"#
    return #"""
        {"id":"u-1","email":"dinda@email.com","displayName":"Dinda","focus":"track_spending",\#
        "payday":{"day":25,"endOfMonth":false},"hideBalances":\#(hideBalances),"consented":\#(consented),\#
        "healthCheckCompleted":\#(healthCheck),"plan":\#(planJSON),"usage":\#(usageJSON),"period":\#(periodJSON),\#
        "lastCategories":{"expense":"coffee","income":null},"debtAccountCount":2,\#
        "aiEnabled":true,"weeklySummaryEnabled":false,"debtEmergencyActive":false}
        """#
}

let consentsJSON = #"""
    {"policyVersion":"2026-10-15","items":[\#
    {"purpose":"core","granted":true,"decidedAt":"2026-10-16T05:00:00.000Z"},\#
    {"purpose":"weekly_summary","granted":false,"decidedAt":null}]}
    """#

let tokensJSON = #""accessToken":"a-1","refreshToken":"r-1","accessExpiresInSeconds":900"#

let indicatorsJSON = #"""
    [{"key":"emergency_fund","group":"save_group","points":50,"band":"coping",\#
    "measure":{"ratio":1.1,"liquid":4800000,"essential":4200000,"targetMultiple":6,"targetAmount":25200000}},\#
    {"key":"savings_ratio","group":"save_group","points":45,"band":"coping",\#
    "measure":{"percent":8,"monthlySavings":600000,"income":7500000}},\#
    {"key":"instalment_ratio","group":"debt_group","points":70,"band":"coping",\#
    "measure":{"percent":18,"monthlyInstalments":1350000,"income":7500000}},\#
    {"key":"consumer_debt","group":"debt_group","points":50,"band":"coping",\#
    "measure":{"platforms":2,"anyLate":true,"anyOverdue":false}},\#
    {"key":"debt_to_asset","group":"debt_group","points":80,"band":"healthy",\#
    "measure":{"percent":32,"totalDebt":14310000,"totalAssets":44700000}},\#
    {"key":"protection_cover","group":"protect_group","points":100,"band":"healthy",\#
    "measure":{"health":true,"income":false}}]
    """#

let stepJSON = #"""
    {"kind":"pay_off_debt","estimatedGain":4,"debtName":"Paylater A","remaining":420000}
    """#

let reportJSON = #"""
    {"score":66,"band":"coping","delta":4,"isInitial":false,"computedAt":"2026-10-16T05:00:00.000Z",\#
    "nextCheckOn":"2026-10-25","groups":[{"group":"save_group","points":48,"band":"coping"},\#
    {"group":"debt_group","points":67,"band":"coping"},{"group":"protect_group","points":100,"band":"healthy"}],\#
    "indicators":\#(indicatorsJSON),"steps":[\#(stepJSON),\#
    {"kind":"build_emergency_fund","estimatedGain":4,"currentAmount":4800000,"targetAmount":12600000,\#
    "targetMultiple":4.5}],"cappedByConsumerDebt":false}
    """#

let detailJSON = #"""
    {"key":"emergency_fund","group":"save_group","points":50,"band":"coping",\#
    "measure":{"ratio":1.1,"liquid":4800000,"essential":4200000,"targetMultiple":6,"targetAmount":25200000},\#
    "ladder":[{"points":100,"lower":6,"upper":null,"amountLower":25200000,"amountUpper":null,"isCurrent":false},\#
    {"points":50,"lower":1,"upper":3,"amountLower":4200000,"amountUpper":12600000,"isCurrent":true}],\#
    "nextRung":{"points":75,"amountNeeded":7800000,"scoreFrom":66,"scoreTo":70},\#
    "milestones":[{"at":4200000,"label":"1×"},{"at":12600000,"label":"3×"}]}
    """#

let overviewJSON = #"""
    {"variant":"overview","today":"2026-10-16","displayName":"Dinda","hideBalances":false,\#
    "period":\#(periodJSON),"money":{"income":7500000,"spent":5660000,"remaining":1840000,"perDay":204444,\#
    "spentPercent":75},"step":\#(stepJSON),"stepPosition":{"index":1,"total":3},\#
    "score":{"score":66,"band":"coping","delta":4,"isInitial":false},\#
    "weeklySummary":{"from":"2026-10-09","to":"2026-10-15"},\#
    "checklist":{"healthCheck":true,"firstTransaction":false,"walletAdded":false,"paydaySet":true},\#
    "debtPlan":{"paidOff":1600000,"total":20000000,"remaining":18400000,"percent":8},\#
    "microTarget":{"kind":"one_week","current":120000,"target":350000}}
    """#

let firstStepsJSON = #"""
    {"variant":"first_steps","today":"2026-10-16","displayName":"Dinda","hideBalances":true,\#
    "period":\#(periodJSON),"money":null,"step":null,"stepPosition":null,"score":null,"weeklySummary":null,\#
    "checklist":null,"debtPlan":null,"microTarget":null}
    """#
