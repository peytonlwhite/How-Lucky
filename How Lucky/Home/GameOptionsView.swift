//
//  GameOptionsView.swift
//  How Lucky
//
//  Created by Peyton White on 10/29/24.
//

import SwiftUI
import SwiftData
import os.log

struct GameOptionsView: View {
    
    @Environment(\.modelContext) var context
    @Query var users: [User]
    @State var showingPopupCoins: Bool = false

    let logger = Logger(subsystem: "com.peyton.white", category: "Debug")

   
    var body: some View {
        
        ZStack {
            NavigationStack {
               
                VStack(alignment:.leading, spacing: 1) {
                    Text("How Lucky")
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
                    GameLabelView(label: "Lucky Squares",description: "Only one square is the correct choice each turn. The square changes at random each guess. Use Power Ups and luck to break highscores", color: Color(hex: "#FFD93D"))
                }
                
                NavigationLink {
                    LuckyCirclesGameBoard(user:users[0], powerUps: getPowerUps(game:"2"))
                } label: {
                    GameLabelView(label: "Lucky Circles", description: "Only one circle is the correct choice each turn. Use Power Ups and luck to break highscores", color: Color(hex: "#4ECDC4"))
                }
                
                NavigationLink {
                    LuckyShapesGameBoard(user:users[0], powerUps: getPowerUps(game:"3"))
                } label: {
                    GameLabelView(label: "Lucky Patterns", description: "A pattern will flash. You follow that pattern", color: Color(hex: "#03fc88"))
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
          
            if(users.count > 0) {
                checkUserChecks()
            }
        }
        
    }
    
}

struct GameLabelView: View {
    var label: String
    var description: String
    var color: Color
    @State var viewOptionsIsShown = false

    var body: some View {
        VStack {
            Text(label)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 200, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(color)
                )
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.6)
                .onEnded {_ in
                    viewOptionsIsShown = true
                }
        )
        .popover(isPresented: $viewOptionsIsShown, arrowEdge: .top) {
            ZStack {
                Text("\(description)")
                    .presentationCompactAdaptation(.popover)
                    .foregroundStyle(.gray)
                    .frame(height:100)
            }
            .padding()
        }
      
    }
}


private extension GameOptionsView {
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
        
        print("user checks")
        
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
