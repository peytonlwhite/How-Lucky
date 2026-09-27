//
//  CoinsView.swift
//  How Lucky
//
//  Created by Peyton White on 1/26/25.
//

import SwiftUI

struct CoinsView: View {
    @State var userCoins: Int // Initial coins
    @State var showCoinPopup: Bool = false // Controls visibility of coin change popup
    @State var coinChange: Int // Amount of coins won/lost temporarily
    @State var coinChangeColor: Color // Default to green for winning coins
    @State var icon:String //icocn to show what has changed
    @State var changePopUpText: String
    
    var body: some View {
        VStack {
            // Coin Display
            HStack {
                Text("\(userCoins)")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(getInsideTextColor())
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(getInsideTextColor())
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: getBackgroundColor(),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            
            
            // Coin Change Pop-Up
            if showCoinPopup {
                HStack {
                    Text(coinChange > 0 ? "+\(coinChange) \(changePopUpText)" : "\(coinChange) \(changePopUpText)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(coinChangeColor)
                        .transition(.scale.combined(with: .opacity)) // Animation for appearance
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                )
                .padding(.top, 10)
            }
            
            // Test Buttons
            /*
            HStack {
                Button("Win +5 Coins") {
                    updateCoins(by: 5) // Simulate winning coins
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Lose -3 Coins") {
                    updateCoins(by: -3) // Simulate losing coins
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            */
            
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showCoinPopup = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    updateCoins(by: coinChange)

                }
                
            }
        }
    }
    
    private func getBackgroundColor() -> Gradient {
        switch icon {
        case "c.circle":
            return Gradient(colors: [Color.orange.opacity(0.6), Color.orange])
        case "circlebadge.fill":
            return Gradient(colors: [coinChangeColor.opacity(0.6), coinChangeColor])
        default:
            return Gradient(colors: [coinChangeColor.opacity(0.6), coinChangeColor])
        }
    }

    private func getInsideTextColor() -> Color {
        switch icon {
        case "c.circle":
            return .yellow
        case "circlebadge.fill":
            return .white
        default:
            return .white
        }
    }
    
    // Function to Update Coins and Handle Animation
    private func updateCoins(by amount: Int) {
        coinChange = amount
        if(icon == "circlebadge.fill") {
            
        } else {
            coinChangeColor = amount > 0 ? .green : .red // Green for win, red for loss
        }
        showCoinPopup = true // Show the coin change popup
        
        // Animate the coin change
        withAnimation(.easeInOut(duration: 0.8)) {
            userCoins += amount
        }
        
        // Hide the popup after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCoinPopup = false
            }
        }
    }
}



#Preview {
    CoinsView(userCoins: 100, showCoinPopup: false, coinChange: 20, coinChangeColor: .green,
              icon:"circlebadge.fill",
              changePopUpText: "Circles")
}
