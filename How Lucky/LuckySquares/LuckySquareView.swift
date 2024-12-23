//
//  SquareView.swift
//  How Lucky
//
//  Created by Peyton White on 10/29/24.
//

import SwiftUI

struct LuckySquareView: View {
    
    var square:LuckySquare
    
    var body: some View {
        Text(square.name)
            .frame(width: 75, height: 75)
            .foregroundStyle(.white)
            .fontWeight(.bold)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.red))
            .overlay {
                if square.isDisabled {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(Color(UIColor.systemGroupedBackground))
                        .opacity(0.55)
                }
            }
    }
}

#Preview {
    LuckySquareView(square:LuckySquare(id: "1", name:"1", color: .red, isDisabled: false))
}
