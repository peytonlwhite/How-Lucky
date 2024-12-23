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
    @State private var textSwitch = false
    @State private var activePowerUps: [PowerUp] = []
    
    let powerUps: [PowerUp]
    @State private var freePassPowerUp = MockData.freePassPowerUp
    @State private var nextCorrectSquare = LuckySquare(id: "99", name: "Empty", color: .red, isDisabled: false)
    @State private var howManyGuessesLeft: Int = 1
    @State private var typeOfTrivia: String = ""

    // MARK: - Animation Properties
    @State private var colors: [Color] = [.white, .red]
    private let maxScaleEffect: CGFloat = 4.0
    private let minScaleEffect: CGFloat = 0
    private let animationDuration = 1.2
    private let animationDelay = 0.1
    @State private var shouldTransition = true
    @State private var colorIndex = 0
    
    @State private var typeOfTriva: String = ""

    @Environment(\.colorScheme) var colorScheme

    //MARK: - ad properties
    @StateObject var rewardViewModel = RewardedViewModel()

    @State private var isLoading = true

    @State private var showText = true
    @State private var triedMoreThanOnce = false
    @State private var textOpacity = 1.0
    @State private var disapearingText = "Guess the correct square!"


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
                    
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(minimum: 20)), count: columnCount),
                        alignment: .center, spacing: 10
                    ) {
                        ForEach(viewModel.luckySquares, id: \.self) { square in
                            Button {
                                squareClicked(square: square)
                            } label: {
                                LuckySquareView(square: square)
                            }
                            .disabled(square.isDisabled)
                        }
                    }
                    .padding()
                    
                    // Disappearing Text at Mid-Top and Centered
                    if showText {
                        GeometryReader { geometry in
                            Text(disapearingText)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
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
                    
                    
                    // High Score in Bottom Left
                    Text("High Score: \(user.luckySquaresStats!.highScore)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.black.opacity(0.5)) // Optional background for visibility
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                    
                    
                }
            }
            .navigationTitle("Lucky Squares")
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            .toolbar {
                ToolbarView(
                    showingPowerUpSheet: $showingPowerUpSheet,
                    showingTriviaSheet: $showingTriviaSheet,
                    powerUps: powerUps,
                    freePassPowerUp: freePassPowerUp,
                    powerUpChosen: powerUpChosen,
                    triviaDone: triviaDone,
                    typeOfTriva: typeOfTrivia,
                    triviaManager: triviaManager,
                    user:user
                )
            }
        }
        .onAppear {
            startFlashingAnimation()
            isLoading = false
        }
    }
}

 
private extension LuckySquaresGameBoard {
    
    
    var previousColor: Color { colors[colorIndex % colors.count] }
    var transitioningColor: Color { colors[(colorIndex + 1) % colors.count] }
     
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
                squareClickedIsInCorrect()
                removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: false)
            }
        }
        
        resetTriviaManager()

    }
    
    func getTrivaIdBasedOnType() -> String {
        switch typeOfTriva {
            case "easy":
                return "5"
            case "med":
                return "6"
            case "hard":
                return "11"
            case "tof":
                return "7"
            case "mania":
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

          
        switch powerUp.id {
          case "1": squareClicked(square: LuckySquare(id: "free pass", name: "free pass", color: .white, isDisabled: false))
          case "2": split5050()
          case "3": luckyRestart()
          case "4": twoGuesses()
          case "5": trivia(type: "easy")
          case "6": trivia(type: "med")
          case "7": trivia(type: "tof")
          case "9": trivia(type: "mania")
          case "10": resetPowerUpsButReset()
          case "11": trivia(type: "hard")
          case "12": adForCoins()
          default: break
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
        typeOfTriva = type
        Task { await triviaManager.fetchTrivia(gameType: type) }
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
        print("randomRange: \(randomRange)")
        nextCorrectSquare = viewModel.luckySquares[randomRange]
    }
    
    func squareClicked(square:LuckySquare) {
        timesGuessed += 1
                
        activePowerUps.forEach {
            print("Power Up active BOF \($0.name)")
        }

        /*
        print("times guessed BOF \(timesGuessed)")
        print("numOfSquares BOF \(numOfSquares)")
        print("howManyGuessesLeft BOF \(howManyGuessesLeft)")
        print("timesGuessedRight BOF \(timesGuessedRight)")
        print("square clicked name BOF \(square.name)")
        print("square clicked id BOF \(square.id)")
        print("square clicked disabled BOF \(square.isDisabled)")
    */
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
                    squareClickedIsInCorrect()
                }
                howManyGuessesLeft = howManyGuessesLeft - 1
            } else { //all other cases reset everything
                squareClickedIsInCorrect()
            }
        }
      
    }
    
    func setDisapearingText() {
        print("user highscore: \(getHighscoreinTimesTried())")
        print("timesGuessedRight: \(timesGuessedRight)")
        print("if condition = \(getHighscoreinTimesTried() - timesGuessedRight)")
        
        if(timesGuessedRight == 1 && !triedMoreThanOnce) {
            disapearingText = "Nice, Now Keep Guessing"
            resetDisapearingTextParams()
        } else if(timesGuessedWrong > 0 && !triedMoreThanOnce) {
            disapearingText = "Tough, Try Again"
            resetDisapearingTextParams()
        }
        
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

        viewModel.luckySquares.append(LuckySquare(id: UUID().uuidString, name: "\(numOfSquares+1)", color: .red, isDisabled: false))
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
        viewModel.luckySquares  = [
           LuckySquare(id: "1", name:"1", color: .red, isDisabled: false),
           LuckySquare(id: "2", name:"2", color: .red, isDisabled: false)
       ]
    }
    
    func enableAllSquares() {
        //set all squares to able
        viewModel.luckySquares.forEach { $0.isDisabled = false }
    }
    
    func squareClickedIsInCorrect() {
        timesGuessedRight = 0
        score = 0
        timesGuessed = 0
        powerUpsUsedForHighscore = 0
        howManyGuessesLeft = 1
        resetSquares()
        columnCount = 2
        resetPowerUps()
        resetActivePowerUps()
        toggleScoreView()
        powerUpsUsedForHighscore = 0
        //stats
        user.luckySquaresStats?.totalTimesPlayed = (user.luckySquaresStats?.totalTimesPlayed ?? 0) + 1
        timesGuessedWrong += 1

        if((user.luckySquaresStats?.totalTimesIncorrectInRow ?? 0) < timesGuessedWrong * 50) {
            user.luckySquaresStats?.totalTimesIncorrectInRow = timesGuessedWrong * 50
        }
        setDisapearingText()
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
