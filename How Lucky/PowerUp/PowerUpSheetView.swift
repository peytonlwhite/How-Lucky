import SwiftUI

struct PowerUpSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    var function: (PowerUp) -> Void
    let powerUps: [PowerUp]
    let freePassPowerUp: PowerUp
    @Bindable var user: User
    @State private var hasSelected = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Give your luck a boost.").font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                        Label("\(user.coins ?? 0)", systemImage: "c.circle.fill").font(.headline).monospacedDigit()
                    }
                    powerUpButton(freePassPowerUp, featured: true)
                    Text("CHOOSE A POWER-UP").font(.caption.weight(.bold)).tracking(1.2).foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: typeSize.isAccessibilitySize ? 280 : 150), spacing: 12)], alignment: .leading, spacing: 12) {
                        ForEach(powerUps) { powerUp in powerUpButton(powerUp, featured: false) }
                    }
                }.padding(20)
            }
            .background(GamePalette.canvas)
            .navigationTitle("Power-ups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }

    private func powerUpButton(_ powerUp: PowerUp, featured: Bool) -> some View {
        let affordable = powerUp.costOfCoins <= (user.coins ?? 0)
        return Button {
            guard !hasSelected, !powerUp.isLocked, affordable else { return }
            hasSelected = true
            function(powerUp)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                PowerUpView(powerUp: powerUp, isMaxWidth: featured)
                if !affordable && !powerUp.isLocked {
                    Text("Need \(powerUp.costOfCoins - (user.coins ?? 0)) more coins")
                        .font(.caption2).foregroundStyle(.secondary).padding(.horizontal, 8)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(hasSelected || powerUp.isLocked || !affordable)
        .accessibilityHint(affordable ? "Use this power-up" : "Not enough coins")
    }
}
