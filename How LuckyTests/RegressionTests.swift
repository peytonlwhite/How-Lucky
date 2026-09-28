import Foundation
import SwiftData
import SwiftUI
import Testing
@testable import How_Lucky

struct BettingTests {
    @Test func oddsUseDistinctGuessesAndNetWinnings() {
        #expect(abs(CoinBet.odds(choices: 250, guesses: 6) - 40.6666666667) < 0.000001)
        #expect(CoinBet.odds(choices: 2) == 1)
        #expect(CoinBet.odds(choices: 4) == 3)
        #expect(CoinBet.odds(choices: 10, guesses: 5) == 1)
        #expect(CoinBet.odds(choices: 2, guesses: 6) == 0)
        #expect(CoinBet.odds(choices: 0) == 0)
        #expect(CoinBet.odds(choices: 250, guesses: 0) == 0)
    }

    @Test func reservedStakeIsReturnedOnlyOnWinOrCancellation() throws {
        let bet = try #require(CoinBet(stake: 30, balance: 300, odds: 3))
        let available = 300 - bet.stake
        #expect(available == 270)
        #expect(available + bet.payout == 390)
        #expect(available + bet.cancellationRefund == 280)
        #expect(bet.winnings == 90)
    }

    @Test func payoutIsLockedAndRoundedToWholeCoins() throws {
        let bet = try #require(CoinBet(stake: 10, balance: 300, odds: CoinBet.odds(choices: 250, guesses: 6)))
        #expect(bet.winnings == 406)
        #expect(bet.payout == 416)
        #expect(bet.cancellationRefund == 3)
        #expect(bet.odds != CoinBet.odds(choices: 249, guesses: 5))
    }

    @Test func invalidAndOverflowingBetsAreRejected() {
        #expect(CoinBet(stake: 0, balance: 300, odds: 3) == nil)
        #expect(CoinBet(stake: -1, balance: 300, odds: 3) == nil)
        #expect(CoinBet(stake: 301, balance: 300, odds: 3) == nil)
        #expect(CoinBet(stake: 1, balance: 300, odds: .nan) == nil)
        #expect(CoinBet(stake: 1, balance: 300, odds: .infinity) == nil)
        #expect(CoinBet(stake: 1, balance: 300, odds: -1) == nil)
        #expect(CoinBet(stake: 1, balance: Int.max, odds: 1) == nil)
        #expect(CoinBet(stake: Int.max, balance: Int.max, odds: 3) == nil)
    }

    @Test func guaranteedWinReturnsOnlyTheStake() throws {
        let bet = try #require(CoinBet(stake: 10, balance: 300, odds: CoinBet.odds(choices: 1, guesses: 6)))
        #expect(bet.winnings == 0)
        #expect(bet.payout == 10)
    }

    @Test func exactWholeCoinResultsDoNotLoseOneCoinToFloatingPoint() throws {
        let bet = try #require(CoinBet(stake: 100, balance: 300, odds: CoinBet.odds(choices: 28, guesses: 5)))
        #expect(bet.winnings == 460)
        for choices in 1...250 {
            for guesses in 1...min(choices, 8) {
                for stake in [1, 3, 6, 10, 11, 100, 300] {
                    let candidate = try #require(CoinBet(stake: stake, balance: 300, odds: CoinBet.odds(choices: choices, guesses: guesses)))
                    #expect(candidate.winnings == stake * (choices - guesses) / guesses)
                }
            }
        }
    }
}

@MainActor
struct SavedPlayerTests {
    @Test func resetsAndPlayersHaveIndependentDefaults() throws {
        let first = MockData.initUser
        let second = MockData.initUser
        let firstStats = try #require(first.luckySquaresStats)
        firstStats.highScore = 500
        firstStats.powerUpStats[0].totalTimesUsed = 10
        #expect(second.luckySquaresStats?.highScore == 0)
        #expect(second.luckySquaresStats?.powerUpStats[0].totalTimesUsed == 0)
        first.luckySquaresStats = MockData.initLuckySquareStats
        #expect(first.luckySquaresStats?.highScore == 0)
        let powerUps = MockData.squarePowerUps
        powerUps[0].isLocked = true
        #expect(!MockData.squarePowerUps[0].isLocked)
    }

    @Test func repairPreservesExistingRecordsAndFillsOnlyMissingValues() throws {
        let container = try ModelContainer(for: User.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let user = MockData.initUser
        container.mainContext.insert(user)
        user.coins = 1234
        user.luckySquaresStats?.highScore = 900
        user.luckySquaresStats?.powerUpStats.removeAll { $0.id == "12" }
        user.luckyCirclesStats = nil
        user.appLastOpened = nil
        user.repairMissingDefaults()
        user.repairMissingDefaults()
        try container.mainContext.save()
        #expect(user.coins == 1234)
        #expect(user.luckySquaresStats?.highScore == 900)
        #expect(user.luckySquaresStats?.powerUpStats.filter { $0.id == "12" }.count == 1)
        #expect(user.luckyCirclesStats != nil)
        #expect(user.appLastOpened != nil)
    }
}

private final class TriviaStubProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        let url = request.url!
        let query = url.query ?? ""
        let status = query.contains("difficulty=hard") ? 503 : 200
        let body: String
        if query.contains("difficulty=medium") {
            body = #"{"response_code":5,"results":[]}"#
        } else {
            body = #"{"response_code":0,"results":[{"category":"Test","type":"boolean","difficulty":"easy","question":"Test question","correct_answer":"True","incorrect_answers":["False"]}]}"#
        }
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

@MainActor
struct TriviaTests {
    private func makeManager() -> TriviaManager {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [TriviaStubProtocol.self]
        return TriviaManager(session: URLSession(configuration: config))
    }

    @Test func unavailableServerProducesRecoverableError() async {
        let manager = makeManager()
        await manager.fetchTrivia(gameType: "hard")
        #expect(manager.errorMessage != nil)
        #expect(!manager.isLoading)
        #expect(manager.answerChoices.isEmpty)
    }

    @Test func emptyAPIResponseDoesNotLeaveBlankTrivia() async {
        let manager = makeManager()
        await manager.fetchTrivia(gameType: "med")
        #expect(manager.errorMessage != nil)
        #expect(!manager.isLoading)
        await manager.fetchTrivia(gameType: "easy")
        #expect(manager.errorMessage == nil)
        #expect(manager.answerChoices.count == 2)
    }

    @Test func answerCanOnlyCountOnceAndResetClearsChoices() async throws {
        let manager = makeManager()
        await manager.fetchTrivia(gameType: "tof")
        let answer = try #require(manager.answerChoices.first(where: { $0.isCorrect }))
        manager.selectAnswer(answer: answer)
        #expect(!manager.selectAnswer(answer: answer))
        #expect(manager.score == 1)
        manager.goToNextQuestion()
        #expect(manager.reachedEnd)
        manager.resetManager()
        #expect(manager.answerChoices.isEmpty)
        #expect(manager.score == 0)
        #expect(!manager.reachedEnd)
    }
}

@MainActor
struct SecondSweepTests {
    @Test func dailyRewardHonorsExactBoundaryAndCannotBeClaimedTwice() {
        let user = MockData.initUser
        let last = Date(timeIntervalSince1970: 1_000_000)
        user.coins = 100
        user.appLastOpened = last
        #expect(!user.claimDailyReward(now: last.addingTimeInterval(86_399)))
        #expect(user.coins == 100)
        let due = last.addingTimeInterval(86_400)
        #expect(user.claimDailyReward(now: due))
        #expect(user.coins == 105)
        #expect(!user.claimDailyReward(now: due))
        #expect(!user.claimDailyReward(now: last))
        #expect(user.coins == 105)
    }

    @Test func missingRewardDateAndOverflowDoNotCrashOrGrantRepeatedCoins() {
        let user = MockData.initUser
        let now = Date(timeIntervalSince1970: 1_000_000)
        user.appLastOpened = nil
        #expect(!user.claimDailyReward(now: now))
        #expect(user.appLastOpened == now)
        user.coins = Int.max
        #expect(!user.claimDailyReward(now: now.addingTimeInterval(86_400)))
        #expect(user.coins == Int.max)
    }

    @Test func resizingKeepsCirclesReachableAndPreservesTheirIdentity() {
        let board = LuckyCircleGameBoardViewModel()
        let ids = board.luckyCircles.map { $0.id }
        let candidateWinner = board.luckyCircles[98]
        for size in [CGSize(width: 280, height: 320), CGSize(width: 900, height: 650), CGSize(width: 10, height: 12)] {
            board.updateBounds(size)
            #expect(board.luckyCircles.map { $0.id } == ids)
            #expect(board.luckyCircles[98] === candidateWinner)
            for circle in board.luckyCircles {
                let radius = circle.size / 2
                #expect(circle.position.x >= radius - 0.00001)
                #expect(circle.position.y >= radius - 0.00001)
                #expect(circle.position.x <= size.width - radius + 0.00001)
                #expect(circle.position.y <= size.height - radius + 0.00001)
            }
        }
        let priorSize = board.boardSize
        board.updateBounds(.zero)
        #expect(board.boardSize == priorSize)
        board.resetCircles()
        #expect(board.luckyCircles.count == 250)
        #expect(board.luckyCircles.allSatisfy { $0.size <= priorSize.width && $0.size <= priorSize.height })
    }

    @Test func triviaDecodesUnicodeAndPreservesLiteralFormatting() throws {
        let json = #"{"category":"Test","type":"multiple","difficulty":"easy","question":"%22C%2B%2B%22%20%26%20%CF%80%20%2Atext%2A%20%2520","correct_answer":"100%25","incorrect_answers":["%3Ctag%3E","a%2Bb","No"]}"#
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let result = try decoder.decode(TriviaResult.self, from: Data(json.utf8))
        let identity = result.id
        #expect(result.id == identity)
        #expect(String(result.formattedQuestion.characters) == "\"C++\" & π *text* %20")
        let correct = try #require(result.answers.first(where: { $0.isCorrect }))
        #expect(String(correct.text.characters) == "100%")
        #expect(result.answers.count == 4)
    }
}

@MainActor
struct GameCombinationTests {
    @Test func fiftyFiftyRestoresActualBoardAfterLuckyRestart() {
        let board = LuckySquareGameBoardViewModel()
        for _ in 0..<8 { board.advance() }
        #expect(board.luckySquares.count == 10)
        board.restartKeepingScore()
        board.advance()
        #expect(board.luckySquares.count == 3)
        board.use5050()
        #expect(board.luckySquares.count == 2)
        board.advance()
        #expect(board.luckySquares.count == 4)
        #expect(board.countBefore5050 == nil)
    }

    @Test func repeatedFiftyFiftyRetainsOriginalSizeAndAdvancesOnce() {
        let board = LuckySquareGameBoardViewModel()
        for _ in 0..<5 { board.advance() }
        board.use5050()
        board.use5050()
        #expect(board.countBefore5050 == 7)
        board.advance() // Also used by trivia and Free Pass.
        #expect(board.luckySquares.count == 8)
        board.advance()
        #expect(board.luckySquares.count == 9)
    }

    @Test func restartAndLossDiscardTemporaryBoardState() {
        let board = LuckySquareGameBoardViewModel()
        for _ in 0..<5 { board.advance() }
        board.use5050()
        board.restartKeepingScore()
        board.advance()
        #expect(board.luckySquares.count == 3)
        board.use5050()
        board.reset()
        board.advance()
        #expect(board.luckySquares.count == 3)
        #expect(board.luckySquares.allSatisfy { !$0.isDisabled })
    }

    @Test func cutInHalfRemovesHalfOfAllCirclesAndAlwaysKeepsWinner() {
        let board = LuckyCircleGameBoardViewModel()
        let winner = board.luckyCircles[98]
        #expect(board.cutInHalf(preserving: winner.id) == 125)
        #expect(board.luckyCircles.count == 125)
        #expect(board.luckyCircles.contains { $0 === winner })
        board.removeIncorrectCircles(upTo: 123, preserving: winner.id)
        #expect(board.luckyCircles.count == 2)
        #expect(board.cutInHalf(preserving: winner.id) == 1)
        #expect(board.luckyCircles.count == 1)
        #expect(board.cutInHalf(preserving: winner.id) == 0)
        #expect(board.luckyCircles.first === winner)
    }

    @Test func triviaRemovalIsCappedAndInvalidWinnerDoesNotDeleteBoard() {
        let board = LuckyCircleGameBoardViewModel()
        #expect(board.removeIncorrectCircles(upTo: 20, preserving: "missing") == 0)
        #expect(board.luckyCircles.count == 250)
        let winner = board.luckyCircles[98]
        #expect(board.removeIncorrectCircles(upTo: 0, preserving: winner.id) == 0)
        #expect(board.removeIncorrectCircles(upTo: 20, preserving: winner.id) == 20)
        #expect(board.removeIncorrectCircles(upTo: 500, preserving: winner.id) == 229)
        #expect(board.luckyCircles.count == 1)
        #expect(board.luckyCircles.first === winner)
    }

    @Test func colorRemovalRejectsImpossibleUseAndPreservesWinningColor() {
        let board = LuckyCircleGameBoardViewModel()
        let colors: [Color] = [.red, .red, .blue, .green]
        board.luckyCircles = colors.enumerated().map { index, color in
            LuckyCircle(id: String(index), name: String(index), color: color, isDisabled: false, size: 20, position: CGPoint(x: 30, y: 30))
        }
        #expect(board.removableColors(preserving: "0").count == 2)
        #expect(board.removeColors(count: 3, preserving: "0") == 0)
        #expect(board.luckyCircles.count == 4)
        #expect(board.removeColors(count: 2, preserving: "0") == 2)
        #expect(Set(board.luckyCircles.map { $0.id }) == Set(["0", "1"]))
    }
}
