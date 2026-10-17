import Domain
import Foundation
import Observation

/**
 Kira Peduli inside the Catat chat. A message with a crisis signal (PED-02) gets the fixed reply
 instead of being sent or read for transactions; its quick replies open the help sheet (PED-03),
 offer the check-in (PED-05) or go back to the composer. A check-in whose time has come greets the
 person when Catat opens (PED-06).

 Recording a signal never shows anything: a person in crisis never meets an error, and a signal that
 did not arrive waits in memory and is sent again at the next signal, quick reply or opening
 of Catat; an ordinary message never waits for it. A check-in greeting that could not load waits
 for the next opening. Only scheduling the check-in, which the person asked for, says when it
 failed, with Coba Lagi. A check-in already scheduled opens with its delay chosen, and Tidak Perlu
 then cancels it, as quietly as a signal is recorded.
 */
@MainActor
@Observable
package final class CareChatModel {
    /** The route of Mode Darurat Utang (PED-07). */
    static let debtEmergency = AppRoute.debtEmergency

    /** The lines Kira Peduli added to the chat, oldest first. */
    package internal(set) var entries: [CareChatEntry] = []
    /** Whether the help sheet (PED-03) is up. */
    package var isHelpPresented = false
    /** Check-in Lanjutan (PED-05), while it is open. */
    package internal(set) var checkIn: CheckInModel?
    /** Scheduling the check-in failed: the dialog with Coba Lagi and Tutup. */
    package var checkInFailure: CheckInFailure?
    /** Where the chat sends the person outside itself: Mode Darurat Utang. */
    var onOpen: (AppRoute) -> Void = { _ in }
    /** Mau Cerita Dulu: back to the composer. */
    var onFocusComposer: () -> Void = {}
    private let service: any CheckInService
    private let detector: CrisisDetector
    private let clock: any RecordClock
    private let makeId: @Sendable () -> String
    /** The strongest level recorded in this session, per source. */
    private var recorded: [CareSignalSource: CareSignalLevel] = [:]
    /** The check-in is offered once per crisis session. */
    private var hasOfferedCheckIn = false
    /** The check-in scheduled in this session, until it greets or is cancelled. */
    private var scheduled: (id: String, delay: CheckInDelay)?
    private let outbox: CareOutbox

    /** The chat's Kira Peduli on `service`, with `detector` reading the messages. */
    init(
        service: any CheckInService, detector: CrisisDetector, clock: any RecordClock,
        makeId: @escaping @Sendable () -> String
    ) {
        self.service = service
        outbox = CareOutbox(service: service)
        self.detector = detector
        self.clock = clock
        self.makeId = makeId
    }

    /**
     Whether `text` carries a crisis signal. When it does, the message and Kira's fixed reply join
     the chat on this device and the signal's level is recorded; Catat then neither sends the
     message nor reads it for transactions.
     */
    func intercept(_ text: String, allowsModel: Bool) async -> Bool {
        guard let level = await detector.level(of: text, allowsModel: allowsModel) else { return false }
        add(.personText(text))
        add(.crisisReply(isAnswered: false))
        record(level, source: .chat)
        await outbox.send()
        return true
    }

    /** A quick reply under a crisis reply or a check-in greeting. */
    package func choose(_ choice: CareChoice, in entry: CareChatEntry) async {
        /** Mau Bahas Utangnya leaves the chat; the greeting keeps its quick replies for the way back. */
        if choice != .talkAboutDebt {
            answer(entry)
            add(.personChoice(choice))
        }
        switch choice {
        case .safe:
            hasOfferedCheckIn = true
            presentCheckIn(delay: scheduled?.delay ?? .tomorrow)
        case .unsafe:
            isHelpPresented = true
            record(.danger, source: .chat)
        case .talkFirst:
            onFocusComposer()
        case .better:
            add(.checkInBetter)
        case .stillHeavy:
            isHelpPresented = true
            record(.concern, source: .checkIn)
        case .talkAboutDebt:
            openDebtEmergency()
        }
        await outbox.send()
    }

    /** Lihat Bantuan on the crisis reply. */
    package func openHelp() {
        isHelpPresented = true
    }

    /**
     The help sheet closed by Kembali ke Chat, a swipe or the scrim: Kira offers the check-in, once
     per session; Aku Aman offers it every time it is tapped.
     */
    package func helpClosed() {
        guard !hasOfferedCheckIn else { return }
        hasOfferedCheckIn = true
        presentCheckIn(delay: scheduled?.delay ?? .tomorrow)
    }

    /** Buka on the Mode Darurat Utang card, and Mau Bahas Utangnya. */
    package func openDebtEmergency() {
        onOpen(Self.debtEmergency)
    }

    /** Coba Lagi on the failure dialog: the offer again, with the delay the person chose. */
    package func retryCheckIn() {
        guard let failed = checkInFailure else { return }
        checkInFailure = nil
        presentCheckIn(delay: failed.delay)
    }

    /**
     Catat opened: the signals and cancels that did not arrive are sent again, and the check-in
     whose time has come greets `name` once and is marked as shown, unless the person cancelled it.
     */
    func opened(name: String) async {
        await outbox.send()
        guard let due = try? await service.due(), !outbox.cancels(due.id) else { return }
        if scheduled?.id == due.id { scheduled = nil }
        let id = "check-in-\(due.id)"
        if !entries.contains(where: { $0.id == id }) {
            entries.append(
                CareChatEntry(id: id, createdAt: clock.now, kind: .checkInGreeting(name: name, isAnswered: false)))
        }
        /** error ignored: a greeting not marked is marked again at the next opening, and shown once */
        try? await service.markSeen(id: due.id)
    }

    private func presentCheckIn(delay: CheckInDelay) {
        checkIn = CheckInModel(
            service: service, delay: delay,
            onScheduled: { [weak self] checkIn, delay in
                self?.scheduled = (checkIn.id, delay)
                self?.checkIn = nil
            },
            onDecline: { [weak self] in await self?.declined() },
            onFailure: { [weak self] failure in
                self?.checkIn = nil
                self?.checkInFailure = failure
            })
    }

    /** Tidak Perlu, or the close button: a check-in scheduled before is cancelled. */
    private func declined() async {
        checkIn = nil
        guard let pending = scheduled else { return }
        scheduled = nil
        outbox.add(.cancel(checkInId: pending.id))
        await outbox.send()
    }

    private func add(_ kind: CareChatEntry.Kind) {
        entries.append(CareChatEntry(id: makeId(), createdAt: clock.now, kind: kind))
    }

    private func answer(_ entry: CareChatEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        switch entries[index].kind {
        case .crisisReply: entries[index].kind = .crisisReply(isAnswered: true)
        case .checkInGreeting(let name, _): entries[index].kind = .checkInGreeting(name: name, isAnswered: true)
        case .personText, .personChoice, .checkInBetter: break
        }
    }

    /** Queues `level` once per source and session, and again only when it is stronger. */
    private func record(_ level: CareSignalLevel, source: CareSignalSource) {
        if let known = recorded[source], known >= level { return }
        recorded[source] = level
        outbox.add(.signal(level, source))
    }
}
