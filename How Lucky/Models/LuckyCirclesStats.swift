//
//  LuckyCirclesStats.swift
//  How Lucky
//
//  Created by Peyton White on 11/10/24.
//

import Foundation
import SwiftData

@Model
final class LuckyCirclesStats {
    var highScore:Int
    var powerUpsUsedForHighscore: Int
    var totalTimesPlayed: Int
    var totalTimesIncorrectInRow: Int

    var powerUpStats:[PowerUpStats]
    var coinsWon: Int?
    var coinsLost: Int?
    var coinsWagered: Int?
    
    init(highScore: Int, powerUpsUsedForHighscore: Int, totalTimesPlayed: Int, totalTimesIncorrectInRow: Int, powerUpStats: [PowerUpStats], coinsWon: Int, coinsLost: Int, coinsWagered: Int) {
        self.highScore = highScore
        self.powerUpsUsedForHighscore = powerUpsUsedForHighscore
        self.totalTimesPlayed = totalTimesPlayed
        self.totalTimesIncorrectInRow = totalTimesIncorrectInRow
        self.powerUpStats = powerUpStats
        self.coinsWon = coinsWon
        self.coinsLost = coinsLost
        self.coinsWagered = coinsWagered
    }
    
}
