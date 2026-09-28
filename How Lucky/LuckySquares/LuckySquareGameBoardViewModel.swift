import SwiftUI

class LuckySquareGameBoardViewModel: ObservableObject {
    @Published var luckySquares: [LuckySquare] = []
    private(set) var countBefore5050: Int?

    init() { reset() }

    func use5050() {
        // Reusing 50/50 after Reset Power-Ups must not overwrite the original size.
        if countBefore5050 == nil { countBefore5050 = luckySquares.count }
        replaceSquares(count: 2)
    }

    func restartKeepingScore() {
        countBefore5050 = nil
        replaceSquares(count: 2)
    }

    func advance() {
        // Every successful route (guess, trivia, Free Pass) consumes 50/50.
        if let previousCount = countBefore5050 {
            replaceSquares(count: previousCount)
            countBefore5050 = nil
        }
        luckySquares.forEach { $0.isDisabled = false }
        luckySquares.append(makeSquare(number: luckySquares.count + 1))
    }

    func reset() {
        countBefore5050 = nil
        replaceSquares(count: 2)
    }

    private func replaceSquares(count: Int) {
        luckySquares = (1...max(2, count)).map { makeSquare(number: $0) }
    }

    private func makeSquare(number: Int) -> LuckySquare {
        LuckySquare(id: UUID().uuidString, name: String(number), color: .red, isDisabled: false)
    }
}
