import Foundation

/// Odds are net winnings per coin staked. A win also returns the reserved stake.
struct CoinBet {
    let stake: Int
    let odds: Double
    let winnings: Int
    var payout: Int { stake + winnings }
    var cancellationRefund: Int { stake / 3 }

    init?(stake: Int, balance: Int, odds: Double) {
        guard stake > 0, stake <= balance, odds.isFinite, odds >= 0 else { return nil }
        // Correct a one-ULP representation error (e.g. 100 * 4.6 = 459.999…)
        // before rounding down to whole coins.
        let profit = (Double(stake) * odds).nextUp.rounded(.down)
        guard profit.isFinite, profit < Double(Int.max) else { return nil }
        let winnings = Int(profit)
        guard !balance.addingReportingOverflow(winnings).overflow else { return nil }
        self.stake = stake
        self.odds = odds
        self.winnings = winnings
    }

    /// One winning item, with incorrect choices removed after each guess.
    static func odds(choices: Int, guesses: Int = 1) -> Double {
        guard choices > 0, guesses > 0 else { return 0 }
        let attempts = min(choices, guesses)
        return Double(choices - attempts) / Double(attempts)
    }

    static func oddsLabel(_ odds: Double) -> String {
        guard odds.isFinite, odds >= 0 else { return "Unavailable" }
        return String(format: "%.2f to 1", odds)
    }
}
