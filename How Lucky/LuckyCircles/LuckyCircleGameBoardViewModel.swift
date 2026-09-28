//
//  LuckyCircleGameBoardViewModel.swift
//  How Lucky
//
//  Created by Peyton White on 11/7/24.
//
import SwiftUI
import Foundation

class LuckyCircleGameBoardViewModel:ObservableObject {
    
    @Published var luckyCircles = [LuckyCircle]()
    var listOfColors = [Color]()
    private(set) var boardSize = CGSize(width: 320, height: 480)
    let howManyColors = 10; //25 circles for each color
    let howManyCircles = 250; //250
    let dotSizeRange: ClosedRange<CGFloat> = 20...60  // Adjust dot size range as needed
    //var powerUps: [PowerUp] = []

    
    init() {
        resetCircles()
        //loadPowerUps()
    }
    
    func loadPowerUps() {
       // powerUps = MockData.squarePowerUps
    }
    
    
    func getRandomColors() {
        // Ten consistent colors remain easy to distinguish against the game surface.
        listOfColors = [Color.red, .orange, .yellow, .green, .teal, .cyan, .blue, .indigo, .purple, .pink].shuffled()
    }

    private func randomPosition(forSize size: CGFloat) -> CGPoint {
        let radius = size / 2
        return CGPoint(
            x: CGFloat.random(in: radius...max(radius, boardSize.width - radius)),
            y: CGFloat.random(in: radius...max(radius, boardSize.height - radius))
        )
    }

    /// Resize existing circles without changing the winner, colors, or guesses.
    func updateBounds(_ bounds: CGSize) {
        guard bounds.width.isFinite, bounds.height.isFinite,
              bounds.width > 0, bounds.height > 0, bounds != boardSize else { return }
        for circle in luckyCircles {
            let oldRadius = circle.size / 2
            let x = (circle.position.x - oldRadius) / max(1, boardSize.width - circle.size)
            let y = (circle.position.y - oldRadius) / max(1, boardSize.height - circle.size)
            circle.size = min(circle.size, min(bounds.width, bounds.height))
            let radius = circle.size / 2
            circle.position = CGPoint(
                x: radius + min(1, max(0, x)) * max(0, bounds.width - circle.size),
                y: radius + min(1, max(0, y)) * max(0, bounds.height - circle.size)
            )
        }
        boardSize = bounds
    }

    @discardableResult
    func removeIncorrectCircles(upTo count: Int, preserving winnerID: String) -> Int {
        guard count > 0, luckyCircles.contains(where: { $0.id == winnerID }) else { return 0 }
        // Randomize removals so array order does not reveal the winning circle.
        let ids = Set(luckyCircles.filter { $0.id != winnerID }.shuffled().prefix(count).map { $0.id })
        luckyCircles.removeAll { ids.contains($0.id) }
        return ids.count
    }

    @discardableResult
    func cutInHalf(preserving winnerID: String) -> Int {
        removeIncorrectCircles(upTo: luckyCircles.count / 2, preserving: winnerID)
    }

    func removableColors(preserving winnerID: String) -> [Color] {
        guard let winner = luckyCircles.first(where: { $0.id == winnerID }) else { return [] }
        return Array(Set(luckyCircles.map { $0.color }).subtracting([winner.color]))
    }

    @discardableResult
    func removeColors(count: Int, preserving winnerID: String) -> Int {
        let eligible = removableColors(preserving: winnerID)
        guard count > 0, eligible.count >= count else { return 0 }
        let colors = Set(eligible.shuffled().prefix(count))
        let before = luckyCircles.count
        luckyCircles.removeAll { colors.contains($0.color) }
        return before - luckyCircles.count
    }

    func resetCircles() {
        luckyCircles = []
        listOfColors = []
        getRandomColors()
        
        for count in 1..<howManyCircles+1 {
            let size = min(CGFloat.random(in: dotSizeRange), min(boardSize.width, boardSize.height))
            let pos = self.randomPosition(forSize: size)
            
            self.luckyCircles.append(LuckyCircle(id: "\(count)", name:"\(count)", color: getRandomColor(), isDisabled: false, size: size,position: pos))
        }
    }
    
    
    func getRandomColor() -> Color {
        let randomRange = Int.random(in: 0..<listOfColors.count)
        
        let randomColor = listOfColors[randomRange]
        
        let arr = luckyCircles.filter {
            $0.color == randomColor
        }
        
        if(arr.count == (howManyCircles/howManyColors)) {
            //remove that from the list return a different color
            listOfColors.removeAll { $0.hashValue == randomColor.hashValue }
            return getRandomColor()
        } else {
            return randomColor
        }
    }
    
}

