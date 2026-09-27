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
    let powerUps: [PowerUp]
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
        id: "99", name: "Empty", color: .red, isDisabled: false, size: 50.0,
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
    
    @State private var isLoading = true
    
    @State private var showText = true
    @State private var triedMoreThanOnce = false
    @State private var textOpacity = 1.0
    @State private var disapearingText = ""
    
    
    //MARK: - bet properties
    @State private var currentActiveBet:Int = 0
    @State private var quadGeoSize:CGSize = .zero
    @State private var showBetCoinViewpopUp = false
    @State private var showCircleChangeViewpopUp = false
    @State private var showingBetPopUp = false
    
    @State private var coinChangeNum = 0
    @State private var coinTotal = 0
    @State private var coinChangeColor:Color = .green
    
    //bet text props
    @State private var showBetText = true
    @State private var colorOfBetText:Color = .yellow
    @State private var betTextOpacity = 1.0
    @State private var disapearingBetText = ""
    
    
    
    // MARK: - Main View
    var body: some View {
        NavigationStack {
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
                GeometryReader { geometry in
                    ZStack {
                        FlashingView(
                            shouldTransition: $shouldTransition,
                            maxScaleEffect: maxScaleEffect,
                            minScaleEffect: minScaleEffect,
                            colors: colors,
                            colorIndex: $colorIndex,
                            animationDuration: animationDuration
                        )
                        
                        ScoreView(score: score, textSwitch: textSwitch)
                        
                        ForEach(Array(viewModel.luckyCircles.enumerated()), id: \.offset) { index, circle in
                            LuckyCircleView(circle: circle, isCorrect: circle.id == nextCorrectCircle.id) {
                                if !lockBoard {
                                    circleClicked(circle: circle)
                                }
                            }
                        }
                        
                        
                        flashQuadrantBorder(in: geometry.size)
                            .onAppear() {
                                if(quadGeoSize.equalTo(.zero)) {
                                    quadGeoSize = geometry.size
                                }
                            }
                          
                    }
                    
                    
                    // Disappearing Text for bets
                    if showBetText {
                        GeometryReader { geometry in
                            Text(disapearingBetText)
                                .font(.title2)
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
                            CoinsView(userCoins: coinTotal, coinChange: coinChangeNum, coinChangeColor: coinChangeColor,icon:"c.circle",
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
                    
                    if showCircleChangeViewpopUp {
                        GeometryReader { geometry in
                            CoinsView(userCoins: coinTotal, coinChange: coinChangeNum, coinChangeColor: coinChangeColor, icon:"circlebadge.fill",
                                 changePopUpText: "Circles")
                                .position(
                                    x: geometry.size.width / 2, // Center horizontally
                                    y: geometry.size.height * 0.2 // 20% from the top
                                )
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        showCircleChangeViewpopUp = false
                                    }
                                }
                        }
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
                                useOffset: true,
                                userCoins: user.coins!,
                                bettingOnText: MockData.luckyCirclesBetDescription,
                                bettingRulesText: "1. Enter the amount of coins you want to bet.\n2. Check the odds to calculate your potential winnings.\n3. If you don't have enough coins, you'll see an error.\n4. Click 'Bet' to confirm or 'Cancel' to exit.",
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
                        
                    VStack {
                        
                    }
                    .popover(isPresented: $viewGameDirections, arrowEdge: .top) {
                        ZStack {
                            // Display the rules as Text
                            ScrollView {
                                Text(MockData.luckyCirclesDescription)
                                    .font(.body)
                                    .foregroundStyle(colorScheme == .dark ? .white :  .black)
                                    .padding()
                            }
                            
                        }
                        .padding()
                    }
                    .onAppear {
                        screenSize = geometry.size
                    }
                    
                    // Disappearing Text at Mid-Top and Centered
                    if showText {
                        GeometryReader { geometry in
                            Text(disapearingText)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
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
                    
                }
                .navigationTitle("Lucky Circles")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Left-aligned items
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Text("\(howManyGuessesLeft) -")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            
                            Text("\(viewModel.luckyCircles.count)")
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
                            showBets: true,
                            user: user,
                            mainGameType: MainGameType.circles
                        )
                    }
                }
            }
            
            
        }
        .onAppear {
            startFlashingAnimation()
            isLoading = false
            howManyGuessesLeft = howManyGuessesToStart
            resetPowerUps()
            resetActivePowerUps()
            generateNextGuessedCircle()
        }
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
        showBetText = true
        betTextOpacity = 1.0
    }
    
    func cancelBet() {
        showBetCoinViewPopUp(totalCoins: user.coins!, numOfCoins: 0-(Int(currentActiveBet/3)), colorOfChange: .red)
        user.coins =  user.coins! - Int(currentActiveBet/3)
        clearActiveBets()
    }
    
    func clearActiveBets() {
        if(currentActiveBet > 0) {
            showBetText(text: "Bet Cleared", colorOfText:.yellow)
        }
        currentActiveBet = 0
    }
    
    func getActiveBetCancelOrNotMessage() -> String {
        return "\(currentActiveBet) coins at \(formatOddsToFraction(getOddsForBet())) odds. \n\n *If you cancel your bet you get \(Int(currentActiveBet/3)) coins back"
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
    
    func hasCurrentBet() -> Bool {
        if(currentActiveBet > 0) {
            return true
        }
        return false
    }
    
    // Function to determine the number of circles in a specific quadrant
    func circlesInQuadrant(for quadrant: Quadrant, in size: CGSize, circles: [CGPoint]) -> Int {
        let frame = quadrantFrame(in: size, quadrant: quadrant) // Get the frame for the quadrant

        return circles.filter { frame.contains($0) }.count // Count circles that fall within the frame
    }
    
    // Function to extract all circle positions as an array of CGPoint
    func getAllCirclePositions() -> [CGPoint] {
        return viewModel.luckyCircles.map { $0.position }
    }
    
    
    func getOddsForBet() -> CGFloat {
        var numOfCircles = viewModel.luckyCircles.count
        
        // Quadrant is active, so adjust the number of circles accordingly
        if isPowerUpActive(id: "9") {
            numOfCircles = circlesInQuadrant(for: targetQuadrant, in: screenSize, circles: getAllCirclePositions())
        }
        
        let guesses = max(howManyGuessesLeft, 1) // Ensure at least 1 guess to avoid division by zero
        
        // Calculate the true odds using cumulative probability
        let probabilityOfMissingAll = pow(CGFloat(numOfCircles - 1) / CGFloat(numOfCircles), CGFloat(guesses))
        
        let trueOdds = 1 / (1 - probabilityOfMissingAll)
        let roundedOdds = max(1, Int(ceil(trueOdds)))

        return CGFloat(roundedOdds)// Ensure odds never go below 1
    }
    
    func userBetCoinsAction(coins:Int) {
        currentActiveBet = coins
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
        // Get all circles except the correct one
        let removableCircles = viewModel.luckyCircles.filter { $0.id != nextCorrectCircle.id }

        // Ensure there are circles to remove
        guard !removableCircles.isEmpty else { return }

        // Calculate the number of circles to remove (half of the list)
        let halfCount = removableCircles.count / 2
        let initialCount = viewModel.luckyCircles.count

        // Remove the first `halfCount` circles from the list
        viewModel.luckyCircles.removeAll { circle in
            removableCircles.prefix(halfCount).contains(where: { $0.id == circle.id })
        }
        let removedCount = initialCount - viewModel.luckyCircles.count
        showCirclesChangeViewPopUp(totalCircles: initialCount, numOfCircles: 0-removedCount, colorOfChange: .purple)

    }
    
    func removeAmountFromCirclesIfNotHalf(amount:Int) {
        // Get all circles except the correct one
        let removableCircles = viewModel.luckyCircles.filter { $0.id != nextCorrectCircle.id }
     
        if(removableCircles.count >= amount) {
            // Remove the first {{amount}} circles from the list
            let initialCount = viewModel.luckyCircles.count
            viewModel.luckyCircles.removeAll { circle in
                removableCircles.prefix(amount).contains(where: { $0.id == circle.id })
            }
            let removedCount = initialCount - viewModel.luckyCircles.count
            showCirclesChangeViewPopUp(totalCircles: initialCount, numOfCircles: 0-removedCount, colorOfChange: .purple)
        } else {
            //only remove half
            showBetText(text: "Less than \(amount) Circles, Cut in Half", colorOfText: .red)
            removeHalfOfTheCircles()
        }
    }
    
    func triviaDone(isCorrect:Bool) {
 
        if(isCorrect) {
            if(isPowerUpActive(id: "6")) { // trivia easy remove 20
                removeAmountFromCirclesIfNotHalf(amount: 20)
            } else if(isPowerUpActive(id: "7")) { //medium reove 40
                removeAmountFromCirclesIfNotHalf(amount: 40)
            } else if(isPowerUpActive(id: "8")) { //hard remove 60
                removeAmountFromCirclesIfNotHalf(amount: 60)
            }
            removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: true)
        } else {
            if(isPowerUpActive(id: "5")) { // trivia mania is active so count them
                let toRemove = triviaManager.score*5
                getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaCorrects += triviaManager.score
                getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaInCorrects += 1
                
                removeAmountFromCirclesIfNotHalf(amount: toRemove)

                removeFromActivePowerUps(id:getTrivaIdBasedOnType())
            } else {
                //for circles game we don't restart on incorrect trivia guess
                //circleClickedIsInCorrect()
                removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: false)
            }
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
            return "9"
        default:
            return ""
        }
    }
    
    func isPowerUpActive(id:String) -> Bool {
        return activePowerUps.contains(where: {$0.id == id})
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
        case "2"://50%
            // Get all circles except the correct one
            let removableCircles = viewModel.luckyCircles.filter { $0.id != nextCorrectCircle.id }

            // Ensure there are circles to remove
            guard !removableCircles.isEmpty else { return }

            // Calculate the number of circles to remove (half of the list)
            let halfCount = removableCircles.count / 2
            let initialCount = viewModel.luckyCircles.count

            // Remove the first `halfCount` circles from the list
            viewModel.luckyCircles.removeAll { circle in
                removableCircles.prefix(halfCount).contains(where: { $0.id == circle.id })
            }
            
            showCirclesChangeViewPopUp(totalCircles: initialCount, numOfCircles: 0-halfCount, colorOfChange: .purple)

        case "3": //remove one color
            // Get a set of unique colors excluding the correct circle's color
            var uniqueColors = Set(viewModel.luckyCircles.map { $0.color })
            uniqueColors.remove(nextCorrectCircle.color)

            // Ensure there's at least one color to remove
            guard let colorToRemove = uniqueColors.randomElement() else {
                showBetText(text: "Only One Color Left", colorOfText: .red)
                return
            }
             
            // Remove circles with the randomly selected incorrect color
            let initialCount = viewModel.luckyCircles.count
            viewModel.luckyCircles.removeAll { $0.color == colorToRemove }
            let removedCount = initialCount - viewModel.luckyCircles.count
            showCirclesChangeViewPopUp(totalCircles: initialCount, numOfCircles: 0-removedCount, colorOfChange: colorToRemove)
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
            if(nextCorrectCircle.id == "99") {
                generateNextGuessedCircle()
            }
           
            // Determine the quadrant for the target circle
            targetQuadrant = determineQuadrant(for: nextCorrectCircle.position, in: screenSize)
            
        case "10"://remove two colors
            // Get a set of unique colors excluding the correct circle's color
            var uniqueColors = Set(viewModel.luckyCircles.map { $0.color })
            uniqueColors.remove(nextCorrectCircle.color)

            // Ensure there are at least two colors to remove
            guard uniqueColors.count >= 2 else {
                showBetText(text: "Only One or Two Colors Left", colorOfText: .red)
                return
            }

            // Select two random incorrect colors
            let colorsToRemove = Array(uniqueColors.shuffled().prefix(2))
            let initialCount = viewModel.luckyCircles.count

            // Remove circles with the selected incorrect colors
            viewModel.luckyCircles.removeAll { colorsToRemove.contains($0.color) }
            let removedCount = initialCount - viewModel.luckyCircles.count
            showCirclesChangeViewPopUp(totalCircles: initialCount, numOfCircles: 0-removedCount, colorOfChange: .purple)
        case "11"://remove three colors
            // Get a set of unique colors excluding the correct circle's color
            var uniqueColors = Set(viewModel.luckyCircles.map { $0.color })
            uniqueColors.remove(nextCorrectCircle.color)

            // Ensure there are at least two colors to remove
            guard uniqueColors.count >= 3 else {
                showBetText(text: "Only One or Two or Three Colors Left", colorOfText: .red)
                return
            }

            // Select two random incorrect colors
            let colorsToRemove = Array(uniqueColors.shuffled().prefix(3))
            let initialCount = viewModel.luckyCircles.count

            // Remove circles with the selected incorrect colors
            viewModel.luckyCircles.removeAll { colorsToRemove.contains($0.color) }
            let removedCount = initialCount - viewModel.luckyCircles.count
            showCirclesChangeViewPopUp(totalCircles: initialCount, numOfCircles: 0-removedCount, colorOfChange: .purple)
        case "12": adForCoins()
        default:
            print("default")
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
    
    func circleClicked(circle:LuckyCircle) {
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
        if(nextCorrectCircle.id == "99") {
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
            showBetCoinViewPopUp(totalCoins: user.coins!, numOfCoins: (Int(getPayoutFromBet())), colorOfChange: .green)
            //showBetText(text: "Bet Won: +\(Int(getPayoutFromBet()))c", colorOfText:.green)
            updateBettingStatsCorrect()
            user.coins = user.coins! + Int(getPayoutFromBet())
            currentActiveBet = 0
        }
    }
    
    func resetDisapearingBetCoinViewParams() {
        showBetCoinViewpopUp = true
    }
    
    func resetDisapearingCirclesChangeViewParams() {
        showCircleChangeViewpopUp = true
    }
    
    func getPayoutFromBet() -> CGFloat {
        return CGFloat(currentActiveBet) * getOddsForBet()
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
        coinTotal = totalCircles
        coinChangeColor = colorOfChange
        coinChangeNum = numOfCircles
        resetDisapearingCirclesChangeViewParams()
    }
    
    func flashCorrectCircle() {
        // Remove all circles except for the correct one
        viewModel.luckyCircles = viewModel.luckyCircles.filter { $0.id == nextCorrectCircle.id }
    }
    
    func circleClickedIsInCorrect() {
        // Show the correct circle for 1 second before proceeding with the rest of the logic
        lockBoard = true
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
            showBetCoinViewPopUp(totalCoins: user.coins!,numOfCoins: 0-currentActiveBet, colorOfChange: .red)
            //showBetText(text: "Bet Lost: -\(currentActiveBet)c", colorOfText:.red)
            updateBettingStatsInCorrect()
            user.coins = user.coins! - currentActiveBet
            currentActiveBet = 0
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
        if let index = activePowerUps.enumerated().first(where: {$0.element.id == id}) {
            // do something with foo.offset and foo.element
            activePowerUps.remove(at: index.offset)
        } else {
            // item could not be found
        }
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
    LuckyCirclesGameBoard(user: MockData.defUser, powerUps: MockData.circlePowerUps)
}
