//
//  MockData.swift
//  How Lucky
//
//  Created by Peyton White on 11/10/24.
//

import Foundation
import SwiftUI

class MockData {
    
    static var initUser: User { User(id: "1", luckySquaresStats: initLuckySquareStats,
                                    luckyCirclesStats:initLuckyCirclesStats,
                                     luckyPatternsStats: LuckyPatternsStats(highScore: 0, powerUpsUsedForHighscore: 0, totalTimesPlayed: 0, totalTimesIncorrectInRow: 0, powerUpStats: []),
                                     coins:initUserCoins,
                                     appLastOpened: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                                     resetCoinsUsed: 0,
                                     resetStatsUsed: 0) }
    
    //Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
    
    static var initLuckySquareStats:LuckySquaresStats { LuckySquaresStats(highScore: 0, powerUpsUsedForHighscore: 0, totalTimesPlayed: 0, totalTimesIncorrectInRow: 0, powerUpStats: [
        PowerUpStats(id: "1", name: "Free Pass", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "2", name: "50/50", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "3", name: "Lucky Restart", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "4", name: "Two Guesses", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "5", name: "Trivia Easy", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "6", name: "Trivia Medium", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "11", name: "Trivia Hard", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "7", name: "Trivia ToF", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "9", name: "Trivia Mania", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "10", name: "Reset PowerUps", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "12", name: "Ad For Coins", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0)
    ], coinsWon: 0, coinsLost: 0, coinsWagered: 0) }
    
    static var initLuckyCirclesStats: LuckyCirclesStats { LuckyCirclesStats(highScore: 0, powerUpsUsedForHighscore: 0, totalTimesPlayed: 0, totalTimesIncorrectInRow: 0,powerUpStats: [
        PowerUpStats(id: "1", name: "Free Pass", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "2", name: "Cut in Half", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "3", name: "Remove a Color", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "4", name: "Two Guesses", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "6", name: "Trivia Easy", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "7", name: "Trivia Medium", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "8", name: "Trivia Hard", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "9", name: "Which Quadrant", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "5", name: "Trivia Mania", totalTimesUsed: 0, isTrivia: true, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "11", name: "Remove Three colors", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "10", name: "Remove Two colors", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
        PowerUpStats(id: "12", name: "Ad For Coins", totalTimesUsed: 0, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0)
    ], coinsWon: 0, coinsLost: 0, coinsWagered: 0) }
    
    static let initUserCoins:Int = 300
    
    static var defUser: User { User(id: "2", luckySquaresStats:
                                        LuckySquaresStats(highScore: 50, powerUpsUsedForHighscore: 3, totalTimesPlayed: 22, totalTimesIncorrectInRow: 4,
                                                                                powerUpStats: [
                                                                                    PowerUpStats(id: "1", name: "Free Pass", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "2", name: "50/50", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "3", name: "Lucky Restart", totalTimesUsed: 8, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "4", name: "Two Guesses", totalTimesUsed: 2, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "5", name: "Trivia Easy", totalTimesUsed: 50, isTrivia: true, totalTriviaCorrects: 25, totalTriviaInCorrects: 25, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "6", name: "Trivia Medium", totalTimesUsed: 40, isTrivia: true, totalTriviaCorrects: 10, totalTriviaInCorrects: 30, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "11", name: "Trivia Hard", totalTimesUsed: 26, isTrivia: true, totalTriviaCorrects: 20, totalTriviaInCorrects: 6, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "7", name: "Trivia ToF", totalTimesUsed: 7, isTrivia: true, totalTriviaCorrects: 4, totalTriviaInCorrects: 3, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "9", name: "Trivia Mania", totalTimesUsed: 21, isTrivia: true, totalTriviaCorrects: 14, totalTriviaInCorrects: 7, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "10", name: "Reset PowerUps", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                                                    PowerUpStats(id: "12", name: "Ad For Coins", totalTimesUsed: 2, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0)

                                                                                ], coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                    luckyCirclesStats:
                                        LuckyCirclesStats(highScore: 150, powerUpsUsedForHighscore: 4, totalTimesPlayed: 50, totalTimesIncorrectInRow: 4,
                                                          powerUpStats: [
                                                            PowerUpStats(id: "1", name: "Free Pass", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "2", name: "Cut in Half", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "3", name: "Remove a Color", totalTimesUsed: 8, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "4", name: "+2 Guesses", totalTimesUsed: 2, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "6", name: "Trivia Easy", totalTimesUsed: 50, isTrivia: true, totalTriviaCorrects: 25, totalTriviaInCorrects: 25, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "7", name: "Trivia Medium", totalTimesUsed: 40, isTrivia: true, totalTriviaCorrects: 10, totalTriviaInCorrects: 30, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "8", name: "Trivia Hard", totalTimesUsed: 26, isTrivia: true, totalTriviaCorrects: 20, totalTriviaInCorrects: 6, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "9", name: "Which Quadrant", totalTimesUsed: 7, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "5", name: "Trivia Mania", totalTimesUsed: 21, isTrivia: true, totalTriviaCorrects: 14, totalTriviaInCorrects: 7, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "11", name: "Remove Three colors", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "10", name: "Remove Two colors", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                                            PowerUpStats(id: "12", name: "Ad For Coins", totalTimesUsed: 4, isTrivia: false, totalTriviaCorrects: 0, totalTriviaInCorrects: 0, coinsWon: 0, coinsLost: 0, coinsWagered: 0)
                                                        ], coinsWon: 0, coinsLost: 0, coinsWagered: 0),
                                        luckyPatternsStats: LuckyPatternsStats(highScore: 0, powerUpsUsedForHighscore: 0, totalTimesPlayed: 0, totalTimesIncorrectInRow: 0, powerUpStats: []),
                                        coins:10, appLastOpened: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                                        resetCoinsUsed: 0,
                                        resetStatsUsed: 0) }
    
    static var freePassPowerUp: PowerUp { PowerUp(id: "1", name: "Free Pass", color: .yellow, isLocked: false, description: "Free Points!", costOfCoins: 0) }
   
    static var squarePowerUps: [PowerUp] { [
        PowerUp(id:"2", name: "50/50", color: .blue, isLocked: false,
                description: "Go back to 2 squares to get an extra point", costOfCoins: 10),
        PowerUp(id:"3", name: "Lucky Restart", color: .orange, isLocked: false,
                description: "Start back to 2 squares but keep your current score :)", costOfCoins: 10),
        PowerUp(id:"4", name: "Two Guesses", color: .red, isLocked: false,
                description: "Get two guesses for your next point", costOfCoins: 0),
        PowerUp(id:"5", name: "Trivia Easy", color: .purple, isLocked: false,
                description: "Get an easy triva question correct to gain another point", costOfCoins: 5),
        PowerUp(id:"6", name: "Trivia Med", color: .pink, isLocked: false,
                description: "Get a medium triva question correct to gain another point", costOfCoins: 3),
        PowerUp(id:"7", name: "Trivia ToF", color: .black, isLocked: false,
                description: "Get a true or false triva question correct to gain another point", costOfCoins: 0),
        PowerUp(id:"9", name: "Trivia Mania", color: .green, isLocked: false,
                description: "How man ever triva questions you get correct, that's how many points you get. Go Crazy! Don't cheat!", costOfCoins: 5),
        PowerUp(id:"10", name: "Reset PowerUps", color: .indigo, isLocked: false,
                description: "Reset all locked powerUps", costOfCoins: 20),
        PowerUp(id:"11", name: "Trivia Hard", color: .indigo, isLocked: false,
                description: "Get a hard triva question correct to gain another point", costOfCoins: 0),
        PowerUp(id:"12", name: "Ad For Coins", color: .random, isLocked: false,
                description: "Watch an ad to earn coins", costOfCoins: 0)
    ] }
    
    static var circlePowerUps: [PowerUp] { [
        PowerUp(id:"2", name: "Cut in Half", color: .blue, isLocked: false,
                description: "remove half of the circles", costOfCoins: 0),
        PowerUp(id:"3", name: "Remove a color", color: .red, isLocked: false,
                description: "Get rid of all the (blue) circles", costOfCoins: 0),
        PowerUp(id:"4", name: "+2 Guesses", color: .orange, isLocked: false,
                description: "Adds two more guesses", costOfCoins: 5),
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
                description: "Get rid of all the (blue and green) circles", costOfCoins: 0),
        PowerUp(id:"11", name: "Remove three colors", color: .pink, isLocked: false,
                description: "Get rid of all the (blue, green, and pink) circles", costOfCoins: 5),
        PowerUp(id:"12", name: "Ad For Coins", color: .random, isLocked: false,
                description: "Watch an ad to earn coins", costOfCoins: 0)
        
       
    ] }
    
     static var patternPowerUps: [PowerUp] { [
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
                 description: "Watch an ad to earn coins", costOfCoins: 0)
     ] }
    

    static let luckySquaresDescription: LocalizedStringKey = "**1. The Goal** \n Your objective is to select the **correct square** hidden on the board. At the start, there are **2 squares**, but only **1 is correct**.\n\n **2. Progression** \n- If you pick the correct square, you’ll move to the next round.\n- In each round, the number of squares increases by **1**, but there’s still only **1 correct square**.\n\n **3. Power-Ups** \nUse power-ups to improve your chances and climb to a **higher score**:\n\n **4. Betting Coins** \n- You can bet your coins to **increase your rewards**.\n- The higher your bet, the more coins you can win!\n- But beware: if you guess wrong, you’ll lose the coins.\n\n **5. Winning Streaks** \nBuild up your streaks to boost your high score. Each correct guess adds to your streak! \n - You can also bet on the trivia power up. \n\n **6. Tips** \n - Top Bar: In order Left to Right the numbers at top are: Tries left, Squares count."

    
    static let luckyCirclesDescription: LocalizedStringKey = "**The Objective** \n- The game starts out with 250 circles on the screen. \n- Each turn consist of 6 guesses and only one circle on the screen is correct. The screen will light up green if you are correct, Otherwise the circle chosen is incorrect and will remove itself. \n- After all guesses have been used the correct circle will show itself. \n- There are 10 seperate colors for the 250 circles. Each color has 25 circles. \n- Use Power Ups to reduce the circles on the screen and break highscores and reduce betting odds.\n\n **Tips** \n - The numbers at top are (Left to Right) are Tries left, Circles Left. Use Power Ups to get that number down for a better chance. \n\n - Getting a trivia power up wrong does not restart the game. \n\n - Use the Quadrant Power Up every turn. \n\n - Always use the 50/50. \n\n - Power Ups reset each correct guess, so use all of them each turn. \n\n **Betting** \n **Dynamic Odds System** \n - True probability-based odds system \n\n - You are betting on the chance to guess the correct circle within **Your Guesses left** attempts. \n\n - See more in Betting Info Bubble when betting"

    static let luckySquaresBetDescription: LocalizedStringKey = "You are betting on the chance you will guess the correct square given each turn the correct square changes without you knowing which one it is"
    
    static let luckyCirclesBetDescription: LocalizedStringKey = """
    Bet on finding the winning circle within your remaining guesses. Incorrect circles are removed, so the chance of winning is guesses divided by eligible circles (up to 100%). A quadrant hint limits eligible circles to that quadrant.

    With 250 circles and 6 guesses, the chance is 6/250 (2.4%). Net winnings are approximately 40.67 coins per coin staked, rounded down to whole coins for the complete bet.

    The stake is deducted when you place the bet. Odds stay fixed until it ends. Power-ups are unavailable while betting. A win returns the stake plus winnings; canceling returns one third of the stake. Leaving an unfinished game forfeits the stake.
    """
}
