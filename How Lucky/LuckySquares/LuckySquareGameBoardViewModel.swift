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
            LuckySquare(id: "1", name:"1", color: .red, isDisabled: false),
            LuckySquare(id: "2", name:"2", color: .red, isDisabled: false)
        ]
    }
}


