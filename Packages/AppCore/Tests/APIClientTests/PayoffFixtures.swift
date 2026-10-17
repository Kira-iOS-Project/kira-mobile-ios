/** Payoff responses as the backend sends them for Dinda (RencanaPelunasan, PelunasanAktif boards). */

let payoffPlanJSON = #"""
    {"method":"snowball","extraPayment":200000,"maxExtraPayment":1840000,"monthlyBudget":700000,\#
    "hasUnknownRate":true,\#
    "accounts":[\#
    {"id":"00000000-0000-4000-8000-000000000001","kind":"paylater","name":"Paylater A","remaining":420000,\#
    "monthlyInstalment":210000,"annualInterestRate":24,"dueDay":5,"position":1,"months":2,\#
    "payoffMonth":"2026-11","interest":6400},\#
    {"id":"00000000-0000-4000-8000-000000000002","kind":"online_loan","name":"Pinjol B","remaining":890000,\#
    "monthlyInstalment":290000,"position":2,"months":null,"payoffMonth":null,"interest":null}],\#
    "productive":[{"id":"00000000-0000-4000-8000-000000000003","kind":"vehicle","name":"Cicilan Motor",\#
    "remaining":13000000,"monthlyInstalment":850000}],\#
    "totalInterest":null,"allPaidMonths":null,"allPaidMonth":null,\#
    "comparison":{"otherMethod":"avalanche","interestSaved":-1200,"firstPayoffMonthsLater":1}}
    """#

let emptyPayoffPlanJSON = #"""
    {"method":"avalanche","extraPayment":0,"maxExtraPayment":0,"monthlyBudget":0,"hasUnknownRate":false,\#
    "accounts":[],"productive":[],"totalInterest":null,"allPaidMonths":null,"allPaidMonth":null,\#
    "comparison":null}
    """#

let activePlanJSON = #"""
    {"id":"00000000-0000-4000-8000-0000000000aa","method":"snowball","extraPayment":0,\#
    "startedAt":"2026-10-10T03:00:00.000Z",\#
    "accounts":[\#
    {"id":"00000000-0000-4000-8000-000000000001","kind":"paylater","name":"Paylater A","remaining":420000,\#
    "original":600000,"progressPercent":30,"monthlyInstalment":210000,"annualInterestRate":24,"dueDay":5,\#
    "status":"in_progress"},\#
    {"id":"00000000-0000-4000-8000-000000000003","kind":"vehicle","name":"Cicilan Motor","remaining":13000000,\#
    "original":15000000,"progressPercent":13,"monthlyInstalment":850000,"status":"ongoing"}],\#
    "nextPayment":{"debtId":"00000000-0000-4000-8000-000000000001","name":"Paylater A","amount":210000,\#
    "instalment":210000,"extra":0,"dueDate":"2026-11-05","daysLeft":20}}
    """#

let settledPaymentJSON = #"""
    {"debtId":"00000000-0000-4000-8000-000000000001","monthlyInstalment":210000,\#
    "paid":420000,"remaining":0,"progressPercent":100,\#
    "paidOff":true,"nextAccount":{"id":"00000000-0000-4000-8000-000000000002","name":"Pinjol B"},\#
    "scoreEstimate":{"before":66,"after":72,"consumerDebtBefore":50,"consumerDebtAfter":80}}
    """#

let partPaymentJSON = #"""
    {"debtId":"00000000-0000-4000-8000-000000000001","monthlyInstalment":210000,\#
    "paid":210000,"remaining":210000,"progressPercent":65,\#
    "paidOff":false,"nextAccount":null,"scoreEstimate":null}
    """#

let donePlanJSON = #"""
    {"id":"00000000-0000-4000-8000-0000000000aa","method":"snowball","extraPayment":0,\#
    "startedAt":"2026-10-10T03:00:00.000Z","accounts":[],"nextPayment":null}
    """#
