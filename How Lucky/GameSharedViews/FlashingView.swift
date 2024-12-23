//
//  FlashingView.swift
//  How Lucky
//
//  Created by Peyton White on 11/11/24.
//

import SwiftUI

struct FlashingView: View {
    @Binding var shouldTransition: Bool
    let maxScaleEffect: CGFloat
    let minScaleEffect: CGFloat
    let colors: [Color]
    @Binding var colorIndex: Int
    let animationDuration: Double
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colors[colorIndex % colors.count])
                .scaleEffect(maxScaleEffect)
            
            Circle()
                .fill(colors[(colorIndex + 1) % colors.count])
                .scaleEffect(shouldTransition ? maxScaleEffect : minScaleEffect)
        }
    }
}

#Preview {
    FlashingView(shouldTransition: Binding.constant(true), maxScaleEffect: 4.0, minScaleEffect: 0.0, colors: [.white, .blue], colorIndex: Binding.constant(0), animationDuration: 1.2)
}
