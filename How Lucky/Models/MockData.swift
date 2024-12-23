//
//  MockData.swift
//  How Lucky
//
//  Created by Peyton White on 11/10/24.
//

import Foundation

class MockData {
    
    static let initUser: User = User(id: "1", luckySquaresStats:
                                        LuckySquaresStats(highScore: 0, powerUpsUsedForHighscore: 0, totalTimesPlayed: 0, totalTimesIncorrectInRow: 0, powerUpStats: [
                                            PowerUpStats(id: "1", name: "Free Pass", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "2", name: "50/50", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "3", name: "Lucky Restart", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "4", name: "Two Guesses", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "5", name: "Trivia Easy", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "6", name: "Trivia Medium", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "11", name: "Trivia Hard", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "7", name: "Trivia ToF", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "9", name: "Trivia Mania", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "10", name: "Reset PowerUps", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "12", name: "Ad For Coins", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0)
                                        ]),
                                    luckyCirclesStats:
                                        LuckyCirclesStats(highScore: 0, powerUpsUsedForHighscore: 0, totalTimesPlayed: 0, totalTimesIncorrectInRow: 0,powerUpStats: [
                                            PowerUpStats(id: "1", name: "Free Pass", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "2", name: "50%", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "3", name: "Remove a Color", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "4", name: "Two Guesses", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "6", name: "Trivia Easy", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "7", name: "Trivia Medium", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "8", name: "Trivia Hard", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "9", name: "Which Quadrant", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "5", name: "Trivia Mania", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "11", name: "Remove Three colors", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "10", name: "Remove Two colors", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                            PowerUpStats(id: "12", name: "Ad For Coins", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0)
                                        ]),
                                     luckyPatternsStats: LuckyPatternsStats(highScore: 0, powerUpsUsedForHighscore: 0, totalTimesPlayed: 0, totalTimesIncorrectInRow: 0, powerUpStats: []),
                                     coins:50, appLastOpened: Calendar.current.date(byAdding: .day, value: -2, to: Date())!)
    
    //Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
    
    static let defUser: User = User(id: "2", luckySquaresStats:
                                        LuckySquaresStats(highScore: 50, powerUpsUsedForHighscore: 3, totalTimesPlayed: 22, totalTimesIncorrectInRow: 4,
                                                                                powerUpStats: [
                                                                                    PowerUpStats(id: "1", name: "Free Pass", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                                                    PowerUpStats(id: "2", name: "50/50", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                                                    PowerUpStats(id: "3", name: "Lucky Restart", totalTimesUsed: 8, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                                                    PowerUpStats(id: "4", name: "Two Guesses", totalTimesUsed: 2, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                                                    PowerUpStats(id: "5", name: "Trivia Easy", totalTimesUsed: 50, isTrivia: true, totalTriviaCorrects: 25, totalTriviaInCorrects: 25),
                                                                                    PowerUpStats(id: "6", name: "Trivia Medium", totalTimesUsed: 40, isTrivia: true, totalTriviaCorrects: 10, totalTriviaInCorrects: 30),
                                                                                    PowerUpStats(id: "11", name: "Trivia Hard", totalTimesUsed: 26, isTrivia: true, totalTriviaCorrects: 20, totalTriviaInCorrects: 6),
                                                                                    PowerUpStats(id: "7", name: "Trivia ToF", totalTimesUsed: 7, isTrivia: true, totalTriviaCorrects: 4, totalTriviaInCorrects: 3),
                                                                                    PowerUpStats(id: "9", name: "Trivia Mania", totalTimesUsed: 21, isTrivia: true, totalTriviaCorrects: 14, totalTriviaInCorrects: 7),
                                                                                    PowerUpStats(id: "10", name: "Reset PowerUps", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                                                    PowerUpStats(id: "12", name: "Ad For Coins", totalTimesUsed: 2, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0)

                                                                                ]),
                                    luckyCirclesStats:
                                        LuckyCirclesStats(highScore: 150, powerUpsUsedForHighscore: 4, totalTimesPlayed: 50, totalTimesIncorrectInRow: 4,
                                                          powerUpStats: [
                                                            PowerUpStats(id: "1", name: "Free Pass", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                            PowerUpStats(id: "2", name: "50%", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                            PowerUpStats(id: "3", name: "Remove a Color", totalTimesUsed: 8, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                            PowerUpStats(id: "4", name: "Two Guesses", totalTimesUsed: 2, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                            PowerUpStats(id: "6", name: "Trivia Easy", totalTimesUsed: 50, isTrivia: true, totalTriviaCorrects: 25, totalTriviaInCorrects: 25),
                                                            PowerUpStats(id: "7", name: "Trivia Medium", totalTimesUsed: 40, isTrivia: true, totalTriviaCorrects: 10, totalTriviaInCorrects: 30),
                                                            PowerUpStats(id: "8", name: "Trivia Hard", totalTimesUsed: 26, isTrivia: true, totalTriviaCorrects: 20, totalTriviaInCorrects: 6),
                                                            PowerUpStats(id: "9", name: "Which Quadrant", totalTimesUsed: 7, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                            PowerUpStats(id: "5", name: "Trivia Mania", totalTimesUsed: 21, isTrivia: true, totalTriviaCorrects: 14, totalTriviaInCorrects: 7),
                                                            PowerUpStats(id: "11", name: "Remove Three colors", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                            PowerUpStats(id: "10", name: "Remove Two colors", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0),
                                                            PowerUpStats(id: "12", name: "Ad For Coins", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0)
                                                        ]),
                                        luckyPatternsStats: LuckyPatternsStats(highScore: 0, powerUpsUsedForHighscore: 0, totalTimesPlayed: 0, totalTimesIncorrectInRow: 0, powerUpStats: []),
                                        coins:50, appLastOpened: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date())
    
    static let freePassPowerUp: PowerUp = PowerUp(id: "1", name: "Free Pass", color: .yellow, isLocked: false, description: "Free Points!", costOfCoins: 0)
   
    static let squarePowerUps: [PowerUp] = [
        PowerUp(id:"2", name: "50/50", color: .blue, isLocked: false,
                description: "Go back to 2 squares to get an extra point", costOfCoins: 1),
        PowerUp(id:"3", name: "Lucky Restart", color: .orange, isLocked: false,
                description: "Start back to 2 squares but keep your current score :)", costOfCoins: 2),
        PowerUp(id:"4", name: "Two Guesses", color: .red, isLocked: false,
                description: "Get two guesses for your next point", costOfCoins: 0),
        PowerUp(id:"5", name: "Trivia Easy", color: .purple, isLocked: false,
                description: "Get an easy triva question correct to gain another point", costOfCoins: 1),
        PowerUp(id:"6", name: "Trivia Med", color: .pink, isLocked: false,
                description: "Get a medium triva question correct to gain another point", costOfCoins: 2),
        PowerUp(id:"7", name: "Trivia ToF", color: .black, isLocked: false,
                description: "Get a true or false triva question correct to gain another point", costOfCoins: 0),
        PowerUp(id:"9", name: "Trivia Mania", color: .green, isLocked: false,
                description: "How man ever triva questions you get correct, that's how many points you get. Go Crazy! Don't cheat!", costOfCoins: 0),
        PowerUp(id:"10", name: "Reset PowerUps", color: .indigo, isLocked: false,
                description: "Reset all locked powerUps", costOfCoins: 5),
        PowerUp(id:"11", name: "Trivia Hard", color: .indigo, isLocked: false,
                description: "Get a hard triva question correct to gain another point", costOfCoins: 0),
        PowerUp(id:"12", name: "Ad For Coins", color: .random, isLocked: false,
                description: "Get 5 Coins for an ad", costOfCoins: 0)
    ]
    
    static let circlePowerUps: [PowerUp] = [
        PowerUp(id:"2", name: "50%", color: .blue, isLocked: false,
                description: "remove half of the circles", costOfCoins: 0),
        PowerUp(id:"3", name: "Remove a color", color: .red, isLocked: false,
                description: "Get rid of all the (blue) circles", costOfCoins: 0),
        PowerUp(id:"4", name: "Two guesses", color: .orange, isLocked: false,
                description: "Two guesses at the correct circle", costOfCoins: 0),
        PowerUp(id:"5", name: "Triva mania", color: .black, isLocked: false,
                description: "Each question correct gets rid of 5 circles", costOfCoins: 0),
        PowerUp(id:"6", name: "Triva Easy", color: .mint, isLocked: false,
                description: "Correct answer removes 20 circles", costOfCoins: 0),
        PowerUp(id:"7", name: "Triva Med", color: .green, isLocked: false,
                description: "Correct answer removes 40 circles", costOfCoins: 0),
        PowerUp(id:"8", name: "Triva Hard", color: .indigo, isLocked: false,
                description: "Correct answer removes 60 circles", costOfCoins: 0),
        PowerUp(id:"9", name: "Which Quadrant", color: .brown, isLocked: false,
                description: "Tells you out of which 4 quadrants the circle is located in", costOfCoins: 0),
        PowerUp(id:"10", name: "Remove two colors", color: .purple, isLocked: false,
                description: "Get rid of all the (blue and green) circles", costOfCoins: 1),
        PowerUp(id:"11", name: "Remove three colors", color: .pink, isLocked: false,
                description: "Get rid of all the (blue, green, and pink) circles", costOfCoins: 2),
        PowerUp(id:"12", name: "Ad For Coins", color: .random, isLocked: false,
                description: "Get 5 Coins for an ad", costOfCoins: 0)
        
       
    ]
    
     static let patternPowerUps: [PowerUp] = [
         PowerUp(id:"2", name: "50/50", color: .blue, isLocked: false,
                 description: "Go back to 2 squares to get an extra point", costOfCoins: 1),
         PowerUp(id:"3", name: "Lucky Restart", color: .orange, isLocked: false,
                 description: "Start back to 2 squares but keep your current score :)", costOfCoins: 2),
         PowerUp(id:"4", name: "Two Guesses", color: .red, isLocked: false,
                 description: "Get two guesses for your next point", costOfCoins: 0),
         PowerUp(id:"5", name: "Trivia Easy", color: .purple, isLocked: false,
                 description: "Get an easy triva question correct to gain another point", costOfCoins: 1),
         PowerUp(id:"6", name: "Trivia Med", color: .pink, isLocked: false,
                 description: "Get a medium triva question correct to gain another point", costOfCoins: 2),
         PowerUp(id:"7", name: "Trivia ToF", color: .black, isLocked: false,
                 description: "Get a true or false triva question correct to gain another point", costOfCoins: 0),
         PowerUp(id:"9", name: "Trivia Mania", color: .green, isLocked: false,
                 description: "How man ever triva questions you get correct, that's how many points you get. Go Crazy! Don't cheat!", costOfCoins: 0),
         PowerUp(id:"10", name: "Reset PowerUps", color: .indigo, isLocked: false,
                 description: "Reset all locked powerUps", costOfCoins: 5),
         PowerUp(id:"11", name: "Trivia Hard", color: .indigo, isLocked: false,
                 description: "Get a hard triva question correct to gain another point", costOfCoins: 0),
         PowerUp(id:"12", name: "Ad For Coins", color: .random, isLocked: false,
                 description: "Get 5 Coins for an ad", costOfCoins: 0)
     ]
    
}
