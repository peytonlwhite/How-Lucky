import SwiftUI

struct BetPopUpView: View {
    let useOffset: Bool
    let userCoins: Int // User coins amount
    let bettingOnText: LocalizedStringKey
    let bettingRulesText: String
    let cancelButtonText: String
    let titleText: String
    @Binding var isActive: Bool
    let odds: CGFloat // Odds for the bet
    let action: (_ isYes: Bool, _ betAmount: Int?) -> Void // Bet action handler
    
    @State private var offset: CGFloat = 1000
    @State private var betAmount: String = "" // User input for bet amount
    @State private var errorMessage: String = ""
    @State private var isShowingInfoSheet = false // To handle the info button sheet
    @FocusState private var isKeyboardActive: Bool // For managing keyboard focus
    
    var body: some View {
        ZStack {
            // Background dimmed overlay
            Color(.black)
                .opacity(0.3)
                .cornerRadius(8)
                .onTapGesture {
                    close()
                }
            
            // Popup content
            VStack(spacing: 16) {
                // Top row: Coins on the left and Info button on the right
                HStack {
                    HStack {
                        Text("\(userCoins)")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.yellow)
                        Image(systemName: "c.circle")
                            .font(.title3)
                            .foregroundStyle(.yellow)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange.opacity(0.6), Color.orange]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    .padding(.leading, 10)
                    
                }
                .padding(.top, 10)
                
                HStack {
                    Text(titleText)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.black)
                    
                    Button {
                        isShowingInfoSheet.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }
           
                
                // Display current odds
                VStack(spacing: 4) {
                    Text("Current Odds")
                        .font(.title3)
                        .foregroundStyle(.black)
                    
                    Text("\(formatOddsToFraction(odds))")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.blue)
                }
                
                // Bet amount input and winnings
                VStack(spacing: 8) {
                    HStack {
                        Text("Bet Amount:")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        TextField("Enter coins", text: $betAmount)
                            .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle for better customization
                            .keyboardType(.numberPad)
                            .frame(width: 125, height: 40) // Adjust width and height
                            .padding(8) // Add inner padding
                            .font(.title2) // Increase font size
                            .foregroundColor(.black) // Ensure text is always black
                            .multilineTextAlignment(.center)
                            .focused($isKeyboardActive)
                            .background(
                                RoundedRectangle(cornerRadius: 12) // Use a rounded rectangle for better styling
                                    .fill(Color.white) // Ensure the background is always white
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2) // Add shadow
                            )
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    Button("Done") {
                                        isKeyboardActive = false
                                    }
                                }
                            }
                           
                    }
                    
                    // Calculate and show potential winnings
                    if let bet = Int(betAmount) {
                        Text("Potential Winnings: \(String(format: "%.2f", CGFloat(bet) * odds)) coins")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                        Text("Potential Payout: \(String(format: "%.2f",CGFloat(bet) + CGFloat(bet) * odds)) coins")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                    
                    if !errorMessage.isEmpty {
                        Text("\(errorMessage)")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
                
                // Buttons for Cancel and Bet
                HStack(spacing: 16) {
                    Button {
                        action(false, nil)
                        close()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.gray)
                            
                            Text(cancelButtonText)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .frame(height: 50)
                    }
                    
                    Button {
                        if let bet = Int(betAmount), bet > 0 {
                            getErrorMessage()
                            if errorMessage.isEmpty {
                                action(true, bet)
                                close()
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.blue)
                            
                            Text("Bet")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .frame(height: 50)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(alignment: .topTrailing) {
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.medium)
                        .tint(.black)
                        .padding()
                }
            }
            .shadow(radius: 20)
            .padding(30)
            .offset(x: 0, y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
            .onChange(of: isKeyboardActive) {
                withAnimation {
                    if(useOffset) {
                        offset = isKeyboardActive ? -150 : 0 // Adjust offset when keyboard is active
                    }
                }
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isShowingInfoSheet) {
            VStack(spacing: 20) {
                Text("What Am I Betting On?")
                    .font(.title)
                    .bold()
                
                ScrollView {
                    Text(bettingOnText)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Text("Betting Rules")
                    .font(.title)
                    .bold()
                
                Text(bettingRulesText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Close") {
                    isShowingInfoSheet = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

private extension BetPopUpView {
    func close() {
        withAnimation(.spring()) {
            offset = 1000
            isActive = false
        }
    }
    
    func getErrorMessage() {
        if let bet = Int(betAmount), bet > userCoins {
            errorMessage = "Not Enough Coins"
        } else {
            errorMessage = ""
        }
    }
    
    func formatOddsToFraction(_ odds: CGFloat) -> String {
        let roundedOdds = round(odds * 10) / 10
        if roundedOdds > 1 {
            return "\(Int(roundedOdds)) to 1"
        } else if roundedOdds == 1 {
            return "1 to 1"
        } else {
            let invertedOdds = 1 / roundedOdds
            return "1 to \(Int(invertedOdds))"
        }
    }
}

#Preview {
    BetPopUpView(useOffset: true, userCoins: 10, bettingOnText: MockData.luckyCirclesBetDescription, bettingRulesText: "Betting rules text",
                 cancelButtonText: "Cancel",
                 titleText:"Win Some Coins!",
                 isActive: .constant(true), odds: 2.0,  action: { isYes, betAmount in })
}
