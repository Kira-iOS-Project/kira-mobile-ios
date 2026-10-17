import APIClient
import Domain
import Foundation
import Observation

/**
 Naskah Pengajuan Keringanan (PED-09, 09b, 09c): the lender picked from the person's debts fills the
 instalment; the person types what they can pay; the reason and the contract number are the
 script's two coloured phrases, each edited in a small sheet. Salin Naskah copies the script and
 shows "Naskah Disalin". The contract number stays in this model only: it is never sent or kept.
 */
@MainActor
@Observable
package final class NegotiationScriptModel {
    /** The coloured phrase being edited. */
    package enum Editing: Hashable, Sendable {
        /** The short reason. */
        case reason
        /** The contract number. */
        case contract
    }

    /** The lenders once loaded; empty when the person has no debt recorded. */
    package private(set) var phase: ScreenPhase<[CareDebt]> = .loading
    /** The script's values. */
    package private(set) var script: NegotiationScript
    /** The lender the script is written to. */
    package private(set) var lender: CareDebt?
    /** Whether the lender list (09b) is open. */
    package var isPickingLender = false
    /** The phrase whose sheet is open. */
    package var editing: Editing?
    /** What the open sheet's field holds. */
    package var draft = ""

    private let service: any CareToolsService
    private let copier: @MainActor (NegotiationScript.Fill) -> Void

    /**
     A script that starts with `defaultReason` ("penghasilan berkurang"); `copier` writes the template
     with the clipboard's values (the whole contract number) and puts it on the clipboard.
     */
    package init(
        service: any CareToolsService, defaultReason: String,
        copier: @escaping @MainActor (NegotiationScript.Fill) -> Void
    ) {
        self.service = service
        self.copier = copier
        script = NegotiationScript(name: "", reason: defaultReason)
    }

    /** Cicilan Sekarang, as the field shows it ("230.000"). */
    package var instalmentText: String {
        get { AmountInput.text(for: script.currentInstalment) }
        set { script.currentInstalment = AmountInput.value(of: newValue) }
    }

    /** Kemampuan Bayar per Bulan, as the field shows it. */
    package var affordableText: String {
        get { AmountInput.text(for: script.affordable) }
        set { script.affordable = AmountInput.value(of: newValue) }
    }

    /** Loads the name and the debts; the first debt is picked. A name that fails to load stays a gap. */
    package func load() async {
        async let name = try? service.displayName()
        do {
            let debts = try await service.debts()
            script.name = await name ?? script.name
            phase = debts.isEmpty ? .empty : .loaded(debts)
            if lender == nil, let first = debts.first { select(first) }
        } catch {
            phase = .failed(careProblem(error))
        }
    }

    /** The script's values as the screen shows them, the contract number masked. */
    package var shown: NegotiationScript.Fill {
        script.fill(for: .screen)
    }

    /** Picks `debt` and fills its instalment (09b). */
    package func select(_ debt: CareDebt) {
        lender = debt
        script.currentInstalment = debt.monthlyInstalment
        isPickingLender = false
    }

    /** Opens the sheet of a coloured phrase on its current value. */
    package func edit(_ phrase: Editing) {
        draft = phrase == .reason ? script.reason : script.contractNumber
        editing = phrase
    }

    /** Keeps the sheet's value and closes it; a blank reason keeps the previous one. */
    package func finishEditing() {
        switch editing {
        case .reason:
            if !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { script.reason = draft }
        case .contract:
            script.contractNumber = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        case nil:
            break
        }
        editing = nil
    }

    /**
     Copies the script with the whole contract number (the copier says how the copy went); false,
     copying nothing, while an amount or the reason is missing, so the screen can say what to fill.
     */
    @discardableResult
    package func copy() -> Bool {
        guard script.isComplete else { return false }
        copier(script.fill(for: .clipboard))
        return true
    }
}
