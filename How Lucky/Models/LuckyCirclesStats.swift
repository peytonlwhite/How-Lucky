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
    
    init(highScore: Int, powerUpsUsedForHighscore: Int, totalTimesPlayed: Int, totalTimesIncorrectInRow: Int, powerUpStats: [PowerUpStats]) {
        self.highScore = highScore
        self.powerUpsUsedForHighscore = powerUpsUsedForHighscore
        self.totalTimesPlayed = totalTimesPlayed
        self.totalTimesIncorrectInRow = totalTimesIncorrectInRow
        self.powerUpStats = powerUpStats
    }
    
}
