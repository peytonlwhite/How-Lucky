//
//  PowerUpView.swift
//  How Lucky
//
//  Created by Peyton White on 11/2/24.
//

import SwiftUI

struct PowerUpView: View {
    let powerUp:PowerUp
    let isMaxWidth:Bool
    @State var viewOptionsIsShown = false
    @Environment(\.colorScheme) var colorScheme
    

    var body: some View {
        
        
    
        HStack(alignment: .center) {
            VStack {
                if powerUp.costOfCoins != 0 {
                    HStack(spacing:3) {
                        Spacer()
                        Text("\(powerUp.costOfCoins)")
                            .font(.headline)
                            .foregroundStyle(.yellow)
                        Image(systemName: "c.circle")
                            .font(.headline)
                            .foregroundStyle(.yellow)
                    }
                    .padding(.trailing, 6)
                    .padding(.top,15)
                }
                
                // Center the powerUp.name text both vertically and horizontally
                Text(powerUp.name)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.bottom,powerUp.costOfCoins == 0 ? 0 : 30)
                    .padding(.horizontal,5)
            }
            //.padding(.top,3)
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Make VStack take up all available space
        }
        .frame(maxWidth: isMaxWidth ? .infinity : 150, maxHeight: 85)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(powerUp.color)
        )
        .overlay {
           
            RoundedRectangle(cornerRadius: 8)
                   .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth:1)
            
            if powerUp.isLocked {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color(UIColor.systemGroupedBackground))
                    .opacity(0.55)
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.6)
                .onEnded {_ in
                    viewOptionsIsShown = true
                }
        )
        .popover(isPresented: $viewOptionsIsShown, arrowEdge: .top) {
            ZStack {
                Text("\(powerUp.description)")
                    .presentationCompactAdaptation(.popover)
                    .foregroundStyle(powerUp.color)
                    .frame(height:100)
            }
            .padding()
    
        }
    }
}

#Preview {
    PowerUpView(powerUp: PowerUp(id: "1", name: "Hey dfvfvdfvdfvdfvdfvdv", color: .blue, isLocked: false, description: "desc", costOfCoins: 4), isMaxWidth: false)
}
