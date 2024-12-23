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
    let howManyColors = 25; //25
    let howManyCircles = 250; //250
    let dotSizeRange: ClosedRange<CGFloat> = 20...60  // Adjust dot size range as needed
    //var powerUps: [PowerUp] = []

    
    init() {
        print("in viewmodel init")
        resetCircles()
        //loadPowerUps()
    }
    
    func loadPowerUps() {
       // powerUps = MockData.squarePowerUps
    }
    
    
    func getRandomColors() {
        for _ in 0..<howManyColors {
            self.listOfColors.append(Color.random)
        }
    }
    
    // Function to get a random position, ensuring circles stay on screen
    // Function to get a random position, ensuring circles stay on screen with at least half visible
       private func randomPosition(forSize size: CGFloat) -> CGPoint {
         
           let screenWidth = UIScreen.main.bounds.width-5
           let screenHeight = UIScreen.main.bounds.height-100
           
           // Adjust random position so that at least half of the circle stays on screen
           let minX = size / 2
           let maxX = screenWidth - size / 2
           let minY = size / 2
           let maxY = screenHeight - size / 2
           
           let x = CGFloat.random(in: minX...(maxX))
           let y = CGFloat.random(in: minY...(maxY))
           
           return CGPoint(x: x, y: y)
       }
    
    
    func resetCircles() {
        luckyCircles = []
        listOfColors = []
        getRandomColors()
        
        for count in 1..<howManyCircles+1 {
            let size = CGFloat.random(in: dotSizeRange)
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

