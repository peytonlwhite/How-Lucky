import SwiftUI

struct BetPopUpView: View {
    let useOffset: Bool
    let userCoins: Int
    let bettingOnText: LocalizedStringKey
    let bettingRulesText: String
    let cancelButtonText: String
    let titleText: String
    @Binding var isActive: Bool
    let odds: CGFloat
    let action: (Bool, Int?) -> Void
    @State private var betAmount = ""
    @State private var errorMessage = ""
    @State private var isShowingInfoSheet = false
    @State private var hasSubmitted = false
    @FocusState private var isKeyboardActive: Bool

    private var quote: CoinBet? {
        guard let amount = Int(betAmount) else { return nil }
        return CoinBet(stake: amount, balance: userCoins, odds: Double(odds))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea().onTapGesture { close() }
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Make your pick count").font(.caption).foregroundStyle(.secondary)
                                Text(titleText).font(.title2.bold())
                            }
                            Spacer()
                            Button { close() } label: { Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(.secondary) }
                                .accessibilityLabel("Close betting")
                        }
                        HStack {
                            Label("\(userCoins) available", systemImage: "c.circle.fill")
                            Spacer()
                            Button { isShowingInfoSheet = true } label: { Image(systemName: "info.circle") }
                                .accessibilityLabel("Betting rules")
                        }.font(.subheadline.weight(.medium))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("NET ODDS").font(.caption2.weight(.bold)).tracking(1.2).foregroundStyle(.secondary)
                            Text(CoinBet.oddsLabel(Double(odds))).font(.system(.title, design: .rounded, weight: .bold))
                            Text("Your stake is reserved now. A win returns your stake plus winnings.")
                                .font(.caption).foregroundStyle(.secondary)
                        }.padding(16).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Coins to bet").font(.headline)
                            TextField("Enter an amount", text: $betAmount)
                                .keyboardType(.numberPad).focused($isKeyboardActive)
                                .font(.title2.monospacedDigit()).padding(14)
                                .background(GamePalette.canvas, in: RoundedRectangle(cornerRadius: 12))
                                .accessibilityLabel("Coins to bet")
                                .onChange(of: betAmount) { _, _ in errorMessage = "" }
                            HStack {
                                ForEach([5, 10, 25, 50], id: \.self) { amount in
                                    Button("\(amount)") { betAmount = String(amount); isKeyboardActive = false }
                                        .buttonStyle(.bordered).disabled(amount > userCoins)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        if let quote {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Profit").font(.caption).foregroundStyle(.secondary)
                                    Text("+\(quote.winnings)").font(.headline).monospacedDigit()
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Total returned on win").font(.caption).foregroundStyle(.secondary)
                                    Text("\(quote.payout) coins").font(.headline).monospacedDigit()
                                }
                            }
                        }
                        if !errorMessage.isEmpty { Text(errorMessage).font(.caption).foregroundStyle(.red) }
                        HStack(spacing: 12) {
                            Button(cancelButtonText) { action(false, nil); close() }
                                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                            Button("Place bet") { submit() }
                                .buttonStyle(.borderedProminent).frame(maxWidth: .infinity, minHeight: 44)
                                .disabled(hasSubmitted)
                        }
                    }.padding(22)
                }
                .frame(maxWidth: 440, maxHeight: min(620, max(0, geometry.size.height - 32)))
                .background(GamePalette.surface, in: RoundedRectangle(cornerRadius: 26))
                .padding(.horizontal, 16)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { isKeyboardActive = false } }
        }
        .sheet(isPresented: $isShowingInfoSheet) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(bettingOnText)
                        Text("Betting rules").font(.headline)
                        Text(bettingRulesText).foregroundStyle(.secondary)
                    }.padding(24)
                }
                .navigationTitle("Before you bet").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { isShowingInfoSheet = false } } }
            }
        }
    }

    private func close() { isKeyboardActive = false; isActive = false }

    private func submit() {
        guard !hasSubmitted else { return }
        guard let amount = Int(betAmount), amount > 0 else {
            errorMessage = "Enter a positive whole number of coins."
            return
        }
        guard let quote else {
            errorMessage = amount > userCoins ? "You do not have enough coins." : "This bet is too large."
            return
        }
        hasSubmitted = true
        action(true, quote.stake)
        close()
    }
}
