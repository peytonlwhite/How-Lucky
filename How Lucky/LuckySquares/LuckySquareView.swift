import SwiftUI

struct LuckySquareView: View {
    var square: LuckySquare
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var tint: Color { square.isFlashing ? .green : GamePalette.squares }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(square.isDisabled && !square.isFlashing ? Color(uiColor: .tertiarySystemFill) : tint.opacity(0.12))
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(tint.opacity(square.isDisabled && !square.isFlashing ? 0.12 : 0.45), lineWidth: square.isFlashing ? 3 : 1.5)
            VStack(spacing: 5) {
                Image(systemName: square.isFlashing ? "checkmark.circle.fill" : square.isDisabled ? "xmark" : "sparkle")
                    .font(.caption.weight(.semibold))
                Text(square.name).font(.system(.title2, design: .rounded, weight: .bold)).minimumScaleFactor(0.7)
            }
            .foregroundStyle(square.isDisabled && !square.isFlashing ? Color.secondary : tint)
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: square.isFlashing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Square \(square.name)")
        .accessibilityValue(square.isFlashing ? "Winning square" : square.isDisabled ? "Already tried" : "Available")
    }
}

#Preview {
    HStack {
        LuckySquareView(square: LuckySquare(id: "1", name: "1", color: .red, isDisabled: false))
        LuckySquareView(square: LuckySquare(id: "2", name: "2", color: .red, isDisabled: true))
        LuckySquareView(square: LuckySquare(id: "3", name: "3", color: .red, isDisabled: false, isFlashing: true))
    }.padding()
}
