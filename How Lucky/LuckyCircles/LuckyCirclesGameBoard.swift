//
//  LuckyCirclesGameBoard.swift
//  How Lucky
//
//  Created by Peyton White on 11/7/24.
//

import SwiftUI

struct LuckyCirclesGameBoard: View {
    
    // MARK: - User Info
    @Bindable var user: User
    @Environment(\.modelContext) var context
    
    // MARK: - ViewModel and Managers
    @StateObject var viewModel = LuckyCircleGameBoardViewModel()
    @StateObject var triviaManager = TriviaManager()
    
    // MARK: - PowerUp Info
    @State var powerUps: [PowerUp]
    @State private var freePassPowerUp: PowerUp = MockData.freePassPowerUp
    @State private var activePowerUps: [PowerUp] = []
    
    // MARK: - Guessing Related
    @State private var timesGuessedRight: Int = 0
    @State private var howManyGuessesToStart: Int = 6
    @State private var howManyGuessesLeft: Int = 0
    @State private var numOfCirclesInQuadrant: Int = 0
    @State private var timesGuessedWrong: Int = 0
    @State private var timesGuessed: Int = 0
    
    // MARK: - Sheets Info
    @State private var showingPowerUpSheet = false
    @State private var showingTriviaSheet = false
    @State private var viewGameDirections = false
    
    // MARK: - Score Game Related
    @State private var textSwitch = false
    @State private var score: Int = 0
    @State private var powerUpsUsedForCurrentScore: Int = 0
    @State private var nextCorrectCircle: LuckyCircle = LuckyCircle(
        id: "unselected", name: "Empty", color: .red, isDisabled: false, size: 50.0,
        position: CGPoint(x: 50, y: 100)
    )
    
    // MARK: - Screen and Animation Related
    @State private var screenSize: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height
    )
    @State private var colors: [Color] = [.white, .blue]
    private let maxScaleEffect: CGFloat = 4.0
    private let minScaleEffect: CGFloat = 0
    private let animationDuration = 1.2
    private let animationDelay = 0.1
    @State private var shouldTransition = true
    @State private var lockBoard = false
    @State private var colorIndex = 0
    
    @Environment(\.colorScheme) var colorScheme
    
    
    // MARK: - Quadrant Related
    @State private var targetQuadrant: Quadrant = .none
    enum Quadrant {
        case topLeft, topRight, bottomLeft, bottomRight, none
    }
    
    
    //MARK: - ad properties
    @StateObject var rewardViewModel = RewardedViewModel()
    
    @State private var hasStarted = false
    @State private var isLoading = true
    
    @State private var showText = true
    @State private var triedMoreThanOnce = false
    @State private var textOpacity = 1.0
    @State private var disapearingText = ""
    
    
    //MARK: - bet properties
    @State private var activeBet: CoinBet?
    private var currentActiveBet: Int { activeBet?.stake ?? 0 }
    @State private var quadGeoSize:CGSize = .zero
    @State private var showBetCoinViewpopUp = false
    @State private var showCircleChangeViewpopUp = false
    @State private var circlePopupID = UUID()
    @State private var circleTotal = 0
    @State private var circleChangeNum = 0
    @State private var circleChangeColor: Color = .purple
    @State private var showingBetPopUp = false
    
    @State private var coinPopupID = UUID()
    @State private var coinChangeNum = 0
    @State private var coinTotal = 0
    @State private var coinChangeColor:Color = .green
    
    //bet text props
    @State private var showBetText = true
    @State private var colorOfBetText:Color = .yellow
    @State private var betTextOpacity = 1.0
    @State private var disapearingBetText = ""
    
    
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var noticeID = UUID()

    var body: some View {
        ZStack {
            GamePalette.canvas.ignoresSafeArea()
            GeometryReader { layout in
            VStack(spacing: 12) {
                GameDashboard(score: score, best: user.luckyCirclesStats?.highScore ?? 0,
                              guesses: howManyGuessesLeft, pieces: viewModel.luckyCircles.count,
                              pieceName: "circles", coins: user.coins ?? 0, accent: GamePalette.circles, compact: layout.size.height < 480)
                HStack {
                    Text("Find the lucky circle").font(.headline)
                    Spacer()
                    if activeBet != nil {
                        Label("Bet active", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.semibold)).foregroundStyle(GamePalette.circles)
                    }
                }.padding(.horizontal, 4)
                gameBoard
                    .disabled(isLoading || lockBoard || showingBetPopUp)
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
                                    cancelBet()
                                } else {
                                    //do nothing
                                    showingBetPopUp = false
                                }
                            }
                        } else {
                            BetPopUpView(
                                useOffset: false,
                                userCoins: user.coins!,
                                bettingOnText: MockData.luckyCirclesBetDescription,
                                bettingRulesText: "1. Enter the amount of coins you want to bet.\n2. Check the odds to calculate your potential winnings.\n3. If you don't have enough coins, you'll see an error.\n4. Your stake is deducted when you place the bet. A win returns your stake plus whole-coin winnings. Canceling returns one third of the stake. Leaving an unfinished game forfeits the stake.",
                                cancelButtonText: "Cancel",
                                titleText:"Win Some Coins!",
                                isActive: $showingBetPopUp, odds: CGFloat(getOddsForBet())
                            ) { toBet,coins  in
                                if toBet {
                                    userBetCoinsAction(coins:Int(coins!))
                                    showBetText(text: "Bet Placed", colorOfText: .yellow)
                                } else {
                                    showingBetPopUp = false
                                }
                            }

                        }
                    }


        }
        .navigationTitle("Lucky Circles")
        .navigationBarTitleDisplayMode(.inline)
        .tint(GamePalette.circles)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { viewGameDirections = true } label: { Image(systemName: "questionmark.circle") }
                    .accessibilityLabel("How to play Lucky Circles")
                    .disabled(isLoading || showingBetPopUp)
            }
        }
        .sheet(isPresented: $viewGameDirections) {
            GameRulesSheet(title: "How to play", rules: MockData.luckyCirclesDescription)
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
                            showBets: true,
                            user: user,
                            mainGameType: MainGameType.circles,
                            hasActiveBet: activeBet != nil,
                            triviaCancelled: triviaCancelled
                        )
                .disabled(isLoading || lockBoard || showingBetPopUp)
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
            howManyGuessesLeft = howManyGuessesToStart
            generateNextGuessedCircle()
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
            } else if showCircleChangeViewpopUp {
                GameNotice(text: "\(-circleChangeNum) circles removed · \(viewModel.luckyCircles.count) remaining",
                           symbol: "circle.dotted", tint: GamePalette.circles)
                    .id(circlePopupID)
                    .task {
                        do { try await Task.sleep(for: .seconds(3)) } catch { return }
                        showCircleChangeViewpopUp = false
                    }
            } else if showBetText && !disapearingBetText.isEmpty {
                GameNotice(text: disapearingBetText, symbol: "info.circle", tint: GamePalette.circles)
                    .id(noticeID)
                    .task {
                        do { try await Task.sleep(for: .seconds(3)) } catch { return }
                        showBetText = false
                    }
            } else {
                GameNotice(text: lockBoard ? "The winning circle is revealed. Next round coming up…" : "Use power-ups to narrow the field.",
                           symbol: lockBoard ? "eye" : "hand.tap", tint: .secondary)
            }
        }
    }

    private var gameBoard: some View {
        GeometryReader { geometry in
            ZStack {
                GamePalette.surface
                ForEach(viewModel.luckyCircles) { circle in
                    LuckyCircleView(circle: circle, isCorrect: lockBoard && circle.id == nextCorrectCircle.id) {
                        circleClicked(circle: circle)
                    }
                }
                flashQuadrantBorder(in: geometry.size).allowsHitTesting(false)
            }
            .onChange(of: geometry.size, initial: true) { _, size in updateBoardBounds(size) }
        }
        .padding(12)
        .background(GamePalette.surface, in: RoundedRectangle(cornerRadius: 24))
        .overlay { RoundedRectangle(cornerRadius: 24).strokeBorder(GamePalette.circles.opacity(0.18), lineWidth: 1) }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension LuckyCirclesGameBoard {
    
    func resetDisapearingTextParams() {
        showText = true
        textOpacity = 1.0
    }
    
    func getHighscoreinTimesTried() -> Int {
        return (user.luckySquaresStats!.highScore/50)
    }
    
    func setDisapearingText() {
        
        //other messages
        /*
         if(timesGuessedRight == 1 && !triedMoreThanOnce) {
         disapearingText = "Nice, Now Keep Guessing"
         resetDisapearingTextParams()
         } else if(timesGuessedWrong > 0 && !triedMoreThanOnce) {
         disapearingText = "Tough, Try Again"
         resetDisapearingTextParams()
         }
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
    
    func showBetText(text:String, colorOfText:Color) {
        colorOfBetText = colorOfText
        disapearingBetText = text
        resetDisapearingBetTextParams()
    }
    
    
    func resetDisapearingBetTextParams() {
        noticeID = UUID()
        showBetText = true
        betTextOpacity = 1.0
    }
    
    func cancelBet() {
        clearActiveBets()
    }
    
    func clearActiveBets() {
        guard let bet = activeBet else { return }
        user.coins = (user.coins ?? 0) + bet.cancellationRefund
        user.luckyCirclesStats?.coinsWagered = (user.luckyCirclesStats?.coinsWagered ?? 0) + bet.stake
        user.luckyCirclesStats?.coinsLost = (user.luckyCirclesStats?.coinsLost ?? 0) + bet.stake - bet.cancellationRefund
        activeBet = nil
        showBetText(text: "Bet canceled: \(bet.cancellationRefund) coins returned", colorOfText: .yellow)
    }
    
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
    
    func hasCurrentBet() -> Bool {
        if(currentActiveBet > 0) {
            return true
        }
        return false
    }
    
    // Function to determine the number of circles in a specific quadrant
    func circlesInQuadrant(for quadrant: Quadrant, in size: CGSize, circles: [CGPoint]) -> Int {
        guard quadrant != .none else { return 0 }
        return circles.filter { determineQuadrant(for: $0, in: size) == quadrant }.count
    }
    
    // Function to extract all circle positions as an array of CGPoint
    func getAllCirclePositions() -> [CGPoint] {
        return viewModel.luckyCircles.map { $0.position }
    }
    
    
    func getOddsForBet() -> CGFloat {
        let choices = isPowerUpActive(id: "9")
            ? circlesInQuadrant(for: targetQuadrant, in: screenSize, circles: getAllCirclePositions())
            : viewModel.luckyCircles.count
        return CGFloat(CoinBet.odds(choices: choices, guesses: howManyGuessesLeft))
    }
    
    func userBetCoinsAction(coins:Int) {
        guard activeBet == nil,
              let bet = CoinBet(stake: coins, balance: user.coins ?? 0, odds: Double(getOddsForBet())) else { return }
        user.coins = (user.coins ?? 0) - bet.stake
        activeBet = bet
    }
    
    // Flash the border of the correct quadrant
    func flashQuadrantBorder(in size: CGSize) -> some View {
        let midX = size.width / 2
        let midY = size.height / 2
        
        let flashColor: Color = .red
        let borderWidth: CGFloat = 5
        
        var borderFrame: CGRect
        
        switch targetQuadrant {
        case .topLeft:
            borderFrame = CGRect(x: 0, y: 0, width: midX, height: midY)
        case .topRight:
            borderFrame = CGRect(x: midX, y: 0, width: midX, height: midY)
        case .bottomLeft:
            borderFrame = CGRect(x: 0, y: midY, width: midX, height: midY)
        case .bottomRight:
            borderFrame = CGRect(x: midX, y: midY, width: midX, height: midY)
        case .none:
            borderFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        return Rectangle()
            .stroke(flashColor, lineWidth: borderWidth)
            .frame(width: borderFrame.width, height: borderFrame.height)
            .position(x: borderFrame.midX, y: borderFrame.midY)
                            .allowsHitTesting(false)
            .animation(.easeInOut(duration: 1), value: targetQuadrant)
    }
    
    // Determine which quadrant the target circle is in
    func determineQuadrant(for position: CGPoint, in size: CGSize) -> Quadrant {
      
        let midX = size.width / 2
        let midY = size.height / 2
        
        if position.x < midX && position.y < midY {
            return .topLeft
        } else if position.x >= midX && position.y < midY {
            return .topRight
        } else if position.x < midX && position.y >= midY {
            return .bottomLeft
        } else {
            return .bottomRight
        }
    }
    
    // Get the frame for a given quadrant
    func quadrantFrame(in size: CGSize, quadrant: Quadrant) -> CGRect {
        let midX = size.width / 2
        let midY = size.height / 2
        

        switch quadrant {
        case .topLeft:
            return CGRect(x: 0, y: 0, width: midX, height: midY)
        case .topRight:
            return CGRect(x: midX, y: 0, width: midX, height: midY)
        case .bottomLeft:
            return CGRect(x: 0, y: midY, width: midX, height: midY)
        case .bottomRight:
            return CGRect(x: midX, y: midY, width: midX, height: midY)
        case .none:
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
    }
    
    private var previousColor: Color {
        colors[colorIndex%colors.count]
    }
    
    private var transitioningColor: Color {
        colors[(colorIndex+1)%colors.count]
    }
    
    func removeHalfOfTheCircles() {
        let before = viewModel.luckyCircles.count
        let removed = viewModel.cutInHalf(preserving: nextCorrectCircle.id)
        showCirclesChangeViewPopUp(totalCircles: before, numOfCircles: -removed, colorOfChange: .purple)
    }
    
    func removeAmountFromCirclesIfNotHalf(amount:Int) {
        let before = viewModel.luckyCircles.count
        let removed = viewModel.removeIncorrectCircles(upTo: amount, preserving: nextCorrectCircle.id)
        if removed > 0 {
            showCirclesChangeViewPopUp(totalCircles: before, numOfCircles: -removed, colorOfChange: .purple)
        }
    }
    
    func triviaDone(isCorrect:Bool) {
        if triviaManager.triviaType == "Mania" {
            let stat = getPowerUpStat(id: "5")
            stat.totalTriviaCorrects += triviaManager.score
            if !isCorrect { stat.totalTriviaInCorrects += 1 }
            removeAmountFromCirclesIfNotHalf(amount: triviaManager.score * 5)
            removeFromActivePowerUps(id: "5")
        } else {
            if isCorrect {
                let amount = triviaManager.triviaType == "Easy" ? 20 : triviaManager.triviaType == "Medium" ? 40 : 60
                removeAmountFromCirclesIfNotHalf(amount: amount)
            }
            removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: isCorrect)
        }
        resetTriviaManager()
    }
    
    func removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: Bool) {
        if(isCorrect) {
            getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaCorrects += 1
        } else {
            getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaInCorrects += 1
        }
        removeFromActivePowerUps(id:getTrivaIdBasedOnType())
    }
    
    
    func getTrivaIdBasedOnType() -> String {
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
    
    func isPowerUpActive(id:String) -> Bool {
        return activePowerUps.contains(where: {$0.id == id})
    }
    
    func triviaCancelled() {
        let id = getTrivaIdBasedOnType()
        if let powerUp = activePowerUps.first(where: { $0.id == id }) {
            user.coins = (user.coins ?? 0) + powerUp.costOfCoins
            powerUp.isLocked = false
            let stat = getPowerUpStat(id: id)
            stat.totalTimesUsed = max(0, stat.totalTimesUsed - 1)
            powerUpsUsedForCurrentScore = max(0, powerUpsUsedForCurrentScore - 1)
            removeFromActivePowerUps(id: id)
        }
        triviaManager.resetManager()
    }

    func resetTriviaManager() {
        triviaManager.resetManager()
    }
    
    
    func twoGuesses() {
        howManyGuessesLeft += 2
    }
    
    func getPowerUpStat(id:String) -> PowerUpStats {
        //if need default powerup then we can return it from mockdata powerups
        return (user.luckyCirclesStats?.powerUpStats.first(where: {$0.id == id}))!
    }
    
    
    func powerUpChosen(powerUp: PowerUp) {
        guard !lockBoard, !isLoading, activeBet == nil, !powerUp.isLocked, powerUp.costOfCoins <= (user.coins ?? 0) else { return }
        
        let colorsNeeded = powerUp.id == "3" ? 1 : powerUp.id == "10" ? 2 : powerUp.id == "11" ? 3 : 0
        if colorsNeeded > viewModel.removableColors(preserving: nextCorrectCircle.id).count {
            showBetText(text: "Not enough removable colors. Power-up kept; no coins charged.", colorOfText: .yellow)
            return
        }
        if powerUp.id == "2" && viewModel.luckyCircles.count < 2 {
            showBetText(text: "Only the winning circle remains. Power-up kept.", colorOfText: .yellow)
            return
        }

        powerUp.isLocked = true
        activePowerUps.append(powerUp)
        
        getPowerUpStat(id: powerUp.id).totalTimesUsed += 1
        powerUpsUsedForCurrentScore += 1
        
        if(powerUp.costOfCoins > 0) {
            user.coins = user.coins! - powerUp.costOfCoins
        }
        
        switch powerUp.id {
        case "1"://free pass
            clearActiveBets()
            circleClicked(circle: LuckyCircle(id: "free pass", name: "free pass", color: .white, isDisabled: false, size: 0.0,position: CGPoint(x: 5, y: 5)))
        case "2": removeHalfOfTheCircles()
        case "3", "10", "11":
            let count = powerUp.id == "3" ? 1 : powerUp.id == "10" ? 2 : 3
            let before = viewModel.luckyCircles.count
            let removed = viewModel.removeColors(count: count, preserving: nextCorrectCircle.id)
            showCirclesChangeViewPopUp(totalCircles: before, numOfCircles: -removed, colorOfChange: .purple)
        case "4"://Two guesses
            twoGuesses()
        case "5"://Trivia mania
            trivia(type:"mania")
        case "6"://Triva Easy
            trivia(type:"easy")
        case "7"://Triva Med
            trivia(type:"med")
        case "8"://Triva Hard
            trivia(type:"hard")
        case "9"://which quadrant
            //clear the bets because now the odds are different
            clearActiveBets()
            
            //not a circle yet
            if(nextCorrectCircle.id == "unselected") {
                generateNextGuessedCircle()
            }
           
            // Determine the quadrant for the target circle
            targetQuadrant = determineQuadrant(for: nextCorrectCircle.position, in: screenSize)
            
        case "12": adForCoins()
        default:
            print("default")
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
                    powerUpsUsedForCurrentScore = max(0, powerUpsUsedForCurrentScore - 1)
                    showBetText(text: "No ad reward received. You can try again.", colorOfText: .yellow)
                }
            }
        }
    }

    func circleClicked(circle:LuckyCircle) {
        guard !lockBoard, !isLoading, !showingBetPopUp else { return }
        guard isPowerUpActive(id: "1") || viewModel.luckyCircles.contains(where: { $0 === circle && !$0.isDisabled }) else { return }
        timesGuessed += 1
        
        //Before seeing if guess is correct
        //1. check if free pass is active
        //if so, give them a point and return
        
        //free pass is active, move on to next and thats it
        if(isPowerUpActive(id:"1")) {
            circleClickedIsCorrect()
            removeFromActivePowerUps(id:"1")
            return
        }
        
        
        //not a correct circle yet
        if(nextCorrectCircle.id == "unselected") {
            generateNextGuessedCircle()
        }
        
        
        if(nextCorrectCircle.id == circle.id) {
            circleClickedIsCorrect()
        } else { // incorrect guess
            if(howManyGuessesLeft < 2) {
                circleClickedIsInCorrect()
            } else {
                //another chance
                howManyGuessesLeft = howManyGuessesLeft - 1
                circle.isDisabled = true
                removeCircleFromCircles(id:circle.id)
            }
        }
    }
    
    func removeCircleFromCircles(id:String) {
        if let index = viewModel.luckyCircles.enumerated().first(where: {$0.element.id == id}) {
            // do something with foo.offset and foo.element
            viewModel.luckyCircles.remove(at: index.offset)
        } else {
            // circle could not be found
        }
    }
    
    func updateBoardBounds(_ bounds: CGSize) {
        guard bounds.width > 0, bounds.height > 0 else { return }
        viewModel.updateBounds(bounds)
        screenSize = bounds
        quadGeoSize = bounds
        if isPowerUpActive(id: "9") {
            targetQuadrant = determineQuadrant(for: nextCorrectCircle.position, in: bounds)
        }
    }

    func resetCircles() {
        viewModel.resetCircles()
        lockBoard = false
    }
    
    func circleClickedIsCorrect() {
        checkActiveBetsCorrect()

        timesGuessedRight += 1
        score = timesGuessedRight * 50
        howManyGuessesLeft = howManyGuessesToStart
        timesGuessedWrong = 0
        toggleScoreView()
        checkHighscore()
        showBetText(text: "Round cleared · \(score) points", colorOfText: .green)
        enableAllCircles()
        resetPowerUps()
        resetCircles()
        resetActivePowerUps()
        generateNextGuessedCircle()
        targetQuadrant = .none
        quadGeoSize = .zero
        
        
        setDisapearingText()
        triedMoreThanOnce = true
    }
    
    func enableAllCircles() {
        //set all squares to able
        viewModel.luckyCircles.forEach { $0.isDisabled = false }
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
    
    func resetDisapearingBetCoinViewParams() {
        coinPopupID = UUID()
        showBetCoinViewpopUp = true
    }
    
    func resetDisapearingCirclesChangeViewParams() {
        circlePopupID = UUID()
        showCircleChangeViewpopUp = true
    }
    
    func getPayoutFromBet() -> CGFloat {
        return CGFloat(activeBet?.winnings ?? 0)
    }
    
    
    func updateBettingStatsCorrect() {
        if(currentActiveBet > 0) {
            user.luckyCirclesStats?.coinsWagered = (user.luckyCirclesStats?.coinsWagered ?? 0) + currentActiveBet
            user.luckyCirclesStats?.coinsWon = (user.luckyCirclesStats?.coinsWon ?? 0) + Int(getPayoutFromBet())
        }
    }
    
    func showBetCoinViewPopUp(totalCoins: Int, numOfCoins:Int,colorOfChange:Color) {
        coinTotal = totalCoins
        coinChangeColor = colorOfChange
        coinChangeNum = numOfCoins
        resetDisapearingBetCoinViewParams()
    }
    
    func showCirclesChangeViewPopUp(totalCircles: Int, numOfCircles:Int, colorOfChange:Color) {
        circleTotal = totalCircles
        circleChangeColor = colorOfChange
        circleChangeNum = numOfCircles
        resetDisapearingCirclesChangeViewParams()
    }
    
    func flashCorrectCircle() {
        // Remove all circles except for the correct one
        viewModel.luckyCircles = viewModel.luckyCircles.filter { $0.id == nextCorrectCircle.id }
    }
    
    func circleClickedIsInCorrect() {
        // Show the correct circle for 1 second before proceeding with the rest of the logic
        lockBoard = true
        checkActiveBetsInCorrect()
        flashCorrectCircle()
        
        // Delay the rest of the actions by 1 second so the user can see the correct circle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Rest of the logic will run after the 1-second delay
            timesGuessedRight = 0
            timesGuessed = 0
            score = 0
            powerUpsUsedForCurrentScore = 0
            howManyGuessesLeft = howManyGuessesToStart
            resetCircles()
            resetPowerUps()
            resetActivePowerUps()
            toggleScoreView()
            generateNextGuessedCircle()
            targetQuadrant = .none
            quadGeoSize = .zero
            
            checkActiveBetsInCorrect()
            
            // Stats updates
            user.luckyCirclesStats?.totalTimesPlayed = (user.luckyCirclesStats?.totalTimesPlayed ?? 0) + 1
            timesGuessedWrong += 1
            
            if((user.luckyCirclesStats?.totalTimesIncorrectInRow ?? 0) < timesGuessedWrong * 50) {
                user.luckyCirclesStats?.totalTimesIncorrectInRow = timesGuessedWrong * 50
            }
            setDisapearingText()
        }
    }

    
    func updateBettingStatsInCorrect() {
        if(currentActiveBet > 0) {
            user.luckyCirclesStats?.coinsWagered = (user.luckyCirclesStats?.coinsWagered ?? 0) + currentActiveBet
            user.luckyCirclesStats?.coinsLost = (user.luckyCirclesStats?.coinsLost ?? 0) + currentActiveBet
        }
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
    
    func toggleScoreView() {
        self.textSwitch.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.textSwitch.toggle()
        }
    }
    
    func checkHighscore() {
        if(score > user.luckyCirclesStats?.highScore ?? 0) {
            user.luckyCirclesStats?.highScore = score
            user.luckyCirclesStats?.powerUpsUsedForHighscore = powerUpsUsedForCurrentScore
            context.insert(user)
        }
    }
    
    func resetActivePowerUps() {
        activePowerUps = []
    }
    
    func resetPowerUps() {
        //set all powerUps to Active
        freePassPowerUp.isLocked = false
        powerUps.forEach { $0.isLocked = false }
    }
    
    func generateNextGuessedCircle() {
        let randomRange = Int.random(in: 0..<viewModel.luckyCircles.count)
        nextCorrectCircle = viewModel.luckyCircles[randomRange]
    }
    
     
    func removeFromActivePowerUps(id:String) {
        activePowerUps.removeAll { $0.id == id }
    }
     
    func trivia(type:String) {
        Task.init {
            await triviaManager.fetchTrivia(gameType: type)
        }
        showingTriviaSheet = true
    }
    
    
}

extension Color {
    static var random: Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

#Preview {
    NavigationStack {
    LuckyCirclesGameBoard(user: MockData.defUser, powerUps: MockData.circlePowerUps)
    }
}
