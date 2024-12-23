//
//  PowerUpSheetView.swift
//  How Lucky
//
//  Created by Peyton White on 11/2/24.
//

import SwiftUI
import GoogleMobileAds

struct PowerUpSheetView: View {
    @Environment(\.dismiss) var dismiss
    var function: (_ powerUp: PowerUp) -> Void
    let powerUps: [PowerUp]
    let freePassPowerUp: PowerUp
    @State private var viewOptionsIsShown = false
    
    @Bindable var user: User

    @Environment(\.colorScheme) var colorScheme

    
    
    var body: some View {
        NavigationView {
            VStack {
                
                HStack() {
                    Spacer()
                    HStack {
                        Image(systemName: "c.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.yellow)

                        Text("\(user.coins ?? 0)")
                            .font(.largeTitle)
                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(.clear)
                            )
                        
                    }
                    .padding(.horizontal,6)
                    .padding(.vertical,3)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                               .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth:1)
                    }
                    //Spacer()
                     
                }
                .padding(.horizontal,20)
                
                FreePassButton(freePassPowerUp: freePassPowerUp, action: handlePowerUpSelection,
                               isDisabled: isPowerUpDisabled(powerUp: freePassPowerUp))
                
                PowerUpGrid(powerUps: powerUps, action: handlePowerUpSelection, user:user)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Power Ups")
            .toolbar {
                ToolbarButtonView(
                    viewOptionsIsShown: $viewOptionsIsShown,
                    dismissAction: dismiss
                )
            }
        }
    }

    private func handlePowerUpSelection(_ powerUp: PowerUp) {
        function(powerUp)
        dismiss()
    }
}

private extension PowerUpSheetView {
    
    func isPowerUpDisabled(powerUp:PowerUp) -> Bool {
        if(powerUp.isLocked) {
            return true
        } else if(powerUp.costOfCoins > user.coins ?? 0) {
            powerUp.isLocked = true
            return true
        }
        
        powerUp.isLocked = false
        return false
    }
    
}

// MARK: - Free Pass Button View
struct FreePassButton: View {
    let freePassPowerUp: PowerUp
    let action: (PowerUp) -> Void
    let isDisabled: Bool

    var body: some View {
        HStack {
            Button {
                action(freePassPowerUp)
            } label: {
                PowerUpView(powerUp: freePassPowerUp, isMaxWidth: true)
            }
            .disabled(isDisabled)
            .padding()
        }
    }
}

// MARK: - PowerUp Grid View
struct PowerUpGrid: View {
    let powerUps: [PowerUp]
    let action: (PowerUp) -> Void
    let user:User

    var body: some View {
        VStack {
            ForEach(powerUps.chunked(into: 3), id: \.self) { row in
                HStack(spacing: 7) {
                    ForEach(row, id: \.id) { powerUp in
                        PowerUpButton(powerUp: powerUp, action: action, isDisabled: isPowerUpDisabled(powerUp: powerUp))
                    }
                    if row.count < 3 {
                        SpacerView(spacing: 0)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
    
    func isPowerUpDisabled(powerUp:PowerUp) -> Bool {
        if(powerUp.isLocked) {
            return true
        } else if(powerUp.costOfCoins > user.coins ?? 0) {
            powerUp.isLocked = true
            return true
        }
        
        powerUp.isLocked = false
        return false
    }
    
}

// MARK: - PowerUp Button View
struct PowerUpButton: View {
    let powerUp: PowerUp
    let action: (PowerUp) -> Void
    let isDisabled: Bool

    var body: some View {
        Button {
            action(powerUp)
        } label: {
            PowerUpView(powerUp: powerUp, isMaxWidth: false)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Spacer View for PowerUp Grid Alignment
struct SpacerView: View {
    let spacing: Int
    
    var body: some View {
        ForEach(0..<spacing, id: \.self) { _ in
            Color.clear
                .frame(width: 75, height: 75)
        }
    }
}

// MARK: - Toolbar Button View
struct ToolbarButtonView: View {
    @Binding var viewOptionsIsShown: Bool
    let dismissAction: DismissAction
    
    var body: some View {
        HStack {
            Button("Explain") {
                viewOptionsIsShown = true
            }
            .popover(isPresented: $viewOptionsIsShown, arrowEdge: .top) {
                PopoverView()
            }
            
            Button("Cancel") {
                dismissAction()
            }
        }
    }
}

// MARK: - Popover View for Explanation
struct PopoverView: View {
    var body: some View {
        ZStack {
            Text("Hold down a powerUp to get more info")
                .presentationCompactAdaptation(.popover)
                .foregroundStyle(.blue)
                .frame(width: 200, height: 100)
        }
        .padding()
    }
}

// MARK: - Array Extension for Chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    PowerUpSheetView(
        function: { _ in },
        powerUps: MockData.circlePowerUps,
        freePassPowerUp: MockData.freePassPowerUp,
        user: MockData.defUser
    )
}
