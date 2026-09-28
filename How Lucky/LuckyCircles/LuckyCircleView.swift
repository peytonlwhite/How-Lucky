import SwiftUI

struct LuckyCircleView: View {
    let circle: LuckyCircle
    // Only true during the end-of-round reveal, never during live play.
    let isCorrect: Bool
    var onTap: () -> Void

    var body: some View {
        Circle()
            .fill(circle.color.gradient)
            .overlay { Circle().strokeBorder(.white.opacity(0.65), lineWidth: 1.5) }
            .overlay {
                if isCorrect {
                    Image(systemName: "checkmark").font(.system(size: max(12, circle.size / 3), weight: .heavy))
                        .foregroundStyle(.white).shadow(color: .black.opacity(0.6), radius: 2)
                }
            }
            .shadow(color: circle.color.opacity(0.2), radius: 3, y: 2)
            .frame(width: circle.size, height: circle.size)
            .contentShape(Circle())
            .position(circle.position)
            .opacity(circle.isDisabled ? 0.25 : 1)
            .onTapGesture { if !circle.isDisabled { onTap() } }
            .accessibilityLabel("Circle \(circle.name)")
            .accessibilityValue(isCorrect ? "Winning circle" : "Available")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { if !circle.isDisabled { onTap() } }
    }
}
