/** Score responses as the backend sends them for Dinda (KiraScore, DetailIndikator boards). */

let indicatorsJSON = #"""
    [{"key":"emergency_fund","group":"save_group","points":50,"band":"coping",\#
    "measure":{"ratio":1.1,"liquid":4800000,"essential":4200000,"targetMultiple":6,"targetAmount":25200000}},\#
    {"key":"savings_ratio","group":"save_group","points":45,"band":"coping",\#
    "measure":{"percent":8,"monthlySavings":600000,"income":7500000}},\#
    {"key":"instalment_ratio","group":"debt_group","points":70,"band":"coping",\#
    "measure":{"percent":18,"monthlyInstalments":1350000,"income":7500000}},\#
    {"key":"consumer_debt","group":"debt_group","points":50,"band":"coping",\#
    "measure":{"platforms":2,"anyLate":false,"anyOverdue":false}},\#
    {"key":"debt_to_asset","group":"debt_group","points":80,"band":"healthy",\#
    "measure":{"percent":32,"totalDebt":14310000,"totalAssets":44700000}},\#
    {"key":"protection_cover","group":"protect_group","points":100,"band":"healthy",\#
    "measure":{"health":true,"income":true}}]
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
    "targetMultiple":3}],"cappedByConsumerDebt":false}
    """#

let detailJSON = #"""
    {"key":"emergency_fund","group":"save_group","points":50,"band":"coping",\#
    "measure":{"ratio":1.1,"liquid":4800000,"essential":4200000,"targetMultiple":6,"targetAmount":25200000},\#
    "ladder":[{"points":100,"lower":6,"upper":null,"amountLower":25200000,"amountUpper":null,"isCurrent":false},\#
    {"points":50,"lower":1,"upper":3,"amountLower":4200000,"amountUpper":12600000,"isCurrent":true}],\#
    "nextRung":{"points":75,"amountNeeded":7800000,"scoreFrom":66,"scoreTo":70},\#
    "milestones":[{"at":4200000,"label":"1×"},{"at":12600000,"label":"3×"}]}
    """#
