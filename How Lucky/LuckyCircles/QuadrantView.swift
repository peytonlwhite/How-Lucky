//
//  QuadrantView.swift
//  How Lucky
//
//  Created by Peyton White on 11/9/24.
//

import SwiftUI

struct QuadrantView: View {
    let frame: CGRect
    let isHighlighted: Bool
    let offsetX:CGFloat
    let offsetY:CGFloat
      
    var body: some View {
        Rectangle()
                .stroke(isHighlighted ? Color.red : Color.clear, lineWidth: 5)
                .frame(width: frame.width, height: frame.height)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isHighlighted)
                .position(x: frame.midX, y: frame.midY)
                .offset(x:offsetX, y: offsetY)
    }
}

#Preview {
    QuadrantView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/2), isHighlighted: true, offsetX: 201.0,offsetY: 343.83333333333337)
}
