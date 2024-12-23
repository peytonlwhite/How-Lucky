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
    let powerUps: [PowerUp]
    let freePassPowerUp: PowerUp
    let powerUpChosen: (PowerUp) -> Void
    let triviaDone: (Bool) -> Void
    let typeOfTriva: String
    let triviaManager: TriviaManager
    @Bindable var user: User

    var body: some View {
        Button("Power Ups") {
            showingPowerUpSheet.toggle()
        }
        .sheet(isPresented: $showingPowerUpSheet) {
            PowerUpSheetView(
                function: powerUpChosen,
                powerUps: powerUps,
                freePassPowerUp: freePassPowerUp,
                user:user
            )
        }
        .sheet(isPresented: $showingTriviaSheet) {
            TriviaSheetView(function: triviaDone, type: typeOfTriva)
                .environmentObject(triviaManager)
        }
    }
}

#Preview {
    ToolbarView(showingPowerUpSheet: Binding.constant(false), showingTriviaSheet: Binding.constant(false), powerUps: [], freePassPowerUp: MockData.freePassPowerUp, powerUpChosen: { PowerUp in
        //nothing
    }, triviaDone: { Bool in
        //nothing
    }, typeOfTriva: "mania", triviaManager: TriviaManager(),
                user:MockData.defUser)
}
