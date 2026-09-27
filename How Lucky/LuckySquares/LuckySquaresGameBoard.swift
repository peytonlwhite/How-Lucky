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
    @State private var showingPowerUpSheet = false
    @State private var showingTriviaSheet = false
    @State private var showingBetPopUp = false
    @State private var textSwitch = false
    @State private var activePowerUps: [PowerUp] = []
    
    let powerUps: [PowerUp]
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
    @State private var currentActiveBet:Int = 0
    @State private var showBetCoinViewpopUp = false
    
    @State private var coinChangeNum = 0
    @State private var coinTotal = 0
    @State private var coinChangeColor:Color = .green

    
    // MARK: - Main View
    var body: some View {
        NavigationStack {
            ZStack {
            
                if isLoading {
                    // Loading Screen
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(2)
                        Text("Loading...")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                } else {
                    FlashingView(
                        shouldTransition: $shouldTransition,
                        maxScaleEffect: maxScaleEffect,
                        minScaleEffect: minScaleEffect,
                        colors: colors,
                        colorIndex: $colorIndex,
                        animationDuration: animationDuration
                    )
                    
                    ScoreView(score: score, textSwitch: textSwitch)

                    // Centered Squares Grid
                    Group {
                        if viewModel.luckySquares.count > 20 {
                            ScrollView {
                                squaresGrid
                            }
                        } else {
                            squaresGrid
                        }
                    }
                    
                    // High Score Display
                    VStack {
                        Spacer()
                        Text("High Score: \(user.luckySquaresStats!.highScore)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                            .padding(.bottom, 20)
                    }
                    
                    // Disappearing Text for bets
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
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        showBetCoinViewpopUp = false
                                    }
                                }
                        }
                    }
                    
                    // Disappearing Text
                    if showText {
                        GeometryReader { geometry in
                            Text(disapearingText)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .multilineTextAlignment(.center) // Center text if it wraps
                                .opacity(textOpacity)
                                .frame(maxWidth: .infinity)
                                .position(
                                    x: geometry.size.width / 2, // Center horizontally
                                    y: geometry.size.height * 0.2 // 20% from the top
                                )
                                .onAppear {
                                    withAnimation(.easeOut(duration: 4)) {
                                        textOpacity = 0.0
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        showText = false
                                    }
                                }
                        }
                    }
                    
                    VStack {
                        
                    }
                    .popover(isPresented: $viewGameDirections, arrowEdge: .top) {
                        ZStack {
                            // Display the rules as Text
                            ScrollView {
                                Text(MockData.luckySquaresDescription)
                                    .font(.body)
                                    .foregroundStyle(colorScheme == .dark ? .white :  .black)
                                    .padding()
                            }
                            
                        }
                        .padding()
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
                                useOffset: true, 
                                userCoins: user.coins!,
                                bettingOnText: MockData.luckySquaresBetDescription,
                                bettingRulesText: "1. Enter the amount of coins you want to bet.\n2. Check the odds to calculate your potential winnings.\n3. If you don't have enough coins, you'll see an error.\n4. Click 'Bet' to confirm or 'Cancel' to exit.",
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
                    
                    // Popup for Continue Chance
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
            }
            .navigationTitle("Lucky Squares")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                // Left-aligned items
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("\(howManyGuessesLeft) -")
                            .font(.title3)
                            .foregroundStyle(.blue)
                        
                        Text("\(viewModel.luckySquares.count)")
                            .font(.title3)
                            .foregroundStyle(.blue)
                        
                        Button {
                            viewGameDirections = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.callout)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Right-aligned toolbar view
                ToolbarItem(placement: .navigationBarTrailing) {
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
                        mainGameType: MainGameType.squares
                    )
                }
                
           
            }
            .onAppear {
                startFlashingAnimation()
                isLoading = false
                resetPowerUps()
                resetActivePowerUps()
            }
        }
    }
    
    
    
    
    private var squaresGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(minimum: 20)), count: columnCount),
            alignment: .center,
            spacing: 10
        ) {
            ForEach(viewModel.luckySquares, id: \.self) { square in
                Button {
                    squareClicked(square: square)
                } label: {
                    LuckySquareView(square: square)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 4, x: 0, y: 2)
                }
                .disabled(square.isDisabled)
            }
        }
        .padding()
    }
    
    
}




private extension LuckySquaresGameBoard {
    
    
    var previousColor: Color { colors[colorIndex % colors.count] }
    var transitioningColor: Color { colors[(colorIndex + 1) % colors.count] }
     
    func getActiveBetCancelOrNotMessage() -> String {
        return "\(currentActiveBet) coins at \(formatOddsToFraction(getOddsForBet())) odds"
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
    
    func isBettingActive() -> Bool {
        if(isPowerUpActive(id: "4")) {
            return false
        }
        return true
    }
    
    func getOddsForBet() -> CGFloat {
        let numOfSquares = viewModel.luckySquares.count
        let odds = CGFloat(numOfSquares)-1 / CGFloat(1)
        return odds
    }
    
    func userBetCoinsAction(coins:Int) {
        currentActiveBet = coins
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
        if(isCorrect) {
            removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: true)
            timesGuessed += 1
            squareClickedIsCorrect()
        } else {
            if(isPowerUpActive(id: "9")) { // trivia mania is active so count them
                for _ in 0..<triviaManager.score {
                    getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaCorrects += 1
                    timesGuessed += 1
                    squareClickedIsCorrect()
                }
                getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaInCorrects += 1
                removeFromActivePowerUps(id:getTrivaIdBasedOnType())
            } else {
                timesGuessed += 1
                squareClickedIsInCorrectDontShowCorrectSquare(chance: true)
                removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: false)
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
    
    func resetTriviaManager() {
        triviaManager.resetManager()
    }
    
    func powerUpChosen(powerUp: PowerUp) {
                
        powerUp.isLocked = true
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
    
    func adForContinueChance()  {
        isLoading = true
        Task {
            await rewardViewModel.loadAd()
            isLoading = false
            rewardViewModel.showAd { reward in
                // do nothing let them continue
            }
         }
    }
    
    func adForCoins()  {
        removeFromActivePowerUps(id:"12")
        isLoading = true
        Task {
            await rewardViewModel.loadAd()
            isLoading = false
            rewardViewModel.showAd { reward in
                user.coins = user.coins! + reward
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
    
    func luckyRestart() { resetSquares(); columnCount = 2 }
    
    func split5050() { resetSquares(); columnCount = 2 }
    
    func generateNextGuessedSquare() {
        let randomRange = Int.random(in: 0..<viewModel.luckySquares.count)
        nextCorrectSquare = viewModel.luckySquares[randomRange]
    }
    
    func squareClicked(square:LuckySquare) {
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
        
        //50-50 is active, we don't care until one is guess correctly
        if(isPowerUpActive(id:"2") && !isPowerUpActive(id:"4")) {
            generateNextGuessedSquare()
        }
        
        //Lucky Restart is active, we don't care work is already done
        if(isPowerUpActive(id:"3")) {
            removeFromActivePowerUps(id:"3")
            generateNextGuessedSquare()
        }
        
        //Two Guesses is active only generate next guess the first try
        if(isPowerUpActive(id:"4")) {
            if(howManyGuessesLeft == 2) { //this is the first guess
                generateNextGuessedSquare()
            } else {
                //already guessed twice
            }
        }
        
        
        if(activePowerUps.isEmpty) { //continue as normal
            generateNextGuessedSquare()
        }

        //last check just in case
        if(nextCorrectSquare.id == "99") {
            generateNextGuessedSquare()
        }
        
        if(nextCorrectSquare.id == square.id) {
            //50-50 is active, refill squares and remove it
            if(isPowerUpActive(id:"2")) {
                resetSquares()
                for count in 0..<timesGuessedRight {
                    checkColumnCount()
                    viewModel.luckySquares.append(LuckySquare(id: UUID().uuidString, name: "\(count+3)", color: .red, isDisabled: false))
                }
                removeFromActivePowerUps(id:"2")
            }
            
            
            //Two Guesses is active reset it and remove it
            if(isPowerUpActive(id:"4")) {
                removeFromActivePowerUps(id:"4")
            }
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
        if let index = activePowerUps.enumerated().first(where: {$0.element.id == id}) {
           // do something with foo.offset and foo.element
            activePowerUps.remove(at: index.offset)
        } else {
           // item could not be found
        }
    }
    
    func resetActivePowerUps() {
        activePowerUps = []
    }
    
    func squareClickedIsCorrect() {
        let numOfSquares = viewModel.luckySquares.count
        timesGuessedRight += 1
        score = timesGuessed * 50
        howManyGuessesLeft = 1
        timesGuessedWrong = 0
        toggleScoreView()
        checkColumnCount()
        checkHighscore()
        //checkStats()
        enableAllSquares()
        
        setDisapearingText()
        triedMoreThanOnce = true
        checkActiveBetsCorrect()
        viewModel.luckySquares.append(LuckySquare(id: UUID().uuidString, name: "\(numOfSquares+1)", color: .red, isDisabled: false))
    }
    
    func clearActiveBets() {
        if(currentActiveBet > 0) {
            showBetText(text: "Bet Cleared", colorOfText:.yellow)
        }
        currentActiveBet = 0
    }
    
    func checkActiveBetsCorrect() {
        if(currentActiveBet > 0) {
            showBetCoinViewPopUp(totalCoins: user.coins!, numOfCoins: (Int(getPayoutFromBet())), colorOfChange: .green)
            //showBetText(text: "Bet Won: +\(Int(getPayoutFromBet()))c", colorOfText:.green)
            updateBettingStatsCorrect()
            user.coins = user.coins! + Int(getPayoutFromBet())
            currentActiveBet = 0
        }
    }
    
    func showBetCoinViewPopUp(totalCoins: Int, numOfCoins:Int,colorOfChange:Color) {
        coinTotal = totalCoins
        coinChangeColor = colorOfChange
        coinChangeNum = numOfCoins
        resetDisapearingBetCoinViewParams()
    }
    
    
    func resetDisapearingBetCoinViewParams() {
        showBetCoinViewpopUp = true
    }
    
    func getPayoutFromBet() -> CGFloat {
        return CGFloat(currentActiveBet) * getOddsForBet()
    }
    
    func checkActiveBetsInCorrect() {
        if(currentActiveBet > 0) {
            showBetCoinViewPopUp(totalCoins: user.coins!,numOfCoins: 0-currentActiveBet, colorOfChange: .red)
            //showBetText(text: "Bet Lost: -\(currentActiveBet)c", colorOfText:.red)
            updateBettingStatsInCorrect()
            user.coins = user.coins! - currentActiveBet
            currentActiveBet = 0
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
        if(columnCount > 3) {
            
        } else {
            columnCount = viewModel.luckySquares.count+1
        }
    }
    
    func resetSquares() {
        viewModel.luckySquares = [
                LuckySquare(id: UUID().uuidString, name: "1", color: .red, isDisabled: false),
                LuckySquare(id: UUID().uuidString, name: "2", color: .red, isDisabled: false)
            ]
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
        resetGameVars()
        resetSquares()
        resetPowerUps()
        resetActivePowerUps()
        enableAllSquares()
    }
    
    func squareClickedIsInCorrect(chance:Bool) {
        let randomRange = Int.random(in: 0..<20)
        if(chance && randomRange == 1) {
            showingPopupContinueChance = true
        } else {
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
    LuckySquaresGameBoard(user: MockData.defUser, powerUps: MockData.squarePowerUps)
}
