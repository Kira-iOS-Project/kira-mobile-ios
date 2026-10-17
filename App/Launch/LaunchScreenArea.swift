/** Which area's launcher builds each `-KiraScreen` screen. */
#if DEBUG
    extension LaunchScreen {
        /** The area whose launcher builds the screen. */
        enum Area {
            case onboarding, home, account, plans, record, chat, community, care, careTools, debtEmergency, marketplace
            case debtDetail
            case planRisk
            case houseGoal, weddingGoal, educationGoal
            case goals
            case retirementGoal
            case plan, planHome
            case scoreHistory
            case payoff
            case payoffPlan
            case planModule
            case wallets, budget
            case walletAdd
            case bills
            case billForm
            case weeklySummary
            case budgetEdit
        }

        var area: Area {
            switch self {
            case .splash, .intro, .signUp, .signIn, .code, .consent, .focus, .income, .expenses, .debts, .savings,
                .assets, .protection, .result, .pin:
                .onboarding
            case .home, .homeFirstSteps, .homeDebtPlan, .score, .emergencyFund, .savingsRatio, .instalmentRatio,
                .consumerDebt, .consumerDebtManyOnTime, .debtToAsset, .protectionCover:
                .home
            case .profile, .security, .privacy, .about, .terms, .privacyPolicy, .complaints: .account
            case .plans, .plansYearly, .planDetail, .checkout, .subscription, .invoices, .treat, .scholarship,
                .scholarshipApply, .scholarshipPending, .scholarshipAccepted:
                .plans
            case .history, .transaction, .conversation, .statementImport, .importReview: .record
            case .record, .recordDrafts, .recordManual, .recordScan, .recordQuota, .recordVoice, .crisisSignal,
                .checkInChat:
                .chat
            case .community, .communityGroup, .communityRules, .communityOutbound, .communityLinkUnavailable,
                .groupReport, .groupReportOther, .groupReportSent, .groupReportFailed:
                .community
            case .care, .careOffline, .careHelp, .trustedMessage, .trustedMessageNoRecipient: .care
            case .breathing, .negotiationScript, .safetyPlan, .safetyPlanEmpty, .safetyPlanFailing, .safetyPlanForm:
                .careTools
            case .debtEmergency, .harshCollection, .illegalLender, .unresolvedComplaint, .payoffOffer: .debtEmergency
            case .payoff, .payoffHow, .payoffAvalanche: .payoff
            case .educationGoal, .educationGoalResult, .educationGoalStage: .educationGoal
            case .bills, .billsEmpty, .billsFailed: .bills
            case .budgetEdit, .budgetEditFailing: .budgetEdit
            case .marketplace, .marketplaceEmpty, .marketplaceFailed, .product, .productConsultation, .productEbook,
                .productEvent, .productGone, .submitProduct:
                .marketplace
            case .riskQuiz, .riskQuizUnreadablePlan, .riskDrawdown, .riskHorizon, .riskExperience, .riskDeposit,
                .riskSaveFailing, .riskResult, .riskResultConservative, .riskResultAggressive, .legalityCheck:
                .planRisk
            case .houseGoal, .houseGoalResult, .houseGoalBudgetFailing: .houseGoal
            case .weddingGoal, .weddingGoalResult: .weddingGoal
            case .goalVehicle, .goalGoods, .goalOther, .goalEmergency: .goals
            case .goalRetirement, .goalRetirementResult: .retirementGoal
            case .portfolio, .portfolioMasked, .portfolioEmpty, .portfolioFailed, .addAsset, .addAssetFailing,
                .editAsset:
                .plan
            case .plan, .planNoGoals, .planFailed, .goalDetail, .goalGone, .goalDepositFailing: .planHome
            case .scoreHistory, .scoreHistoryShort, .scoreHistoryEmpty, .scoreHistoryFailed, .scoreHistoryLocked:
                .scoreHistory
            case .myPlan, .myPlanEmpty, .myPlanFailing, .payoffCelebration, .payoffCelebrationLast: .payoffPlan
            case .moduleMoneyMarketFund, .moduleGovernmentBonds, .moduleDeposits, .moduleGold, .moduleStocks,
                .moduleCrypto:
                .planModule
            case .debtDetail, .debtDetailGone, .creditReportGuide: .debtDetail
            case .wallets: .wallets
            case .budget, .budgetFailed: .budget
            case .walletAdd, .walletAddFailing: .walletAdd
            case .billAdd, .billAddSaved, .billAddFailing, .billEdit: .billForm
            case .weeklySummary, .weeklySummaryEmpty, .weeklySummaryFailed: .weeklySummary
            }
        }
    }
#endif
