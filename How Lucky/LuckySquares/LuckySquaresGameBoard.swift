//
//  playground.swift
//  How Lucky
//
//  Created by Peyton White on 10/29/24.
//

import SwiftUI

struct LuckySquaresGameBoard: View {
    
    // MARK: - User and View Model
    @Bindable var user: User
    @Environment(\.modelContext) var context
    @StateObject var viewModel = LuckySquareGameBoardViewModel()
    @StateObject var triviaManager = TriviaManager()
    
    // MARK: - Game and Power-Up State
    @State private var timesGuessedRight: Int = 0
    @State private var timesGuessedWrong: Int = 0
    @State private var powerUpsUsedForHighscore: Int = 0
    @State private var score: Int = 0
    @State private var timesGuessed: Int = 0
    @State private var columnCount: Int = 2
    @State private var lockBoard = false
    @State private var showingPowerUpSheet = false
    @State private var showingTriviaSheet = false
    @State private var showingBetPopUp = false
    @State private var textSwitch = false
    @State private var activePowerUps: [PowerUp] = []
    
    @State var powerUps: [PowerUp]
    @State private var freePassPowerUp = MockData.freePassPowerUp
    @State private var nextCorrectSquare = LuckySquare(id: "99", name: "Empty", color: .red, isDisabled: false)
    @State private var howManyGuessesLeft: Int = 1
    @State private var typeOfTrivia: String = ""

    @State private var viewGameDirections = false

    
    // MARK: - Animation Properties
    @State private var colors: [Color] = [Color(hex: "#3b3a39"), .red]
    private let maxScaleEffect: CGFloat = 4.0
    private let minScaleEffect: CGFloat = 0
    private let animationDuration = 1.2
    private let animationDelay = 0.1
    @State private var shouldTransition = true
    @State private var colorIndex = 0
    
    @Environment(\.colorScheme) var colorScheme

    //MARK: - ad properties
    @StateObject var rewardViewModel = RewardedViewModel()

    @State private var hasStarted = false
    @State private var isLoading = true
 
    //disapearing reg text props
    @State private var showText = true
    @State private var triedMoreThanOnce = false
    @State private var textOpacity = 1.0
    @State private var disapearingText = "Guess the correct square!"
    @State var showingPopupContinueChance: Bool = false

    
    //bet text props
    @State private var showBetText = true
    @State private var colorOfBetText:Color = .yellow
    @State private var betTextOpacity = 1.0
    @State private var disapearingBetText = ""

    
    //MARK: - bet properties
    @State private var activeBet: CoinBet?
    private var currentActiveBet: Int { activeBet?.stake ?? 0 }
    @State private var showBetCoinViewpopUp = false
    
    @State private var coinPopupID = UUID()
    @State private var coinChangeNum = 0
    @State private var coinTotal = 0
    @State private var coinChangeColor:Color = .green

    
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var noticeID = UUID()

    var body: some View {
        ZStack {
            GamePalette.canvas.ignoresSafeArea()
            GeometryReader { layout in
            VStack(spacing: 12) {
                GameDashboard(score: score, best: user.luckySquaresStats?.highScore ?? 0,
                              guesses: howManyGuessesLeft, pieces: viewModel.luckySquares.count,
                              pieceName: "squares", coins: user.coins ?? 0, accent: GamePalette.squares, compact: layout.size.height < 480)
                HStack {
                    Text("Pick your lucky square").font(.headline)
                    Spacer()
                    if activeBet != nil {
                        Label("Bet active", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.semibold)).foregroundStyle(GamePalette.squares)
                    }
                }.padding(.horizontal, 4)
                gameBoard
                    .disabled(isLoading || lockBoard || showingBetPopUp || showingPopupContinueChance)
                statusShelf
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: 900)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }

            if isLoading {
                Color.black.opacity(0.18).ignoresSafeArea()
                ProgressView("Getting ready…")
                    .padding(28).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
                                // Popup for bet
                    if showingBetPopUp {
                        if currentActiveBet > 0 {
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
                                    showingBetPopUp = false
                                }
                            }
                        } else {
                            BetPopUpView(
                                useOffset: false,
                                userCoins: user.coins!,
                                bettingOnText: MockData.luckySquaresBetDescription,
                                bettingRulesText: "1. Enter the amount of coins you want to bet.\n2. Check the odds to calculate your potential winnings.\n3. If you don't have enough coins, you'll see an error.\n4. Your stake is deducted when you place the bet. A win returns your stake plus whole-coin winnings. Canceling returns one third of the stake. Leaving an unfinished game forfeits the stake.",
                                cancelButtonText: "Cancel",
                                titleText:"Win Some Coins!",
                                isActive: $showingBetPopUp, odds: CGFloat(getOddsForBet())
                            ) { toBet,coins  in
                                if toBet {
                                    userBetCoinsAction(coins:Int(coins!))
                                    showBetText(text: "Bet Placed", colorOfText: .yellow)
                                } else {

                                }
                            }
                        }
                    }


                    if showingPopupContinueChance {
                        CustomDialogYesOrNo(
                            isActive: $showingPopupContinueChance,
                            title: "Free Chance",
                            message: "Watch an Ad to continue?",
                            yesButtonTitle: "Yes",
                            noButtonTitle: "No"
                        ) { isYes in
                            if isYes {
                                adForContinueChance()
                            } else {
                                squareClickedIsInCorrect(chance: false)
                            }
                        }
                    }
        }
        .navigationTitle("Lucky Squares")
        .navigationBarTitleDisplayMode(.inline)
        .tint(GamePalette.squares)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { viewGameDirections = true } label: { Image(systemName: "questionmark.circle") }
                    .accessibilityLabel("How to play Lucky Squares")
                    .disabled(isLoading || showingBetPopUp || showingPopupContinueChance)
            }
        }
        .sheet(isPresented: $viewGameDirections) {
            GameRulesSheet(title: "How to play", rules: MockData.luckySquaresDescription)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ToolbarView(
                        showingPowerUpSheet: $showingPowerUpSheet,
                        showingTriviaSheet: $showingTriviaSheet,
                        showingBetPopUp: $showingBetPopUp,
                        powerUps: powerUps,
                        freePassPowerUp: freePassPowerUp,
                        powerUpChosen: powerUpChosen,
                        triviaDone: triviaDone,
                        triviaManager: triviaManager,
                        showBets: isBettingActive(),
                        user: user,
                        mainGameType: MainGameType.squares,
                        hasActiveBet: activeBet != nil,
                        triviaCancelled: triviaCancelled
                    )
                .disabled(isLoading || lockBoard || showingBetPopUp || showingPopupContinueChance)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
        }
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            isLoading = false
            resetPowerUps()
            resetActivePowerUps()

        }
    }

    private var statusShelf: some View {
        Group {
            if showBetCoinViewpopUp {
                GameNotice(text: "\(coinChangeNum >= 0 ? "+" : "")\(coinChangeNum) coins · Balance \(user.coins ?? 0)",
                           symbol: "c.circle.fill", tint: coinChangeNum >= 0 ? .green : .red)
                    .id(coinPopupID)
                    .task {
                        do { try await Task.sleep(for: .seconds(3)) } catch { return }
                        showBetCoinViewpopUp = false
                    }
            }  else if showBetText && !disapearingBetText.isEmpty {
                GameNotice(text: disapearingBetText, symbol: "info.circle", tint: GamePalette.squares)
                    .id(noticeID)
                    .task {
                        do { try await Task.sleep(for: .seconds(3)) } catch { return }
                        showBetText = false
                    }
            } else {
                GameNotice(text: lockBoard ? "The winning square is revealed. Next round coming up…" : "One winner. Each correct pick adds a square.",
                           symbol: lockBoard ? "eye" : "hand.tap", tint: .secondary)
            }
        }
    }

    private var gameBoard: some View {
        GeometryReader { geometry in
            let capacity = typeSize.isAccessibilitySize ? 2 : max(2, Int(max(0, geometry.size.width - 22) / 76))
            let columns = min(capacity, min(6, max(2, Int(ceil(sqrt(Double(viewModel.luckySquares.count)))))))
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columns), spacing: 10) {
                    ForEach(viewModel.luckySquares) { square in
                        Button { squareClicked(square: square) } label: { LuckySquareView(square: square) }
                            .buttonStyle(.plain)
                            .disabled(square.isDisabled)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: CGFloat(columns) * 112)
                .frame(maxWidth: .infinity)
                .padding(16)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: viewModel.luckySquares.count)
            }
            .background(GamePalette.surface, in: RoundedRectangle(cornerRadius: 24))
            .overlay { RoundedRectangle(cornerRadius: 24).strokeBorder(GamePalette.squares.opacity(0.15), lineWidth: 1) }
        }
    }
}

private extension LuckySquaresGameBoard {
    
    
    var previousColor: Color { colors[colorIndex % colors.count] }
    var transitioningColor: Color { colors[(colorIndex + 1) % colors.count] }
     
    func getActiveBetCancelOrNotMessage() -> String {
        guard let bet = activeBet else { return "No active bet" }
        return "\(bet.stake) coins at \(CoinBet.oddsLabel(bet.odds)). Win: \(bet.payout) coins returned. Cancel: \(bet.cancellationRefund) coins returned."
    }
    
    func formatOddsToFraction(_ odds: CGFloat) -> String {
        return CoinBet.oddsLabel(Double(odds))
    }
    
    func isBettingActive() -> Bool {
        if(isPowerUpActive(id: "4")) {
            return false
        }
        return true
    }
    
    func getOddsForBet() -> CGFloat {
        return CGFloat(CoinBet.odds(choices: viewModel.luckySquares.filter { !$0.isDisabled }.count, guesses: howManyGuessesLeft))
    }
    
    func userBetCoinsAction(coins:Int) {
        guard activeBet == nil,
              let bet = CoinBet(stake: coins, balance: user.coins ?? 0, odds: Double(getOddsForBet())) else { return }
        user.coins = (user.coins ?? 0) - bet.stake
        activeBet = bet
    }
    
    func isSquareCorrect(squareId:String) -> Bool {
        return squareId == nextCorrectSquare.id
    }
    
    func startFlashingAnimation() {
        colorIndex = 0
        if(colorScheme == .dark) {
                colors = [.black, .red]
        }
        shouldTransition = false
        colorIndex += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                shouldTransition = true
            }
        }
    }
    
    func triviaDone(isCorrect:Bool) {
        if triviaManager.triviaType == "Mania" {
            let stat = getPowerUpStat(id: "9")
            stat.totalTriviaCorrects += triviaManager.score
            if !isCorrect { stat.totalTriviaInCorrects += 1 }
            for _ in 0..<triviaManager.score {
                guard isPowerUpActive(id: "1") || viewModel.luckySquares.contains(where: { $0 === square && !$0.isDisabled }) else { return }
        timesGuessed += 1
                squareClickedIsCorrect()
            }
            removeFromActivePowerUps(id: "9")
        } else {
            // Record the result before a loss resets the active power-ups.
            removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: isCorrect)
            guard isPowerUpActive(id: "1") || viewModel.luckySquares.contains(where: { $0 === square && !$0.isDisabled }) else { return }
        timesGuessed += 1
            if isCorrect {
                squareClickedIsCorrect()
            } else {
                squareClickedIsInCorrectDontShowCorrectSquare(chance: true)
            }
        }
        resetTriviaManager()
    }
    
    func getTrivaIdBasedOnType() -> String {
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
    }
    
    func removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: Bool) {
        if(isCorrect) {
            getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaCorrects += 1
        } else {
            getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaInCorrects += 1
        }
        removeFromActivePowerUps(id:getTrivaIdBasedOnType())
    }
    
    func triviaCancelled() {
        let id = getTrivaIdBasedOnType()
        if let powerUp = activePowerUps.first(where: { $0.id == id }) {
            user.coins = (user.coins ?? 0) + powerUp.costOfCoins
            powerUp.isLocked = false
            let stat = getPowerUpStat(id: id)
            stat.totalTimesUsed = max(0, stat.totalTimesUsed - 1)
            powerUpsUsedForHighscore = max(0, powerUpsUsedForHighscore - 1)
            removeFromActivePowerUps(id: id)
        }
        triviaManager.resetManager()
    }

    func resetTriviaManager() {
        triviaManager.resetManager()
    }
    
    func powerUpChosen(powerUp: PowerUp) {
        guard !lockBoard, !isLoading, activeBet == nil, !powerUp.isLocked, powerUp.costOfCoins <= (user.coins ?? 0) else { return }
                
        powerUp.isLocked = true
        removeFromActivePowerUps(id: powerUp.id)
        activePowerUps.append(powerUp)
        
        if(powerUp.costOfCoins > 0) {
            user.coins = user.coins! - powerUp.costOfCoins
        }
        
        powerUpsUsedForHighscore += 1
        getPowerUpStat(id: powerUp.id).totalTimesUsed += 1

        clearActiveBets()
          
        switch powerUp.id {
          case "1": squareClicked(square: LuckySquare(id: "free pass", name: "free pass", color: .white, isDisabled: false))
          case "2": split5050()
          case "3": luckyRestart()
          case "4": twoGuesses()
          case "5":
            trivia(type: "easy")
          case "6":
            trivia(type: "med")
          case "7":
            trivia(type: "tof")
          case "9":
            trivia(type: "mania")
          case "10": resetPowerUpsButReset()
          case "11":
            trivia(type: "hard")
          case "12": adForCoins()
          default: break
        }
        
        
      }
    
    func adForContinueChance() {
        isLoading = true
        Task { @MainActor in
            await rewardViewModel.loadAd()
            rewardViewModel.showAd { reward in
                isLoading = false
                if reward > 0 {
                    howManyGuessesLeft = 1
                    enableAllSquares()
                } else {
                    // A failed or skipped ad must not grant a free continuation.
                    squareClickedIsInCorrect(chance: false)
                }
            }
        }
    }

    func adForCoins() {
        removeFromActivePowerUps(id: "12")
        isLoading = true
        Task { @MainActor in
            await rewardViewModel.loadAd()
            rewardViewModel.showAd { reward in
                isLoading = false
                user.coins = (user.coins ?? 0) + reward
                if reward == 0 {
                    powerUps.first(where: { $0.id == "12" })?.isLocked = false
                    let stat = getPowerUpStat(id: "12")
                    stat.totalTimesUsed = max(0, stat.totalTimesUsed - 1)
                    powerUpsUsedForHighscore = max(0, powerUpsUsedForHighscore - 1)
                    showBetText(text: "No ad reward received. You can try again.", colorOfText: .yellow)
                }
            }
        }
    }

    func getPowerUpStat(id:String) -> PowerUpStats {
        //if need default powerup then we can return it from mockdata powerups
        return (user.luckySquaresStats?.powerUpStats.first(where: {$0.id == id}))!
    }
    
    func trivia(type: String) {
        Task.init {
            await triviaManager.fetchTrivia(gameType: type)
        }
        showingTriviaSheet = true
    }
    
    func triviaMed() {
        showingTriviaSheet = true
    }
    
    func triviaToF() {
        showingTriviaSheet = true
    }
    
    func triviaHard() {
        showingTriviaSheet = true
    }
    
    func triviaMania() {
        showingTriviaSheet = true
    }
    
    func twoGuesses() { howManyGuessesLeft = 2 }
    
    func luckyRestart() {
        viewModel.restartKeepingScore()
        removeFromActivePowerUps(id: "2")
        removeFromActivePowerUps(id: "3")
        howManyGuessesLeft = isPowerUpActive(id: "4") ? 2 : 1
        columnCount = 2
    }
    
    func split5050() {
        viewModel.use5050()
        howManyGuessesLeft = isPowerUpActive(id: "4") ? 2 : 1
        columnCount = 2
    }
    
    func generateNextGuessedSquare() {
        let randomRange = Int.random(in: 0..<viewModel.luckySquares.count)
        nextCorrectSquare = viewModel.luckySquares[randomRange]
    }
    
    func squareClicked(square:LuckySquare) {
        guard !lockBoard, !isLoading, !showingBetPopUp, !showingPopupContinueChance else { return }
        guard isPowerUpActive(id: "1") || viewModel.luckySquares.contains(where: { $0 === square && !$0.isDisabled }) else { return }
        timesGuessed += 1
           
        //Before seeing if guess is correct
        //1. check if free pass is active
            //if so, give them a point and return
        
        //free pass is active, move on to next and thats it
        if(isPowerUpActive(id:"1")) {
            squareClickedIsCorrect()
            removeFromActivePowerUps(id:"1")
            return
        }
        
        // Only the second attempt of Two Guesses keeps the previous target.
        // Other active power-ups must not leave an old or removed target in play.
        if !isPowerUpActive(id: "4") || howManyGuessesLeft == 2 {
            generateNextGuessedSquare()
        }
        if isPowerUpActive(id: "3") {
            removeFromActivePowerUps(id: "3")
        }

        if(nextCorrectSquare.id == square.id) {
            squareClickedIsCorrect()
        } else { // incorrect guess
            if(isPowerUpActive(id:"4")) { //two guesses is active
                if(howManyGuessesLeft > 1) { //give them another chance
                    square.isDisabled = true
                } else { //last guess, remove powerUp and reset it
                    removeFromActivePowerUps(id:"4")
                    squareClickedIsInCorrect(chance: true)
                }
                howManyGuessesLeft = howManyGuessesLeft - 1
            } else { //all other cases reset everything
                squareClickedIsInCorrect(chance: true)
            }
        }
      
    }
    
    func setDisapearingText() {
      
        /*
        if(timesGuessedRight == 1 && !triedMoreThanOnce) {
            disapearingText = "Nice, Now Keep Guessing"
            resetDisapearingTextParams()
        } else if(timesGuessedWrong > 0 && !triedMoreThanOnce) {
            disapearingText = "Tough, Try Again"
            resetDisapearingTextParams()
        }
         */
        
        //other messages
        /*
         else if((getHighscoreinTimesTried() - timesGuessedRight) == 1) {
             disapearingText = "2 more guesses until new highscore!"
             resetDisapearingTextParams()
         } else if(timesGuessedRight > getHighscoreinTimesTried()) {
             disapearingText = "New Highscore!"
             resetDisapearingTextParams()
             //resetPowerUps() -- idea to reset powerUps for them
         }
         */
    }
    
    func getHighscoreinTimesTried() -> Int {
        return (user.luckySquaresStats!.highScore/50)
    }
    
    func resetDisapearingTextParams() {
        showText = true
        textOpacity = 1.0
    }
    
    func resetDisapearingBetTextParams() {
        noticeID = UUID()
        showBetText = true
        betTextOpacity = 1.0
    }
    
    func showBetText(text:String, colorOfText:Color) {
        colorOfBetText = colorOfText
        disapearingBetText = text
        resetDisapearingBetTextParams()
    }
    
    func isPowerUpActive(id:String) -> Bool {
        return activePowerUps.contains(where: {$0.id == id})
    }
    
    func removeFromActivePowerUps(id:String) {
        activePowerUps.removeAll { $0.id == id }
    }
    
    func resetActivePowerUps() {
        activePowerUps = []
    }
    
    func squareClickedIsCorrect() {
        // Trivia and Free Pass can finish a round while Two Guesses is active.
        // Do not carry its second-attempt target into the next round.
        removeFromActivePowerUps(id: "4")
        removeFromActivePowerUps(id: "2")
        viewModel.advance()
        timesGuessedRight += 1
        score = timesGuessedRight * 50
        howManyGuessesLeft = 1
        timesGuessedWrong = 0
        toggleScoreView()
        checkColumnCount()
        checkHighscore()
        showBetText(text: "Round cleared · \(score) points", colorOfText: .green)
        //checkStats()
        enableAllSquares()
        
        setDisapearingText()
        triedMoreThanOnce = true
        checkActiveBetsCorrect()
    }
    
    func clearActiveBets() {
        guard let bet = activeBet else { return }
        user.coins = (user.coins ?? 0) + bet.cancellationRefund
        user.luckySquaresStats?.coinsWagered = (user.luckySquaresStats?.coinsWagered ?? 0) + bet.stake
        user.luckySquaresStats?.coinsLost = (user.luckySquaresStats?.coinsLost ?? 0) + bet.stake - bet.cancellationRefund
        activeBet = nil
        showBetText(text: "Bet canceled: \(bet.cancellationRefund) coins returned", colorOfText: .yellow)
    }
    
    func checkActiveBetsCorrect() {
        if(currentActiveBet > 0) {
            showBetCoinViewPopUp(totalCoins: user.coins!, numOfCoins: (activeBet?.payout ?? 0), colorOfChange: .green)
            //showBetText(text: "Bet Won: +\(Int(getPayoutFromBet()))c", colorOfText:.green)
            updateBettingStatsCorrect()
            user.coins = (user.coins ?? 0) + (activeBet?.payout ?? 0)
            activeBet = nil
        }
    }
    
    func showBetCoinViewPopUp(totalCoins: Int, numOfCoins:Int,colorOfChange:Color) {
        coinTotal = totalCoins
        coinChangeColor = colorOfChange
        coinChangeNum = numOfCoins
        resetDisapearingBetCoinViewParams()
    }
    
    
    func resetDisapearingBetCoinViewParams() {
        coinPopupID = UUID()
        showBetCoinViewpopUp = true
    }
    
    func getPayoutFromBet() -> CGFloat {
        return CGFloat(activeBet?.winnings ?? 0)
    }
    
    func checkActiveBetsInCorrect() {
        if(currentActiveBet > 0) {
            showBetCoinViewPopUp(totalCoins: (user.coins ?? 0) + currentActiveBet,numOfCoins: 0-currentActiveBet, colorOfChange: .red)
            //showBetText(text: "Bet Lost: -\(currentActiveBet)c", colorOfText:.red)
            updateBettingStatsInCorrect()
            // The stake was reserved when the bet was placed.
            activeBet = nil
        }
    }
    
    func updateBettingStatsCorrect() {
        if(currentActiveBet > 0) {
            user.luckySquaresStats?.coinsWagered = (user.luckySquaresStats?.coinsWagered ?? 0) + currentActiveBet
            user.luckySquaresStats?.coinsWon = (user.luckySquaresStats?.coinsWon ?? 0) + Int(getPayoutFromBet())
        }
    }
    
    func updateBettingStatsInCorrect() {
        if(currentActiveBet > 0) {
            user.luckySquaresStats?.coinsWagered = (user.luckySquaresStats?.coinsWagered ?? 0) + currentActiveBet
            user.luckySquaresStats?.coinsLost = (user.luckySquaresStats?.coinsLost ?? 0) + currentActiveBet
        }
    }
    
    func checkStats() {
        
    }
    
    func checkColumnCount() {
        columnCount = min(4, max(2, viewModel.luckySquares.count))
    }
    
    func resetSquares() {
        viewModel.reset()
    }
    
    func enableAllSquares() {
        //set all squares to able
        viewModel.luckySquares.forEach { $0.isDisabled = false }
    }
    
    func disableAllSquares() {
        //set all squares to disable
        viewModel.luckySquares.forEach { $0.isDisabled = true }
    }
    
    func flashCorrectSquare() {
        // Set the correct square to flash
        if let correctSquare = viewModel.luckySquares.first(where: { $0.id == nextCorrectSquare.id }) {
            correctSquare.isFlashing = true
        }
    }
    
    func stopFlashingSquare() {
        if let correctSquare = viewModel.luckySquares.first(where: { $0.id == nextCorrectSquare.id }) {
            correctSquare.isFlashing = false
        }
    }
    
    func resetGameVars() {
        timesGuessedRight = 0
        timesGuessed = 0
        powerUpsUsedForHighscore = 0
        howManyGuessesLeft = 1
        columnCount = 2
        powerUpsUsedForHighscore = 0
    }
    
    func gameBoardReset() {
        lockBoard = false
        resetGameVars()
        resetSquares()
        resetPowerUps()
        resetActivePowerUps()
        enableAllSquares()
    }
    
    func squareClickedIsInCorrect(chance:Bool) {
        checkActiveBetsInCorrect()
        let randomRange = Int.random(in: 0..<20)
        if(chance && randomRange == 1) {
            showingPopupContinueChance = true
        } else {
            lockBoard = true
            disableAllSquares()
            score = 0
            toggleScoreView()
            flashCorrectSquare()
       
            // Delay the rest of the actions by 1 second so the user can see the correct circle
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                //show winning square
                stopFlashingSquare()
                //game board reset
                gameBoardReset()
                //bets
                checkActiveBetsInCorrect()
                //stats
                user.luckySquaresStats?.totalTimesPlayed = (user.luckySquaresStats?.totalTimesPlayed ?? 0) + 1
                timesGuessedWrong += 1
                if((user.luckySquaresStats?.totalTimesIncorrectInRow ?? 0) < timesGuessedWrong * 50) {
                    user.luckySquaresStats?.totalTimesIncorrectInRow = timesGuessedWrong * 50
                }
                setDisapearingText()
            }
        }
    }
    
    func squareClickedIsInCorrectDontShowCorrectSquare(chance:Bool) {
        checkActiveBetsInCorrect()
        let randomRange = Int.random(in: 0..<20)
        if(chance && randomRange == 1) {
            showingPopupContinueChance = true
        } else {
            score = 0
            toggleScoreView()
            //game board reset
            gameBoardReset()
            //bets
            checkActiveBetsInCorrect()
            //stats
            user.luckySquaresStats?.totalTimesPlayed = (user.luckySquaresStats?.totalTimesPlayed ?? 0) + 1
            timesGuessedWrong += 1
            if((user.luckySquaresStats?.totalTimesIncorrectInRow ?? 0) < timesGuessedWrong * 50) {
                user.luckySquaresStats?.totalTimesIncorrectInRow = timesGuessedWrong * 50
            }
            setDisapearingText()
        }
    }
    
    func resetPowerUps() {
        //set all powerUps to Active
        freePassPowerUp.isLocked = false
        powerUps.forEach { $0.isLocked = false }
    }
    
    func resetPowerUpsButReset() {
        //set all powerUps to Active but the reset powerups
        freePassPowerUp.isLocked = false
        powerUps.forEach {
            if($0.id != "10") {
                $0.isLocked = false
            }
        }
    }
    
    func toggleScoreView() {
        self.textSwitch.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.textSwitch.toggle()
        }
    }
    
    func checkHighscore() {
        if(score > user.luckySquaresStats?.highScore ?? 0) {
            user.luckySquaresStats?.highScore = score
            user.luckySquaresStats?.powerUpsUsedForHighscore = powerUpsUsedForHighscore
            //MARK: dont think we need this insert. swiftData auto saves pretty sure
            //context.insert(user)
        }
    }
    
}

#Preview {
    NavigationStack {
    LuckySquaresGameBoard(user: MockData.defUser, powerUps: MockData.squarePowerUps)
    }
}
