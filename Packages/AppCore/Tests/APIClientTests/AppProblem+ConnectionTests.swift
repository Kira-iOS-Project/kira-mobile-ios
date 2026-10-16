/** How an error from a call becomes a problem a screen can word: the API's, connection loss, or the generic one. */
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import APIClient

private func wrapped(_ underlying: any Error) -> ClientError {
    ClientError(
        operationID: "getMe", operationInput: (), causeDescription: "transport",
        underlyingError: underlying)
}

@Suite("AppProblem connection loss")
struct AppProblemConnectionTests {
    private let known = AppProblem(
        type: AppProblem.typeBase + "INTERNAL_ERROR", code: "INTERNAL_ERROR", requestId: "r-1")

    @Test("keeps the API's problem, also when the client wrapped a middleware's")
    func keepsTheAPIsProblem() {
        #expect(AppProblem(known) == known)
        #expect(AppProblem(wrapped(known)) == known)
    }

    @Test("reads a transport failure as connection loss, bare or wrapped by the client")
    func readsConnectionLoss() {
        #expect(AppProblem(URLError(.notConnectedToInternet)) == .connectionLost)
        #expect(AppProblem(wrapped(URLError(.timedOut))) == .connectionLost)
    }

    @Test("reads anything else as the generic problem")
    func readsAnythingElseAsGeneric() {
        #expect(AppProblem(CancellationError()) == AppProblem())
        #expect(
            AppProblem(wrapped(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "x"))))
                == AppProblem())
    }

    @Test("words connection loss with its own message and no reference")
    func wordsConnectionLoss() {
        #expect(AppProblem.connectionLost.isConnectionLoss)
        #expect(AppProblem.connectionLost.knownCode == nil)
        #expect(AppProblem.connectionLost.messageKey == "problem.connection")
        #expect(!AppProblem.connectionLost.showsReference)
        #expect(!AppProblem().showsReference)
        #expect(AppProblem().messageKey == "problem.unknown")
        #expect(!known.showsReference)
    }
}
