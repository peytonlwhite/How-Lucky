//
//  PowerUpSheetView.swift
//  How Lucky
//
//  Created by Peyton White on 11/2/24.
//

import SwiftUI

enum MainGameType {
    case circles
    case squares
}

struct TriviaSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var triviaManager:TriviaManager
    var function: (_ isCorrect: Bool) -> Void
    @State private var currentActiveBet:Int = 0
    @State private var showingBetPopUp = true
    let user:User
    let mainGameType: MainGameType
    
    //bet text props
    @State private var showBetText = true
    @State private var betTextOpacity = 1.0
    @State private var disapearingBetText = ""
    @State private var colorOfBetText:Color = .yellow
    
    @State private var showBetCoinViewpopUp = false
    @State private var showCorrectAnswer = false
    @State private var coinChangeNum = 0
    @State private var coinTotal = 0
    @State private var coinChangeColor:Color = .green

    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 40) {
                    HStack {
                        Text("Trivia \(triviaManager.triviaType)")
                        
                        if(notMania() && currentActiveBet > 0) {
                            Button {
                                showingBetPopUp = true
                            } label: {
                                Text("Bet")
                                    .font(.title3)
                            }
                        }
                     

                        Spacer()

                        if(triviaManager.reachedEnd) {
                            Text("Done")
                                .foregroundColor(Color(.green))
                                .fontWeight(.heavy)
                        } else {
                            Text("\(triviaManager.index + 1) out of \(triviaManager.length)")
                                .foregroundColor(Color(.green))
                                .fontWeight(.heavy)
                        }
     
                    }
                    
                    // Popup for bet
                    if (showingBetPopUp && currentActiveBet > 0) {
                            CustomDialogYesOrNo(
                                isActive: $showingBetPopUp,
                                title: "Current Bet",
                                message: getActiveBetCancelOrNotMessage(),
                                yesButtonTitle: "Cancel Bet",
                                noButtonTitle: "Keep Bet"
                            ) { isYes in
                                if isYes {
                                    showBetCoinViewPopUp(totalCoins: user.coins!, numOfCoins: 0 - Int(currentActiveBet/3), colorOfChange: .red)
                                    clearActiveBets()
                                } else {
                                    //do nothing
                                }
                            }
                        } else if(showingBetPopUp && notMania()) {
                            BetPopUpView(
                                useOffset: false,
                                userCoins: user.coins ?? 0,
                                bettingOnText: "You are betting on the chance you will guess this trivia answer correctly. \n - We Calculate the odds based on several factors. Some being \n 1. The average person's knowledge\n 2. The fact that most of the time you can cancel one answer out.\n 3. Type of trivia you are playing. ",
                                bettingRulesText: "1. Enter the amount of coins you want to bet.\n2. Check the odds to calculate your potential winnings.\n3. If you don't have enough coins, you'll see an error.\n4. Click 'Bet' to confirm or 'Cancel' to exit.",
                                cancelButtonText: "Don't Bet",
                                titleText: "Bet On Trivia!",
                                isActive: $showingBetPopUp, odds: CGFloat(getOddsForTriviaBet())
                            ) { toBet, coins  in
                                if toBet {
                                    userBetCoinsTriviaAction(coins: Int(coins!))
                                    showBetText(text: "Bet Placed",colorOfText:.yellow)
                                }
                            }
                        }
                     else {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(triviaManager.question)
                                .font(.system(size: 20))
                                .bold()
                                .foregroundColor(.gray)

                            // When answer is clicked, go to next question or close the sheet if done
                            ForEach(triviaManager.answerChoices, id: \.id) { answer in
                                VStack {
                                    AnswerRow(answer: answer, showCorrect: showCorrectAnswer, function: answerClicked)
                                        .environmentObject(triviaManager)
                                }
                            }
                        }
                        Spacer()
                    }

                    
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color(hex: "#e6e6ff"))
                
                // Disappearing Text for bets - Overlay in ZStack
                if showBetText {
                    GeometryReader { geometry in
                        Text(disapearingBetText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(colorOfBetText)
                            .multilineTextAlignment(.center) // Center text if it wraps
                            .opacity(betTextOpacity)
                            .frame(maxWidth: .infinity)
                            .position(
                                x: geometry.size.width / 2, // Center horizontally
                                y: geometry.size.height * 0.05 // Position 10% from the top
                            )
                            .onAppear {
                                withAnimation(.easeOut(duration: 4)) {
                                    betTextOpacity = 0.0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                                    showBetText = false
                                }
                            }
                    }
                }
                
                if showBetCoinViewpopUp {
                    GeometryReader { geometry in
                        CoinsView(userCoins: coinTotal, coinChange: coinChangeNum, coinChangeColor: coinChangeColor, icon: "c.circle",
                                  changePopUpText: "Coins")
                            .position(
                                x: geometry.size.width / 2, // Center horizontally
                                y: geometry.size.height * 0.2 // 20% from the top
                            )
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
                                    showBetCoinViewpopUp = false
                                }
                            }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

private extension TriviaSheetView {
    func answerClicked(isCorrect:Bool) {
        
        if(isCorrect) {
            triviaManager.goToNextQuestion()
        } else if (!isMania()) {
            triviaManager.goToNextQuestion()
        }

        if(isCorrect) {
            checkActiveBetsCorrect()
            if(triviaManager.reachedEnd) {
                dismissAfterSelection(correct:true)
            }
        } else {
            checkActiveBetsInCorrect()
            highlightCorrectAnswer()
            dismissAfterSelection(correct:false)
        }
    }
    
    func highlightCorrectAnswer() {
        showCorrectAnswer = true
    }
    
    func checkActiveBetsCorrect() {
        if(hasActiveBet()) {
            showBetCoinViewPopUp(totalCoins: user.coins!,numOfCoins: (Int(getPayoutFromBet())), colorOfChange: .green)

            //showBetText(text: "Bet Won: +\(Int(getPayoutFromBet()))c",colorOfText:.green)
            updateBettingStatsCorrect()
            user.coins = (user.coins ?? 0) + Int(getPayoutFromBet())
            currentActiveBet = 0
        }
    }
    
    func hasActiveBet() -> Bool {
        return currentActiveBet > 0
    }
    
    func dismissAfterSelection(correct:Bool) {
        let howLongToWait: Int = 2
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(howLongToWait)) {
            function(correct)
            dismiss()
        }
    }
    
    func getOddsForTriviaBet() -> CGFloat {
        return  CGFloat(3) / CGFloat(1)
    }
    
    func clearActiveBets() {
        if(currentActiveBet > 0) {
            showBetText(text: "Bet Cleared",colorOfText:.yellow)
        }
        currentActiveBet = 0
    }
    
    func showBetCoinViewPopUp(totalCoins: Int,numOfCoins:Int,colorOfChange:Color) {
        coinTotal = totalCoins
        coinChangeColor = colorOfChange
        coinChangeNum = numOfCoins
        resetDisapearingBetCoinViewParams()
    }
    
    
    func resetDisapearingBetCoinViewParams() {
        showBetCoinViewpopUp = true
    }
    
    func getActiveBetCancelOrNotMessage() -> String {
        return "\(currentActiveBet) coins at \(formatOddsToFraction(getOddsForTriviaBet())) odds. \n\n *If you cancel your bet you get \(Int(currentActiveBet/3)) coins back"
    }
    
    
    func updateBettingStatsCorrect() {
        if(currentActiveBet > 0) {
            if let stat = getPowerUpStat(id: getTrivaIdBasedOnType()) {
                stat.coinsWagered = (stat.coinsWagered ?? 0) + currentActiveBet
                stat.coinsWon = (stat.coinsWon ?? 0) + Int(getPayoutFromBet())
            }
        }
    }
    
    
    func getPowerUpStat(id: String) -> PowerUpStats? {
        // Check for the main game type and fetch stats accordingly
        if mainGameType == MainGameType.squares {
            return user.luckySquaresStats?.powerUpStats.first(where: { $0.id == id })
        } else if mainGameType == MainGameType.circles {
            return user.luckyCirclesStats?.powerUpStats.first(where: { $0.id == id })
        }
        // If no matching stats are found, return nil
        return nil
    }
    
    func resetDisapearingBetTextParams() {
        showBetText = true
        betTextOpacity = 1.0
    }
    
    func showBetText(text:String, colorOfText:Color) {
        colorOfBetText = colorOfText
        disapearingBetText = text
        resetDisapearingBetTextParams()
    }
        
    func isMania() -> Bool {
        return triviaManager.triviaType.elementsEqual("Mania")
    }
    
    func getTrivaIdBasedOnType() -> String {
        if(mainGameType == MainGameType.squares) {
            switch triviaManager.triviaType {
                case "Easy":
                    return "5"
                case "Medium":
                    return "6"
                case "Hard":
                    return "11"
                case "T/F":
                    return "7"
                case "Mania":
                    return "9"
                default:
                    return ""
            }
        } else {
            switch triviaManager.triviaType {
                case "Easy":
                    return "6"
                case "Medium":
                    return "7"
                case "Hard":
                    return "8"
                case "Mania":
                    return "9"
                default:
                    return ""
            }
        }
       
    }
    
    func updateBettingStatsInCorrect() {
        if(currentActiveBet > 0) {
            if let stat = getPowerUpStat(id: getTrivaIdBasedOnType()) {
                stat.coinsWagered = (stat.coinsWagered ?? 0) + currentActiveBet
                stat.coinsLost = (stat.coinsLost ?? 0) + currentActiveBet
            }
         }
    }
    
    
    func formatOddsToFraction(_ odds: CGFloat) -> String {
        let roundedOdds = round(odds * 10) / 10
        if roundedOdds > 1 {
            return "\(Int(roundedOdds)) to 1"
        } else if roundedOdds == 1 {
            return "1 to 1"
        } else {
            let invertedOdds = 1 / roundedOdds
            return "1 to \(Int(invertedOdds))"
        }
    }
    
    func userBetCoinsTriviaAction(coins:Int) {
        currentActiveBet = coins
    }

    
    func getPayoutFromBet() -> CGFloat {
        return CGFloat(currentActiveBet) * getOddsForTriviaBet()
    }
    
    func checkActiveBetsInCorrect() {
        if(currentActiveBet > 0) {
            showBetCoinViewPopUp(totalCoins: user.coins!,numOfCoins: 0-currentActiveBet, colorOfChange: .red)
            //showBetText(text: "Bet Lost: -\(currentActiveBet)c",colorOfText:.red)
            updateBettingStatsInCorrect()
            user.coins = (user.coins ?? 0) - currentActiveBet
            currentActiveBet = 0
        }
    }
    
    func notMania() -> Bool {
        return triviaManager.triviaType != "Mania"
    }
    
}




#Preview {
    TriviaSheetView(function: { isCorrect in
        
    }, user:MockData.defUser, mainGameType: MainGameType.squares).environmentObject(TriviaManager())
}
