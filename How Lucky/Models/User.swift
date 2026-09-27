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
