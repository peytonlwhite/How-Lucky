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
    @State private var howManyGuessesLeft: Int = 1
    @State private var timesGuessedWrong: Int = 0
    @State private var timesGuessed: Int = 0

    // MARK: - Sheets Info
    @State private var showingPowerUpSheet = false
    @State private var showingTriviaSheet = false

    // MARK: - Trivia Info
    @State private var typeOfTriva: String = ""

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
    @State private var disapearingText = "Use Power Ups to find the correct Circle!"
 

    
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
                                LuckyCircleView(circle: circle) {
                                    circleClicked(circle: circle)
                                }
                            }
                            flashQuadrantBorder(in: geometry.size)
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
                    
                }
                .navigationTitle("Lucky Circles")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    
                    ToolbarItemGroup() {
                      Spacer()
                        Text("\(viewModel.luckyCircles.count)")
                            .font(.title)
                            .foregroundStyle(.blue)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        ToolbarView(
                            showingPowerUpSheet: $showingPowerUpSheet,
                            showingTriviaSheet: $showingTriviaSheet,
                            powerUps: powerUps,
                            freePassPowerUp: freePassPowerUp,
                            powerUpChosen: powerUpChosen,
                            triviaDone: triviaDone,
                            typeOfTriva: typeOfTriva,
                            triviaManager: triviaManager,
                            user:user
                        )
                    }
                }
            }
        }
        .onAppear {
            startFlashingAnimation()
            isLoading = false
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
    
    func startFlashingAnimation() {
        colorIndex = 0
        if(colorScheme == .dark) {
                colors = [.black, .red]
        }
        
          shouldTransition = false
          colorIndex += 1
          
          DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
              print("circle dis")
              withAnimation(.easeInOut(duration: animationDuration)) {
                  shouldTransition = true
              }
          }
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
            print("size det quad \(size)")
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
          // print("quadrantFrame \(quadrant)")
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
    
    func triviaDone(isCorrect:Bool) {
        print("User guess is correct: \(isCorrect)")
        print("Trivia score: \(triviaManager.score)")
        print("triviaManager.reachedEnd: \(triviaManager.reachedEnd)")
        
        print("Power Ups active \(activePowerUps.count)")
        activePowerUps.forEach {
            print("Power Up active \($0.name)")
        }
        
        var circlesWithoutCorrectOne = viewModel.luckyCircles
        if let index = circlesWithoutCorrectOne.enumerated().first(where: {$0.element.id == nextCorrectCircle.id}) {
            circlesWithoutCorrectOne.remove(at: index.offset)
        } else {
           //not a chosen one yet
        }
       
        if(isCorrect) {
            if(isPowerUpActive(id: "6")) { // trivia easy
                if circlesWithoutCorrectOne.count >= 20 {
                    circlesWithoutCorrectOne.removeFirst(20)
                } else {
                    circlesWithoutCorrectOne.removeFirst(circlesWithoutCorrectOne.count/4)
                }
                viewModel.luckyCircles = circlesWithoutCorrectOne
            } else if(isPowerUpActive(id: "7")) { //medium
                if circlesWithoutCorrectOne.count >= 40 {
                    circlesWithoutCorrectOne.removeFirst(40)
                } else {
                    circlesWithoutCorrectOne.removeFirst(circlesWithoutCorrectOne.count/3)
                }
                viewModel.luckyCircles = circlesWithoutCorrectOne
            } else if(isPowerUpActive(id: "8")) { //hard
                if circlesWithoutCorrectOne.count >= 60 {
                    circlesWithoutCorrectOne.removeFirst(60)
                } else {
                    circlesWithoutCorrectOne.removeFirst(circlesWithoutCorrectOne.count/2)
                }
                viewModel.luckyCircles = circlesWithoutCorrectOne
            }
            removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: true)
        } else {
            if(isPowerUpActive(id: "9")) { // trivia mania is active so count them
                let toRemove = triviaManager.score*5
                
                getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaCorrects += toRemove
                getPowerUpStat(id: getTrivaIdBasedOnType()).totalTriviaInCorrects += 1
                
                if circlesWithoutCorrectOne.count >= toRemove {
                    circlesWithoutCorrectOne.removeFirst(toRemove)
                } else {
                    circlesWithoutCorrectOne.removeFirst(circlesWithoutCorrectOne.count/2)
                }
                viewModel.luckyCircles = circlesWithoutCorrectOne
                removeFromActivePowerUps(id:getTrivaIdBasedOnType())
            } else {
                //for circles game we don't restart on incorrect trivia guess
                //circleClickedIsInCorrect()
                removeTriviaBasedOnTypeFromActivePowerUps(isCorrect: false)
            }
        }
        
        print("lucky circle count: \(viewModel.luckyCircles.count)")
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
        switch typeOfTriva {
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
        howManyGuessesLeft = 2
    }
    
    func getPowerUpStat(id:String) -> PowerUpStats {
        //if need default powerup then we can return it from mockdata powerups
        return (user.luckyCirclesStats?.powerUpStats.first(where: {$0.id == id}))!
    }
    
    
    func powerUpChosen(powerUp: PowerUp) {
        print("power up chosen: \(powerUp.id)")
        powerUp.isLocked = true
        
        activePowerUps.append(powerUp)
        
        getPowerUpStat(id: powerUp.id).totalTimesUsed += 1
        powerUpsUsedForCurrentScore += 1

        if(powerUp.costOfCoins > 0) {
            user.coins = user.coins! - powerUp.costOfCoins
        }
        
        switch powerUp.id {
        case "1"://free pass
            circleClicked(circle: LuckyCircle(id: "free pass", name: "free pass", color: .white, isDisabled: false, size: 0.0,position: CGPoint(x: 5, y: 5)))
        case "2"://50%
            var circlesWithoutCorrectOne = viewModel.luckyCircles
            if let index = circlesWithoutCorrectOne.enumerated().first(where: {$0.element.id == nextCorrectCircle.id}) {
                circlesWithoutCorrectOne.remove(at: index.offset)
            } else {
               //not a chose one yet
            }
            let arr = circlesWithoutCorrectOne.chunked(into: viewModel.howManyCircles/2)[0]
            viewModel.luckyCircles = arr
        case "3"://remove a color
            let arr = viewModel.luckyCircles.filter {
                $0.color != viewModel.luckyCircles[0].color
                &&
                $0.id != nextCorrectCircle.id
            }
            print("arr.len \(arr.count)")

            viewModel.luckyCircles = arr
            //only 1 left
            if(arr.count < 2) {
                circleClickedIsCorrect()
            }
        case "4"://Two guesses
            twoGuesses()
        case "5"://Trivia mania
            print("mania")
            typeOfTriva = "Mania"
            trivia(type:"mania")
        case "6"://Triva Easy
            print("Easy")
            typeOfTriva = "Easy"
            trivia(type:"easy")
        case "7"://Triva Med
            print("Medium")
            typeOfTriva = "Medium"
            trivia(type:"med")
        case "8"://Triva Hard
            print("Hard")
            typeOfTriva = "Hard"
            trivia(type:"hard")
        case "9"://which quadrant
            //not a circle yet
            if(nextCorrectCircle.id == "99") {
                generateNextGuessedCircle()
            }
            // Determine the quadrant for the target circle
            targetQuadrant = determineQuadrant(for: nextCorrectCircle.position, in: screenSize)
            print("targetQuadrant: \(targetQuadrant)")

        case "10"://remove two colors
            let arr = viewModel.luckyCircles.filter {
                $0.color != viewModel.luckyCircles[0].color
                &&
                $0.color != viewModel.luckyCircles[viewModel.luckyCircles.count-1].color
                &&
                $0.id != nextCorrectCircle.id
            }
            print("arr.len \(arr.count)")

            viewModel.luckyCircles = arr
            //only 1 left
            if(arr.count < 2) {
                circleClickedIsCorrect()
            }
        case "11"://remove three colors
            let arr = viewModel.luckyCircles.filter {
                $0.color != viewModel.luckyCircles[0].color
                &&
                $0.color != viewModel.luckyCircles[viewModel.luckyCircles.count-1].color
                &&
                $0.color != viewModel.luckyCircles[viewModel.luckyCircles.count-11].color
                &&
                $0.id != nextCorrectCircle.id
            }
            print("arr.len \(arr.count)")
            viewModel.luckyCircles = arr
            //only 1 left
            if(arr.count < 2) {
                circleClickedIsCorrect()
            }
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
        print("circle clicked: \(circle.id)")
        timesGuessed += 1
        
        print("Power Ups active BOF \(activePowerUps.count)")
        activePowerUps.forEach {
            print("Power Up active BOF \($0.name)")
        }
        
        print("times guessed BOF \(timesGuessed)")
        print("howManyGuessesLeft BOF \(howManyGuessesLeft)")
        print("timesGuessedRight BOF \(timesGuessedRight)")
        print("circle clicked name BOF \(circle.name)")
        print("circle clicked id BOF \(circle.id)")
        print("circle clicked disabled BOF \(circle.isDisabled)")
      
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
        
        print("nextCorrectSquare.id \(nextCorrectCircle.id)")
        print("square.id \(circle.id)")
        
        if(nextCorrectCircle.id == circle.id) {
            print("Correct")
            
            //Two Guesses is active reset it and remove it
            if(isPowerUpActive(id:"4")) {
                removeFromActivePowerUps(id:"4")
            }
            
            
            circleClickedIsCorrect()
            
        } else { // incorrect guess
            print("Incorrect")
            
            if(isPowerUpActive(id:"4")) { //two guesses is active
                if(howManyGuessesLeft > 1) { //give them another chance
                    print("give them another chance")
                    circle.isDisabled = true
                    removeCircleFromCircles(id:circle.id)
                } else { //last guess, remove powerUp and reset it
                    removeFromActivePowerUps(id:"4")
                    circleClickedIsInCorrect()
                }
                howManyGuessesLeft = howManyGuessesLeft - 1
            } else { //all other cases reset everything
                circleClickedIsInCorrect()
            }
        }
        
        print("howManyGuessesLeft EOF \(howManyGuessesLeft)")
        print("timesGuessedRight EOF \(timesGuessedRight)")
        
    }
    
    func removeCircleFromCircles(id:String) {
        if let index = viewModel.luckyCircles.enumerated().first(where: {$0.element.id == id}) {
           // do something with foo.offset and foo.element
            print("offset removed: \(index.offset)")
            viewModel.luckyCircles.remove(at: index.offset)
        } else {
           // circle could not be found
        }
    }
    
    func resetCircles() {
        viewModel.resetCircles()
    }
    
    func circleClickedIsCorrect() {
        timesGuessedRight += 1
        score = timesGuessedRight * 50
        howManyGuessesLeft = 1
        timesGuessedWrong = 0
        toggleScoreView()
        checkHighscore()
        enableAllCircles()
        resetPowerUps()
        resetCircles()
        generateNextGuessedCircle()
        targetQuadrant = .none
        
        setDisapearingText()
        triedMoreThanOnce = true
    }
    
    func enableAllCircles() {
        //set all squares to able
        viewModel.luckyCircles.forEach { $0.isDisabled = false }
    }
    
    
    func circleClickedIsInCorrect() {
        timesGuessedRight = 0
        timesGuessed = 0
        score = 0
        powerUpsUsedForCurrentScore = 0
        howManyGuessesLeft = 1
        resetCircles()
        resetPowerUps()
        resetActivePowerUps()
        toggleScoreView()
        generateNextGuessedCircle()
        targetQuadrant = .none
        
        //stats
        user.luckyCirclesStats?.totalTimesPlayed = (user.luckyCirclesStats?.totalTimesPlayed ?? 0) + 1
        timesGuessedWrong += 1
 
        if((user.luckyCirclesStats?.totalTimesIncorrectInRow ?? 0) < timesGuessedWrong * 50) {
            user.luckyCirclesStats?.totalTimesIncorrectInRow = timesGuessedWrong * 50
        }
        setDisapearingText()

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
        print("randomRange: \(randomRange)")
        nextCorrectCircle = viewModel.luckyCircles[randomRange]
    }
    
    
    func removeFromActivePowerUps(id:String) {
        if let index = activePowerUps.enumerated().first(where: {$0.element.id == id}) {
           // do something with foo.offset and foo.element
            print("offset removed: \(index.offset)")
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
