import SwiftUI

struct PowerUpView: View {
    let powerUp: PowerUp
    let isMaxWidth: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: powerUp.isLocked ? "lock.fill" : "bolt.fill")
                    .foregroundStyle(powerUp.isLocked ? Color.secondary : Color.orange)
                Spacer()
                Text(powerUp.isLocked ? "Used" : powerUp.costOfCoins == 0 ? "Free" : "\(powerUp.costOfCoins) coins")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(powerUp.name).font(.headline).foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Text(powerUp.description).font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: isMaxWidth ? 90 : 155, alignment: .topLeading)
        .background(GamePalette.surface, in: RoundedRectangle(cornerRadius: 18))
        .overlay { RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.06), lineWidth: 1) }
        .opacity(powerUp.isLocked ? 0.55 : 1)
        .accessibilityElement(children: .combine)
    }
}
