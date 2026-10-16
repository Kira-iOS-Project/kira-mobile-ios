import APIClient
import Domain
import Foundation
import Observation

/**
 Lupa PIN (AKN-02): the person proves the account by the code sent to its email, then sets a new
 PIN. Their data stays: only the PIN is replaced, and the code's check opens a fresh session.
 */
@MainActor @Observable
package final class PinRecoveryModel: Identifiable {
    /** The step of the recovery. */
    package enum Phase: Equatable, Sendable {
        /** Sending the code. */
        case sending
        /** The code is on its way; waiting for it to be typed. */
        case enteringCode
        /** Checking the code. */
        case verifying
        /** The code was right: choosing the new PIN. */
        case choosingPin
        /** The new PIN is set and Kira is open. */
        case finished
    }

    /** The step. */
    package private(set) var phase: Phase = .sending
    /** The code typed so far: only its digits, at most six. */
    package var code = "" {
        didSet { if code != Self.digits(code) { code = Self.digits(code) } }
    }
    /** The new PIN typed so far. */
    package var newPin = "" {
        didSet { if newPin != Self.digits(newPin) { newPin = Self.digits(newPin) } }
    }
    /** The API's problem with the last call, shown under the code. */
    package private(set) var problem: AppProblem?
    /** Why the new PIN was refused, shown under the PIN. */
    package private(set) var pinProblem: PinProblem?
    /** When "Kirim Ulang Kode" becomes available. */
    package private(set) var resendAvailableAt: Date?
    /** Where the code goes. */
    package let email: String

    @ObservationIgnored private let service: any PinRecoveryService
    @ObservationIgnored private let session: SessionStore
    @ObservationIgnored private let lock: AppLockModel
    @ObservationIgnored private let now: @Sendable () -> Date

    /** Recovery for `email`, through `service`, renewing `session` and setting the PIN on `lock`. */
    package init(
        email: String, service: any PinRecoveryService, session: SessionStore, lock: AppLockModel,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.email = email
        self.service = service
        self.session = session
        self.lock = lock
        self.now = now
    }

    /** Sends the code (the first time, and again from "Kirim Ulang Kode"). */
    package func sendCode() async {
        phase = .sending
        problem = nil
        do {
            let wait = try await service.sendCode(to: email)
            resendAvailableAt = now().addingTimeInterval(TimeInterval(wait))
        } catch {
            problem = Self.problem(from: error)
        }
        phase = .enteringCode
    }

    /** Whole seconds until the code may be sent again at `date`, 0 when it may. */
    package func secondsUntilResend(at date: Date) -> Int {
        guard let resendAvailableAt else { return 0 }
        return max(0, Int(resendAvailableAt.timeIntervalSince(date).rounded(.up)))
    }

    /** Verifikasi: checks the six digits; the right code renews the session. */
    package func verifyCode() async {
        guard code.count == PinPolicy.length, phase == .enteringCode else { return }
        phase = .verifying
        problem = nil
        do {
            let tokens = try await service.verify(code: code, email: email)
            try await session.signIn(tokens, email: email)
            phase = .choosingPin
        } catch {
            problem = Self.problem(from: error)
            code = ""
            phase = .enteringCode
        }
    }

    /** Simpan PIN: sets the new PIN, which opens Kira. */
    package func savePin() {
        guard phase == .choosingPin else { return }
        do {
            try lock.setPin(newPin)
            pinProblem = nil
            phase = .finished
        } catch {
            pinProblem = error
            newPin = ""
        }
    }

    private static func digits(_ text: String) -> String {
        DigitCode.digits(in: text, length: PinPolicy.length)
    }

    private static func problem(from error: any Error) -> AppProblem {
        AppProblem(error)
    }
}
