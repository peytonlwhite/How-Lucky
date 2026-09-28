//
//  ToolBarView.swift
//  How Lucky
//
//  Created by Peyton White on 11/11/24.
//

import SwiftUI

struct ToolbarView: View {
    @Binding var showingPowerUpSheet: Bool
    @Binding var showingTriviaSheet: Bool
    @Binding var showingBetPopUp: Bool

    let powerUps: [PowerUp]
    let freePassPowerUp: PowerUp
    let powerUpChosen: (PowerUp) -> Void
    let triviaDone: (Bool) -> Void
    let triviaManager: TriviaManager
    let showBets:Bool
    @Bindable var user: User
    let mainGameType: MainGameType
    var hasActiveBet: Bool = false
    var triviaCancelled: () -> Void = {}
    @State private var pendingPowerUp: PowerUp?


    private var accent: Color { mainGameType == .squares ? GamePalette.squares : GamePalette.circles }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 12) {
                Button { showingBetPopUp = true } label: {
                    Label(hasActiveBet ? "Manage bet" : "Bet coins", systemImage: "c.circle")
                        .font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.plain)
                .foregroundStyle(accent)
                .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                .disabled(!showBets)
                .opacity(showBets ? 1 : 0.45)

                Button { showingPowerUpSheet = true } label: {
                    Label("Power-ups", systemImage: "bolt.fill")
                        .font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .background(accent, in: RoundedRectangle(cornerRadius: 16))
                .disabled(hasActiveBet)
                .opacity(hasActiveBet ? 0.45 : 1)
            }
            if hasActiveBet || !showBets {
                Text(hasActiveBet ? "Finish or cancel your bet to use power-ups." : "Finish Two Guesses before placing a bet.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingPowerUpSheet, onDismiss: {
            guard let selection = pendingPowerUp else { return }
            pendingPowerUp = nil
            powerUpChosen(selection)
        }) {
            PowerUpSheetView(function: { selection in
                if pendingPowerUp == nil { pendingPowerUp = selection }
            }, powerUps: powerUps, freePassPowerUp: freePassPowerUp, user: user)
        }
        .sheet(isPresented: $showingTriviaSheet) {
            TriviaSheetView(function: triviaDone, user: user, mainGameType: mainGameType, onLoadCancelled: triviaCancelled)
                .environmentObject(triviaManager)
        }
    }
}

#Preview {
    ToolbarView(showingPowerUpSheet: Binding.constant(false), showingTriviaSheet: Binding.constant(false),showingBetPopUp:Binding.constant(false), powerUps: [], freePassPowerUp: MockData.freePassPowerUp, powerUpChosen: { PowerUp in
        //nothing
    }, triviaDone: { Bool in
        //nothing
    }, triviaManager: TriviaManager(), showBets: true,
                user:MockData.defUser, mainGameType: MainGameType.squares)
}
