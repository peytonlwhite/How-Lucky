//
//  LuckySquare.swift
//  How Lucky
//
//  Created by Peyton White on 11/3/24.
//

import Foundation
import SwiftUI
import Observation


@Observable class LuckySquare:Identifiable, Hashable {
    let id:String
    let name:String
    let color:Color
    var isDisabled:Bool
    
    init(id: String, name:String, color: Color, isDisabled: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.isDisabled = isDisabled
    }
    
    
    
}


extension LuckySquare: Equatable {
    
    public func hash(into hasher: inout Hasher) {
           return hasher.combine(id)
       }
    
    static func == (lhs: LuckySquare, rhs: LuckySquare) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
}
