//
//  PowerUp.swift
//  How Lucky
//
//  Created by Peyton White on 11/2/24.
//

import Foundation
import SwiftUI

class PowerUp:ObservableObject, Identifiable, Hashable {
    var id:String
    var name:String
    var color:Color
    var isLocked:Bool
    var description:String
    var costOfCoins:Int

    
    init(id:String, name: String, color: Color, isLocked: Bool, description:String, costOfCoins:Int) {
        self.id = id
        self.name = name
        self.color = color
        self.isLocked = isLocked
        self.description = description
        self.costOfCoins = costOfCoins
    }
    

}

extension PowerUp: Equatable {
    
    public func hash(into hasher: inout Hasher) {
           return hasher.combine(id)
       }
    
    static func == (lhs: PowerUp, rhs: PowerUp) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
}
