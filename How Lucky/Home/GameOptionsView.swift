//
//  GameOptionsView.swift
//  How Lucky
//
//  Created by Peyton White on 10/29/24.
//

import SwiftUI
import SwiftData
import os.log
import GoogleMobileAds

struct GameOptionsView: View {
    
    @Environment(\.modelContext) var context
    //For UI work non prod
    //var users: [User] = [MockData.defUser]
    @Query var users: [User]
    @State var showingPopupCoins: Bool = false
    
    let logger = Logger(subsystem: "com.peyton.white", category: "Debug")
    
    
    //MARK: - ad properties
    @StateObject var rewardViewModel = RewardedViewModel()
    
    
    struct BannerAdView: UIViewRepresentable {
        var bannerView: GADBannerView
        
        func makeUIView(context: Context) -> GADBannerView {
            return bannerView
        }
        
        func updateUIView(_ uiView: GADBannerView, context: Context) {
            // Any updates can be handled here.
        }
    }
    
    
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(alignment:.leading, spacing: 1) {
                    Text("Lucky Logic")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Image("cloverLogo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 300)

                }
                .padding(.top,30)
                
                
                
                
                NavigationLink {
                    UserScoresView(user:users[0])
                } label: {
                    GameLabelView(label: "Personal Scores", description: "Scores & Records in games", color: Color(hex: "#FF6B6B"))
                }
                
                NavigationLink {
                    LuckySquaresGameBoard(user:users[0], powerUps: getPowerUps(game:"1"))
                } label: {
                    GameLabelView(label: "Lucky Squares",description: MockData.luckySquaresDescription, color: Color(hex: "#FFD93D"))
                }
                
                NavigationLink {
                    LuckyCirclesGameBoard(user:users[0], powerUps: getPowerUps(game:"2"))
                } label: {
                    GameLabelView(label: "Lucky Circles", description: MockData.luckyCirclesDescription, color: Color(hex: "#4ECDC4"))
                }
                /*
                 NavigationLink {
                 LuckyShapesGameBoard(user:users[0], powerUps: getPowerUps(game:"3"))
                 } label: {
                 GameLabelView(label: "Lucky Patterns", description: "A pattern will flash. You follow that pattern", color: Color(hex: "#03fc88"))
                 }
                 */
                
                
                VStack {
                    Spacer()
                    // Ad Banner
                    if rewardViewModel.isBannerAdLoaded {
                        BannerAdView(bannerView: rewardViewModel.getBannerAdView())
                            .frame(width: UIScreen.main.bounds.width, height: 40)
                            .padding(.bottom, 20)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                }
                .toolbar {
                    // Toolbar Buttons
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Action for trailing button
                            increaseUserCoins()
                        }) {
                            // Coin Display
                            HStack {
                                Text("\(users[0].coins!)")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .bold()
                                    .foregroundStyle(.yellow)
                                Image(systemName: "c.circle")
                                    .font(.title3)
                                    .foregroundStyle(.yellow)
                            }
                            .padding(5)
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
                            
                        }
                    }
                }
                
                
                
                
            }
            
            
            if showingPopupCoins {
                CustomDialog(isActive: $showingPopupCoins, title: "Free Coins", message: "Thanks for playing here are 5 free coins", buttonTitle: "Thanks, bye") {
                }
            }
        }
        .onAppear {
            logger.notice("\("TEST", privacy: .public)")
            logger.log("Appear")
            rewardViewModel.loadBannerAd()
            
            if(users.count > 0) {
                checkUserChecks()
            }
        }
        
    }
    
}

struct GameLabelView: View {
    var label: String
    var description: LocalizedStringKey
    var color: Color
    @State var viewOptionsIsShown = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack {
                Text(label)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                Button {
                    viewOptionsIsShown = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
        }
        .frame(height: 60)
        .frame(maxWidth: 300)
        .background(
            LinearGradient(gradient: Gradient(colors: [color, color.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .cornerRadius(15)
                .shadow(radius: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
        )
        .scaleEffect(viewOptionsIsShown ? 1.1 : 1) // Add a slight scale effect on press
        .animation(.spring(), value: viewOptionsIsShown)
        .padding(.horizontal, 20)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.6)
                .onEnded { _ in
                    viewOptionsIsShown = true
                }
        )
        .popover(isPresented: $viewOptionsIsShown, arrowEdge: .top) {
            ZStack {
                // Display the rules as Text
                ScrollView {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(colorScheme == .dark ? .white :  .black)
                        .padding()
                }
                
            }
            .padding()
        }
    }
}


private extension GameOptionsView {
    
    func increaseUserCoins() {
        if(users[0].coins! < 25) {
            users[0].coins = users[0].coins! + 1
        }
    }
    
    func increaseUserCoinsByAmount(amount:Int) {
            users[0].coins = users[0].coins! + amount
    }
    
    func getPowerUps(game:String) -> [PowerUp] {
        if(game=="1") {
            return MockData.squarePowerUps
        } else if(game == "2") {
            return MockData.circlePowerUps
        } else if(game == "3") {
            return MockData.patternPowerUps
        }
        return []
    }
    
    func checkUserChecks() {
        
        let currentDate = Date()
        
        guard let diffInHours = Calendar.current.dateComponents([.hour, .minute], from: users[0].appLastOpened!, to: currentDate).hour
        else { return }
        
        
        logger.info("curent date: \(currentDate)")
        logger.info("users[0].appLastOpened: \(String(describing: users[0].appLastOpened))")
        logger.info("diff in hours \(diffInHours)")
        
        //if first time opened or been more than a day give them coins and reset date
        if(diffInHours > 23) {
            logger.info("show pop up coins")
            showingPopupCoins = true
            users[0].appLastOpened = currentDate
            users[0].coins = users[0].coins! + 5
            logger.info("users[0].appLastOpened after set: \(String(describing: users[0].appLastOpened))")
        }
        
    }
    
}

// Hex Color Initializer for SwiftUI Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8 * 17), (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    GameOptionsView()//.modelContainer(for: User.self)
}
