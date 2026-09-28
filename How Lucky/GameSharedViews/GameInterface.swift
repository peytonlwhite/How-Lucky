import SwiftUI

enum GamePalette {
    static let squares = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1, green: 0.49, blue: 0.43, alpha: 1)
            : UIColor(red: 0.78, green: 0.20, blue: 0.18, alpha: 1)
    })
    static let circles = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.30, green: 0.82, blue: 0.76, alpha: 1)
            : UIColor(red: 0, green: 0.43, blue: 0.43, alpha: 1)
    })
    static let canvas = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
}

struct GameDashboard: View {
    let score: Int
    let best: Int
    let guesses: Int
    let pieces: Int
    let pieceName: String
    let coins: Int
    let accent: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(score, format: .number)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .contentTransition(.numericText())
                    .accessibilityLabel("Score \(score)")
                Text("score").font(.subheadline).foregroundStyle(.secondary)
                Spacer(minLength: 12)
                Text("\(guesses) \(guesses == 1 ? "guess" : "guesses") left")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
            }
            HStack {
                Text("Best \(best) · \(pieces) \(pieceName)")
                Spacer(minLength: 8)
                Label(coins.formatted(), systemImage: "c.circle")
                    .accessibilityLabel("\(coins) coins")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .monospacedDigit()
        .padding(.horizontal, 4)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: score)
        .accessibilityElement(children: .contain)
    }
}

struct GameNotice: View {
    let text: String
    var symbol = "sparkles"
    var tint: Color = .secondary

    var body: some View {
        Label(text, systemImage: symbol)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, minHeight: 28, alignment: .center)
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)
    }
}

struct GameRulesSheet: View {
    let title: String
    let rules: LocalizedStringKey
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView { Text(rules).frame(maxWidth: .infinity, alignment: .leading).padding(24) }
                .background(GamePalette.canvas)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

#Preview("Game dashboard") {
    VStack(spacing: 20) {
        GameDashboard(score: 450, best: 1200, guesses: 2, pieces: 24, pieceName: "squares", coins: 315, accent: GamePalette.squares)
        GameDashboard(score: 150, best: 900, guesses: 6, pieces: 250, pieceName: "circles", coins: 315, accent: GamePalette.circles)
    }.padding().background(GamePalette.canvas)
}
