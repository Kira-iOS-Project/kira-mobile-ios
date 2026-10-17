import APIClient
import Domain
import Foundation
import Observation

/** What the create screen has returned after a successful save. */
package struct BillCreateSnapshot: Hashable, Sendable {
    /** The created schedule, nil while the form is ready. */
    package let savedBill: RecurringBill?

    /** A ready form or the result returned by the server. */
    package init(savedBill: RecurringBill? = nil) {
        self.savedBill = savedBill
    }
}

/** UNG-07: validates and saves an owner-scoped recurring bill. */
@MainActor
@Observable
package final class BillCreateModel {
    /** The form's account-load, save or result phase. */
    package private(set) var phase: ScreenPhase<BillCreateSnapshot> = .loading
    /** Available debt accounts owned by the signed-in person. */
    package private(set) var debtAccounts: [BillDebtAccount] = []
    /** The schedule name. */
    package var name = "" { didSet { if name != oldValue { clientID = UUID() } } }
    /** The whole-rupiah amount as typed. */
    package var amountText = "" { didSet { if amountText != oldValue { clientID = UUID() } } }
    /** The selected expense category. */
    package var category = TransactionCategory.bills { didSet { if category != oldValue { clientID = UUID() } } }
    /** The repetition interval. */
    package var repeatInterval = BillRepeatInterval.monthly {
        didSet { if repeatInterval != oldValue { clientID = UUID() } }
    }
    /** The first due date in WIB. */
    package var dueDate: CalendarDay { didSet { if dueDate != oldValue { clientID = UUID() } } }
    /** Whether this bill is an installment attached to a debt account. */
    package var isDebtInstallment = false {
        didSet {
            if isDebtInstallment != oldValue {
                clientID = UUID()
                if !isDebtInstallment { linkedDebtAccountID = nil }
            }
        }
    }
    /** The selected owner's debt account, if linked. */
    package var linkedDebtAccountID: String? { didSet { if linkedDebtAccountID != oldValue { clientID = UUID() } } }
    /** Whether validation errors should be visible. */
    package private(set) var showsFieldErrors = false
    /** Whether the server is saving the form. */
    package private(set) var isSaving = false
    /** Whether the debt-account request is still running. */
    package private(set) var isLoadingAccounts = true
    /** The owner's account choices could not be loaded. */
    package private(set) var debtAccountsProblem: AppProblem?
    /** The last bill submission failed and can be retried without changing its idempotency key. */
    package private(set) var saveProblem: AppProblem?

    private let service: any BillsService
    private let today: @Sendable () -> CalendarDay
    private var hasLoadedAccounts = false
    private var clientID = UUID()

    /** Loads debt choices and uses an injectable WIB day for validation. */
    package init(service: any BillsService, today: @escaping @Sendable () -> CalendarDay = { CalendarDay(Date()) }) {
        self.service = service
        self.today = today
        dueDate = today()
    }

    /** Expense categories supported by the bill API. */
    package var categories: [TransactionCategory] {
        TransactionCategory.allCases.filter { $0.type == .expense }
    }

    /** Dates before today in WIB cannot be scheduled. */
    package var minimumDueDate: Date { today().start }

    /** A bill returned by the server after a successful submission, or nil before then. */
    package var savedBill: RecurringBill? { phase.value?.savedBill }

    /** The form can be submitted when its required fields and any selected account are valid. */
    package var canSave: Bool {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !isSaving && !cleanName.isEmpty && cleanName.count <= 80
            && AmountInput.amount(amountText) != nil && dueDate >= today()
            && (!isDebtInstallment || (!isLoadingAccounts && debtAccounts.contains { $0.id == linkedDebtAccountID }))
    }

    /** Loads only debt choices from the owner's wallet service; an unavailable picker does not block bills. */
    package func load() async {
        guard !hasLoadedAccounts else { return }
        isLoadingAccounts = true
        debtAccountsProblem = nil
        phase = .loading
        do {
            debtAccounts = try await service.debtAccounts()
            hasLoadedAccounts = true
            phase = debtAccounts.isEmpty ? .empty : .loaded(BillCreateSnapshot())
        } catch {
            hasLoadedAccounts = true
            let problem = billsProblem(error)
            debtAccountsProblem = problem
            phase = .failed(problem)
        }
        isLoadingAccounts = false
    }

    /** Retries the debt choices after an account-load failure. */
    package func retryDebtAccounts() async {
        hasLoadedAccounts = false
        await load()
    }

    /** Stores a picker value using the app's fixed WIB calendar day. */
    package func selectDueDate(_ value: Date) {
        dueDate = CalendarDay(value)
    }

    /** Submits a validated request, retaining the same idempotency key until the draft changes. */
    package func save() async {
        showsFieldErrors = true
        guard canSave, let amount = AmountInput.amount(amountText) else { return }
        let request = BillCreateRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines), amount: amount, category: category,
            nextDueDate: dueDate, repeatInterval: repeatInterval,
            linkedDebtAccountID: isDebtInstallment ? linkedDebtAccountID : nil, clientID: clientID)
        isSaving = true
        saveProblem = nil
        phase = .loading
        do {
            phase = .loaded(BillCreateSnapshot(savedBill: try await service.createBill(request)))
        } catch {
            let problem = billsProblem(error)
            saveProblem = problem
            phase = .failed(problem)
        }
        isSaving = false
    }

    /** Returns the screen to a clean form after it is opened again. */
    package func resetDraft() {
        name = ""
        amountText = ""
        category = .bills
        repeatInterval = .monthly
        dueDate = today()
        isDebtInstallment = false
        linkedDebtAccountID = nil
        saveProblem = nil
        clientID = UUID()
        showsFieldErrors = false
        isSaving = false
        phase = debtAccounts.isEmpty ? .empty : .loaded(BillCreateSnapshot())
    }
}

extension BillCreateModel {
    /** The visible name error after a save attempt. */
    package var nameError: LocalizedStringResource? {
        guard showsFieldErrors else { return nil }
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "bills.create.name.required" }
        return name.count > 80 ? "bills.create.name.tooLong" : nil
    }

    /** The visible amount error after a save attempt. */
    package var amountError: LocalizedStringResource? {
        showsFieldErrors && AmountInput.amount(amountText) == nil ? "bills.create.amount.required" : nil
    }

    /** The visible due-date error after a save attempt. */
    package var dueDateError: LocalizedStringResource? {
        showsFieldErrors && dueDate < today() ? "bills.create.date.past" : nil
    }

    /** The visible account error when an installment needs an owner's debt account. */
    package var debtAccountError: LocalizedStringResource? {
        guard showsFieldErrors, isDebtInstallment else { return nil }
        return debtAccounts.contains { $0.id == linkedDebtAccountID } ? nil : "bills.create.debt.required"
    }
}
