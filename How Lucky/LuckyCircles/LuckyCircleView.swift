//
//  LuckyCircleView.swift
//  How Lucky
//
//  Created by Peyton White on 11/7/24.
//

import SwiftUI

struct LuckyCircleView: View {
    
    let circle:LuckyCircle
    let isCorrect:Bool
    var onTap: () -> Void  // Closure that is called when the circle is tapped

    @State private var isBlinking = false

    
    var body: some View {
        Circle()
                    .fill(circle.isDisabled ? .clear : circle.color)
                    .frame(width: circle.size, height: circle.size)
                    .position(circle.position)
                    .opacity(isCorrect && isBlinking ? 0.3 : 1.0) // Blinking effect
                    .onAppear {
                        if isCorrect {
                            //startBlinking()
                        }
                    }
                    .onTapGesture {
                        onTap()
                    }
    }
    
    
    private func startBlinking() {
        withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            isBlinking.toggle()
        }
    }
    
}


#Preview {
    LuckyCircleView(circle: LuckyCircle(id: "1", name: "1", color: .blue, isDisabled: false, size: 50.0,
                                        position: CGPoint(x: 50, y: 100)),
                    isCorrect: true) {
        //onTap
    }
}
