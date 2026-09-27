//
//  PowrUpStats.swift
//  How Lucky
//
//  Created by Peyton White on 11/10/24.
//

import Foundation
import SwiftData

@Model
final class PowerUpStats {
    var id:String
    var name:String
    var totalTimesUsed: Int
    var isTrivia:Bool
    var totalTriviaCorrects: Int
    var totalTriviaInCorrects: Int
    var coinsWon: Int?
    var coinsLost: Int?
    var coinsWagered: Int?
    
    init(id:String, name: String, totalTimesUsed: Int, isTrivia: Bool, totalTriviaCorrects: Int, totalTriviaInCorrects: Int, coinsWon: Int, coinsLost: Int, coinsWagered: Int) {
        self.id = id
        self.name = name
        self.totalTimesUsed = totalTimesUsed
        self.isTrivia = isTrivia
        self.totalTriviaCorrects = totalTriviaCorrects
        self.totalTriviaInCorrects = totalTriviaInCorrects
        self.coinsWon = coinsWon
        self.coinsLost = coinsLost
        self.coinsWagered = coinsWagered
    }
    
}
