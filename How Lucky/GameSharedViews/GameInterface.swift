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
    var compact = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
        if compact {
            HStack(spacing: 16) {
                compactMetric(value: score, title: "Score")
                compactMetric(value: best, title: "Best")
                compactMetric(value: guesses, title: "Guesses")
                compactMetric(value: pieces, title: pieceName.capitalized)
                compactMetric(value: coins, title: "Coins")
            }
        } else {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CURRENT SCORE").font(.caption2.weight(.bold)).tracking(1.4).foregroundStyle(.secondary)
                    Text(score, format: .number)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Label("Best \(best)", systemImage: "trophy.fill")
                        .font(.caption.weight(.medium)).foregroundStyle(.secondary)
                }
                Spacer(minLength: 12)
                Label(coins.formatted(), systemImage: "c.circle.fill")
                    .font(.subheadline.weight(.bold)).monospacedDigit()
                    .padding(.horizontal, 12).padding(.vertical, 9)
                    .background(Color.orange.opacity(0.12), in: Capsule())
                    .accessibilityLabel("\(coins) coins available")
            }
            HStack(spacing: 10) {
                metric(value: guesses, label: guesses == 1 ? "guess left" : "guesses left", symbol: "hand.tap.fill")
                metric(value: pieces, label: pieceName, symbol: pieceName == "squares" ? "square.grid.2x2.fill" : "circle.grid.3x3.fill")
            }
        }
        }
        }
        .padding(compact ? 12 : 18)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: score)
        .background(GamePalette.surface, in: RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 3).fill(accent).frame(width: 28, height: 4).padding(.trailing, 20)
        }
        .accessibilityElement(children: .contain)
    }

    private func compactMetric(value: Int, title: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value, format: .number).font(.system(.headline, design: .rounded)).monospacedDigit()
            Text(title).font(.caption2).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
    }

    private func metric(value: Int, label: String, symbol: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).foregroundStyle(accent).accessibilityHidden(true)
            Text("\(value)").font(.headline).monospacedDigit()
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
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
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.horizontal, 14)
            .background(tint.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
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
