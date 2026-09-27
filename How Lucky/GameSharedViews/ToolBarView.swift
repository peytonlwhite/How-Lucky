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


    var body: some View {
        HStack { // Wrap everything in an HStack
            if showBets {
                Button("Bet") {
                    showingBetPopUp.toggle()
                }
            }

            Button("Power Ups") {
                showingPowerUpSheet.toggle()
            }
            .sheet(isPresented: $showingPowerUpSheet) {
                PowerUpSheetView(
                    function: powerUpChosen,
                    powerUps: powerUps,
                    freePassPowerUp: freePassPowerUp,
                    user: user
                )
            }

            .sheet(isPresented: $showingTriviaSheet) {
                TriviaSheetView(function: triviaDone, user: user, mainGameType: mainGameType)
                    .environmentObject(triviaManager)
            }
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
