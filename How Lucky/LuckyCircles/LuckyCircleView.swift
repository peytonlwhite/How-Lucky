//
//  LuckyCircleView.swift
//  How Lucky
//
//  Created by Peyton White on 11/7/24.
//

import SwiftUI

struct LuckyCircleView: View {
    
    let circle:LuckyCircle
    var onTap: () -> Void  // Closure that is called when the circle is tapped

    
    var body: some View {
        Circle()
            .fill(circle.isDisabled ? .clear : circle.color)
            .frame(width: circle.size, height: circle.size)
            .position(circle.position)
            .onTapGesture {
            // Execute the closure when the circle is tapped
                onTap()
            }
    }
}


#Preview {
    LuckyCircleView(circle: LuckyCircle(id: "1", name: "1", color: .blue, isDisabled: false, size: 50.0,
                                        position: CGPoint(x: 50, y: 100))) {
        //onTap
    }
}
