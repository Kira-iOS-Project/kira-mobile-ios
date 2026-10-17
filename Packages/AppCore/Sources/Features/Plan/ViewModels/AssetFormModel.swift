import APIClient
import Domain
import Foundation
import Observation

/**
 Tambah Aset (REN-11), and the same form updating an asset (Portofolio's "Ketuk aset untuk
 memperbarui nilainya"): a class from the grid, Nama, Nilai Sekarang typed in whole rupiah, and
 Tanggal, today by default and never later. Simpan checks the fields first and says what is missing
 under each; a saved asset shows "Aset Tersimpan" (REN-11b). The form is a full screen, so a failed
 save closes nothing: it shows the failure dialog, keeps every field, and Coba Lagi sends again.
 */
@MainActor
@Observable
package final class AssetFormModel {
    /** Loading the asset to update; an added asset is ready at once. */
    package private(set) var phase: ScreenPhase<Void> = .loading
    /** The chosen class; none until a tile is tapped. */
    package private(set) var assetClass: AssetClass?
    /** Nama. */
    package var name = ""
    /** Nilai Sekarang as the field shows it, grouped with dots ("2.400.000"). */
    package var valueText = ""
    /** Tanggal. */
    package var valuedOn: Date
    /** Whether the calendar is open under Tanggal. */
    package var isPickingDay = false
    /** The issues found by the last Simpan; cleared field by field as they are fixed. */
    package private(set) var issues: [AssetCheck.Issue] = []
    /** Whether the save is on its way. */
    package private(set) var isSaving = false
    /** "Aset Tersimpan" is up. */
    package var showsSaved = false
    /** The problem of the failed save its dialog shows; nil when no dialog is up. */
    package var failure: AppProblem?
    /** The form has done its work and closes. */
    package private(set) var isClosed = false

    /** The asset being updated, nil for a new one. */
    package let assetId: String?
    private let service: any PortfolioService
    private let now: @Sendable () -> Date

    /** A new asset when `assetId` is nil, else the update of that asset; `now` is the clock. */
    package init(service: any PortfolioService, assetId: String? = nil, now: @escaping @Sendable () -> Date = Date.init) {
        self.service = service
        self.assetId = assetId
        self.now = now
        self.valuedOn = now()
        if assetId == nil { phase = .loaded(()) }
    }

    /** Whether the form updates an asset. */
    package var isUpdate: Bool { assetId != nil }

    /** The value in whole rupiah; nil while the field is empty. */
    package var value: Int? { AmountInput.value(of: valueText) }

    /** The latest day Tanggal takes: today. */
    package var latestDay: Date { now() }

    /** Fills the form with the asset to update; a missing one fails the screen. */
    package func load() async {
        guard let assetId, phase.value == nil else { return }
        do {
            guard let asset = try await service.portfolio().asset(id: assetId) else {
                phase = .failed(AppProblem(code: Self.assetNotFound))
                return
            }
            assetClass = asset.assetClass
            name = asset.name
            valueText = AmountInput.text(for: asset.value)
            valuedOn = asset.valuedOn.date
            phase = .loaded(())
        } catch {
            phase = .failed(AppProblem(error))
        }
    }

    /** Chooses a tile. */
    package func select(_ assetClass: AssetClass) {
        self.assetClass = assetClass
        issues.removeAll { $0 == .noClass }
    }

    /** The issue shown under a field, if the last Simpan found one there. */
    package func issue(in field: Field) -> AssetCheck.Issue? {
        issues.first { field.issues.contains($0) }
    }

    /** Simpan Aset: checks, then sends; the failure dialog keeps every field. */
    package func save() async {
        guard !isSaving else { return }
        let day = CalendarDay(valuedOn)
        issues = AssetCheck.issues(
            assetClass: assetClass, name: name, value: value, valuedOn: day, today: CalendarDay(now()))
        guard issues.isEmpty, let assetClass, let value else { return }
        isSaving = true
        defer { isSaving = false }
        let input = AssetInput(
            assetClass: assetClass, name: name.trimmingCharacters(in: .whitespacesAndNewlines), value: value,
            valuedOn: day)
        do {
            if let assetId {
                _ = try await service.updateAsset(id: assetId, input)
            } else {
                _ = try await service.addAsset(input)
            }
            showsSaved = true
        } catch {
            failure = AppProblem(error)
        }
    }

    /** Coba Lagi on the failure dialog: sends the same fields again. */
    package func retry() async {
        failure = nil
        await save()
    }

    /** Selesai on "Aset Tersimpan": back to Portofolio. */
    package func finish() {
        showsSaved = false
        isClosed = true
    }

    /** The API's code for an asset that is gone; the screen reads it as a problem it knows once the spec lists it. */
    static let assetNotFound = "ASSET_NOT_FOUND"

    /** The form's fields, for the issue shown under each. */
    package enum Field: Sendable {
        /** Kelas Aset. */
        case assetClass
        /** Nama. */
        case name
        /** Nilai Sekarang. */
        case value
        /** Tanggal. */
        case day

        var issues: [AssetCheck.Issue] {
            switch self {
            case .assetClass: [.noClass]
            case .name: [.noName, .nameTooLong]
            case .value: [.noValue, .valueTooLarge]
            case .day: [.futureDay]
            }
        }
    }
}
