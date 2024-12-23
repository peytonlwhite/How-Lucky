//
//  ScoreView.swift
//  How Lucky
//
//  Created by Peyton White on 11/11/24.
//

import SwiftUI

struct ScoreView: View {
    let score: Int
    let textSwitch: Bool
    
    var body: some View {
        Text(textSwitch ? "\(score)" : "")
            .font(.system(size: score > 50 ? 200 : 300))
            .foregroundStyle(Color(score > 0 ? UIColor.green : UIColor.red))
            .zIndex(10)
    }
}


#Preview {
    ScoreView(score: 5, textSwitch: true)
}
