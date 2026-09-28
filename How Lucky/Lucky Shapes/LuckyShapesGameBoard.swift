//
//  LuckyShapesGameBoard.swift
//  How Lucky
//
//  Created by Peyton White on 12/18/24.
//

import SwiftUI

struct LuckyShapesGameBoard: View {
    // MARK: - User Info
    @Bindable var user: User
    @Environment(\.modelContext) var context
    let powerUps: [PowerUp]
    
    
    @State private var gridShapes = ["🔵", "🔺", "⬛️", "🟢", "🟠", "🟣", "🔷", "🟥", "🔶"]
    @State private var patternToMatch: [Int] = []
    @State private var playerPattern: [Int] = []
    @State private var isShowingPattern = true
    @State private var currentFlashingIndex = 0
    @State private var score = 0
    @State private var gridSize = 3
    @State private var patternLength = 2
    @State private var showResult = false
    @State private var resultText = ""
    
    let flashDuration = 0.5
    
    @State private var isFlashing = false
    @State private var flashColor: Color = .clear
    
    // MARK: - Animation Properties
    @State private var colors: [Color] = [.white, .yellow]
    private let maxScaleEffect: CGFloat = 4.0
    private let minScaleEffect: CGFloat = 0
    private let animationDuration = 1.2
    private let animationDelay = 0.1
    @State private var shouldTransition = true
    @State private var colorIndex = 0
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
        NavigationStack {
            ZStack {
                
                FlashingView(
                    shouldTransition: $shouldTransition,
                    maxScaleEffect: maxScaleEffect,
                    minScaleEffect: minScaleEffect,
                    colors: colors,
                    colorIndex: $colorIndex,
                    animationDuration: animationDuration
                )
                   
                
                VStack {
                    
                    GeometryReader { geometry in
                        let gridItemSize = calculateGridItemSize(for: geometry.size, gridSize: gridSize)
                        
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(gridItemSize), spacing: 10), count: gridSize),
                            spacing: 10
                        ) {
                            ForEach(0..<gridShapes.count, id: \.self) { index in
                                Button {
                                    handlePlayerTap(index: index)
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(isFlashing(index) ? Color.yellow : Color.blue)
                                            .frame(width: gridItemSize, height: gridItemSize)
                                            .scaleEffect(isFlashing(index) ? 1.2 : 1.0)
                                            .animation(.easeInOut(duration: flashDuration), value: isFlashing(index))
                                        
                                        Text(gridShapes[index])
                                            .font(.system(size: gridItemSize / 3))
                                            .opacity(isShowingPattern && !isFlashing(index) ? 0 : 1)
                                    }
                                }
                                .disabled(isShowingPattern)
                            }
                        }
                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    }
                    .padding()
                }
                
                // High Score in Bottom Left
                Text("High Score: \(user.luckyPatternsStats!.highScore)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.black.opacity(0.5)) // Optional background for visibility
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                
                
                if isFlashing {
                    flashColor
                        .ignoresSafeArea()
                        .animation(.easeOut(duration: 0.3), value: isFlashing)
                }
            }
            .toolbar {
                // Score on the left
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("\(score)")
                        .font(.title2)
                        .foregroundStyle(.green)
                        .padding()
                }
                
                // Title in the center
                ToolbarItem(placement: .principal) {
                    Text("Lucky Patterns")  // Replace with your game title
                        .font(.title)
                        .padding()
                }
                
                // Pattern length and "Coming Soon" on the right
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Text("\(patternLength)")
                            .font(.title)
                            .foregroundStyle(.blue)
                        
                        Spacer()
                        
                        Text("Coming Soon")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .alert(isPresented: $showResult) {
                Alert(
                    title: Text(resultText),
                    message: Text(resultText == "Correct!" ? "Keep going!" : "Game Over!"),
                    dismissButton: .default(Text("Restart"), action: restartGame)
                )
            }
            .onAppear {
                startFlashingAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    startNewRound()
                }
            }
        }
        
    }
    
    // MARK: - Helper Functions
    func calculateGridItemSize(for availableSize: CGSize, gridSize: Int) -> CGFloat {
        let horizontalSpace = availableSize.width - CGFloat(gridSize - 1) * 10
        let verticalSpace = availableSize.height - CGFloat(gridSize - 1) * 10
        let cellWidth = horizontalSpace / CGFloat(gridSize)
        let cellHeight = verticalSpace / CGFloat(gridSize)
        return min(cellWidth, cellHeight)
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
    
    func startNewRound() {
        patternToMatch = (0..<patternLength).map { _ in Int.random(in: 0..<gridShapes.count) }
        playerPattern = []
        currentFlashingIndex = 0
        isShowingPattern = true
        resultText = ""
        flashPattern()
    }
    
    func flashPattern() {
        guard currentFlashingIndex < patternToMatch.count+1 else {
            isShowingPattern = false
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
            currentFlashingIndex += 1
            flashPattern()
        }
    }
    
    func isFlashing(_ index: Int) -> Bool {
        isShowingPattern && currentFlashingIndex > 0 && currentFlashingIndex <= patternToMatch.count && patternToMatch[currentFlashingIndex - 1] == index
    }
    
    func handlePlayerTap(index: Int) {
        guard !isShowingPattern else { return }
        playerPattern.append(index)
        
        if playerPattern.count == patternToMatch.count {
            checkPattern()
        }
    }
    
    func checkPattern() {
        if playerPattern == patternToMatch {
            // Correct Guess
            score = score + 50
            checkUserStats()
            flashScreen(with: .green)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                // Move to the next round
                playerPattern.removeAll()
                increaseDifficulty()
                startNewRound()
            }
        } else {
            // Incorrect Guess
            checkUserStats()
            
            //stats
            user.luckyPatternsStats?.totalTimesPlayed = (user.luckyPatternsStats?.totalTimesPlayed ?? 0) + 1

            flashScreen(with: .red)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                // Restart the game
                restartGame()
            }
        }
    }
    
    func checkUserStats() {
        if(score > (user.luckyPatternsStats?.highScore ?? 0)) {
            user.luckyPatternsStats?.highScore = score
        }
    }
    
    func flashScreen(with color: Color) {
        flashColor = color
        isFlashing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isFlashing = false
        }
    }
     
    func restartGame() {
        score = 0
        gridSize = 3
        patternLength = 2
        gridShapes = ["🔵", "🔺", "⬛️", "🟢", "🟠", "🟣", "🔷", "🟥", "🔶"]
        startNewRound()
    }
    
    func increaseDifficulty() {
        if (score / 50) % 3 == 0 {
            gridSize += 1
            gridShapes.append(contentsOf: ["🟩", "🔳", "🟫"]) // Add more shapes for larger grid
        }
        if (score / 50) % 2 == 0 {
            patternLength += 1
        }
    }
}


#Preview {
    LuckyShapesGameBoard(user: MockData.defUser, powerUps: MockData.patternPowerUps)
}
