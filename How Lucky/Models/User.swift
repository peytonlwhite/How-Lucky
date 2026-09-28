//
//  Item.swift
//  How Lucky
//
//  Created by Peyton White on 10/29/24.
//

import Foundation
import SwiftData

@Model
final class User: ObservableObject {
    
    @Attribute(.unique)
    var id:String
    var luckySquaresStats: LuckySquaresStats?
    var luckyCirclesStats: LuckyCirclesStats?
    var luckyPatternsStats: LuckyPatternsStats?
    var coins: Int?
    var appLastOpened: Date?
    var resetCoinsUsed: Int?
    var resetStatsUsed: Int?

    init(id:String, luckySquaresStats: LuckySquaresStats, luckyCirclesStats:LuckyCirclesStats,
         luckyPatternsStats: LuckyPatternsStats, coins: Int, appLastOpened: Date, resetCoinsUsed:Int, resetStatsUsed:Int) {
        self.id = UUID().uuidString
        self.luckySquaresStats = luckySquaresStats
        self.luckyCirclesStats = luckyCirclesStats
        self.luckyPatternsStats = luckyPatternsStats
        self.coins = coins
        self.appLastOpened = appLastOpened
        self.resetCoinsUsed = resetCoinsUsed
        self.resetStatsUsed = resetStatsUsed
    }
}

// Fill absent fields from earlier versions without resetting an existing save.
extension User {
    func repairMissingDefaults() {
        if coins == nil { coins = MockData.initUserCoins }
        if appLastOpened == nil { appLastOpened = Date() }
        if resetCoinsUsed == nil { resetCoinsUsed = 0 }
        if resetStatsUsed == nil { resetStatsUsed = 0 }
        if luckySquaresStats == nil { luckySquaresStats = MockData.initLuckySquareStats }
        if luckyCirclesStats == nil { luckyCirclesStats = MockData.initLuckyCirclesStats }
        if luckyPatternsStats == nil { luckyPatternsStats = MockData.initUser.luckyPatternsStats }
        if let stats = luckySquaresStats {
            for initial in MockData.initLuckySquareStats.powerUpStats where !stats.powerUpStats.contains(where: { $0.id == initial.id }) {
                stats.powerUpStats.append(initial)
            }
        }
        if let stats = luckyCirclesStats {
            for initial in MockData.initLuckyCirclesStats.powerUpStats where !stats.powerUpStats.contains(where: { $0.id == initial.id }) {
                stats.powerUpStats.append(initial)
            }
        }
    }
}

extension User {
    @discardableResult
    func claimDailyReward(now: Date = Date()) -> Bool {
        guard let lastReward = appLastOpened else {
            appLastOpened = now
            return false
        }
        guard now.timeIntervalSince(lastReward) >= 24 * 60 * 60 else { return false }
        let (balance, overflow) = (coins ?? 0).addingReportingOverflow(5)
        guard !overflow else { return false }
        coins = balance
        appLastOpened = now
        return true
    }
}
