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
    @State private var activeBet: CoinBet?
    private var currentActiveBet: Int { activeBet?.stake ?? 0 }
    @State private var showingBetPopUp = true
    let user:User
    let mainGameType: MainGameType
    var onLoadCancelled: () -> Void = {}
    @State private var isFinishing = false
    
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
                ScrollView {
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
                    if triviaManager.isLoading || (triviaManager.length == 0 && triviaManager.errorMessage == nil) {
                        ProgressView("Loading trivia…")
                    } else if let error = triviaManager.errorMessage {
                        Text(error)
                        Button("Retry") {
                            Task { await triviaManager.retry() }
                        }
                        Button("Cancel and return power-up") {
                            onLoadCancelled()
                            dismiss()
                        }
                    } else if (showingBetPopUp && currentActiveBet > 0) {
                            CustomDialogYesOrNo(
                                isActive: $showingBetPopUp,
                                title: "Current Bet",
                                message: getActiveBetCancelOrNotMessage(),
                                yesButtonTitle: "Cancel Bet",
                                noButtonTitle: "Keep Bet"
                            ) { isYes in
                                if isYes {
                                    clearActiveBets()
                                } else {
                                    //do nothing
                                }
                            }
                        } else if(showingBetPopUp && notMania()) {
                            BetPopUpView(
                                useOffset: false,
                                userCoins: user.coins ?? 0,
                                bettingOnText: "Bet on answering this question correctly. Net odds are based on the number of answer choices: 1 to 1 for two choices and 3 to 1 for four choices.",
                                bettingRulesText: "1. Enter the amount of coins you want to bet.\n2. Check the odds to calculate your potential winnings.\n3. If you don't have enough coins, you'll see an error.\n4. Your stake is deducted when you place the bet. A win returns your stake plus whole-coin winnings. Canceling returns one third of the stake. Leaving an unfinished game forfeits the stake.",
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
                                .foregroundStyle(.primary)

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
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(GamePalette.canvas)
                
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
                            .allowsHitTesting(false)
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
                            .allowsHitTesting(false)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
                                    showBetCoinViewpopUp = false
                                }
                            }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled()
        }
    }
}

private extension TriviaSheetView {
    func answerClicked(isCorrect:Bool) {

        guard !isFinishing else { return }
        if isCorrect {
            checkActiveBetsCorrect()
            triviaManager.goToNextQuestion()
            if triviaManager.reachedEnd {
                dismissAfterSelection(correct: true)
            }
        } else {
            checkActiveBetsInCorrect()
            highlightCorrectAnswer()
            dismissAfterSelection(correct: false)
        }
    }

    func highlightCorrectAnswer() {
        showCorrectAnswer = true
    }
    
    func checkActiveBetsCorrect() {
        if(hasActiveBet()) {
            showBetCoinViewPopUp(totalCoins: user.coins!,numOfCoins: (activeBet?.payout ?? 0), colorOfChange: .green)

            //showBetText(text: "Bet Won: +\(Int(getPayoutFromBet()))c",colorOfText:.green)
            updateBettingStatsCorrect()
            user.coins = (user.coins ?? 0) + (activeBet?.payout ?? 0)
            activeBet = nil
        }
    }
    
    func hasActiveBet() -> Bool {
        return currentActiveBet > 0
    }
    
    func dismissAfterSelection(correct:Bool) {
        isFinishing = true
        let howLongToWait: Int = 2
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(howLongToWait)) {
            function(correct)
            dismiss()
        }
    }
    
    func getOddsForTriviaBet() -> CGFloat {
        return CGFloat(CoinBet.odds(choices: triviaManager.answerChoices.count))
    }
    
    func clearActiveBets() {
        guard let bet = activeBet else { return }
        user.coins = (user.coins ?? 0) + bet.cancellationRefund
        if let stat = getPowerUpStat(id: getTrivaIdBasedOnType()) {
            stat.coinsWagered = (stat.coinsWagered ?? 0) + bet.stake
            stat.coinsLost = (stat.coinsLost ?? 0) + bet.stake - bet.cancellationRefund
        }
        activeBet = nil
        showBetText(text: "Bet canceled: \(bet.cancellationRefund) coins returned", colorOfText: .yellow)
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
        guard let bet = activeBet else { return "No active bet" }
        return "\(bet.stake) coins at \(CoinBet.oddsLabel(bet.odds)). Win: \(bet.payout) coins returned. Cancel: \(bet.cancellationRefund) coins returned."
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
                    return "5"
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
        return CoinBet.oddsLabel(Double(odds))
    }
    
    func userBetCoinsTriviaAction(coins:Int) {
        guard activeBet == nil,
              let bet = CoinBet(stake: coins, balance: user.coins ?? 0, odds: Double(getOddsForTriviaBet())) else { return }
        user.coins = (user.coins ?? 0) - bet.stake
        activeBet = bet
    }

    
    func getPayoutFromBet() -> CGFloat {
        return CGFloat(activeBet?.winnings ?? 0)
    }
    
    func checkActiveBetsInCorrect() {
        if(currentActiveBet > 0) {
            showBetCoinViewPopUp(totalCoins: (user.coins ?? 0) + currentActiveBet,numOfCoins: 0-currentActiveBet, colorOfChange: .red)
            //showBetText(text: "Bet Lost: -\(currentActiveBet)c",colorOfText:.red)
            updateBettingStatsInCorrect()
            // The stake was reserved when the bet was placed.
            activeBet = nil
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
