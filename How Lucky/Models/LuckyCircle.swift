//
//  LuckyCircle.swift
//  How Lucky
//
//  Created by Peyton White on 11/7/24.
//

import Foundation
import SwiftUI

@Observable class LuckyCircle:Identifiable, Hashable {
    let id:String
    let name:String
    let color:Color
    var isDisabled:Bool
    let size:CGFloat
    let position:CGPoint
    
    init(id: String, name:String, color: Color, isDisabled: Bool, size:CGFloat, position:CGPoint) {
        self.id = id
        self.name = name
        self.color = color
        self.isDisabled = isDisabled
        self.size = size
        self.position = position
    }
    
}


extension LuckyCircle: Equatable {
    
    public func hash(into hasher: inout Hasher) {
           return hasher.combine(id)
       }
    
    static func == (lhs: LuckyCircle, rhs: LuckyCircle) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
}
