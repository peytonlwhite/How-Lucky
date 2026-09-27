//
//  LuckySquareGameBoardViewModel.swift
//  How Lucky
//
//  Created by Peyton White on 11/3/24.
//

import Foundation
//
//  GameOptionsViewModel.swift
//  How Lucky
//
//  Created by Peyton White on 11/1/24.
//

class LuckySquareGameBoardViewModel:ObservableObject {
    
    @Published var luckySquares = [LuckySquare]()
    
    init() {
        self.luckySquares = [
            LuckySquare(id: UUID().uuidString, name: "1", color: .red, isDisabled: false),
            LuckySquare(id: UUID().uuidString, name: "2", color: .red, isDisabled: false)
        ]
    }
    
}

/*
 LuckySquare(id: "3", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "4", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "5", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "6", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "7", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "8", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "9", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "10", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "11", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "12", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "13", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "14", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "15", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "16", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "17", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "18", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "19", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "20", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "21", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "22", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "23", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "24", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "25", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "26", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "27", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "28", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "29", name:"2", color: .red, isDisabled: false),
 LuckySquare(id: "30", name:"30", color: .red, isDisabled: false),
 LuckySquare(id: "31", name:"30", color: .red, isDisabled: false),
 LuckySquare(id: "32", name:"30", color: .red, isDisabled: false),
 LuckySquare(id: "33", name:"30", color: .red, isDisabled: false),
 LuckySquare(id: "34", name:"30", color: .red, isDisabled: false),
 LuckySquare(id: "35", name:"35", color: .red, isDisabled: false),
 LuckySquare(id: "36", name:"35", color: .red, isDisabled: false),
 LuckySquare(id: "37", name:"35", color: .red, isDisabled: false),
 LuckySquare(id: "38", name:"35", color: .red, isDisabled: false),
 LuckySquare(id: "39", name:"39", color: .red, isDisabled: false),
 LuckySquare(id: "40", name:"39", color: .red, isDisabled: false),
 LuckySquare(id: "41", name:"39", color: .red, isDisabled: false),
 LuckySquare(id: "42", name:"42", color: .red, isDisabled: false),
 */


