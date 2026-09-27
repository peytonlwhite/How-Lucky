//
//  UserScores.swift
//  How Lucky
//
//  Created by Peyton White on 10/29/24.
//

import SwiftUI

struct ItemA: Identifiable {
    let id = UUID()
    let title: String
    let details: String
}

struct ItemB: Identifiable {
    let id = UUID()
    let title: String
    let details: String
}

struct ItemC: Identifiable {
    let id = UUID()
    let title: String
    let details: String
}

struct ItemD: Identifiable {
    let id = UUID()
    let title: String
    let details: String
}


struct ItemE: Identifiable {
    let id = UUID()
    let title: String
    let details: String
}

struct ItemF: Identifiable {
    let id = UUID()
    let title: String
    let details: String
}

struct ItemG: Identifiable {
    let id = UUID()
    let title: String
    let details: String
}

struct UserScoresView: View {
    
    @Bindable var user:User
    
    var list: [String] = ["Lucky Squares", "Lucky Circles", "Lucky Patterns"]
    @State private var showPopover = false
    @State private var isPressedStats = false
    @State private var isPressedCoins = false

    
    @State private var isExpandedA = true
    @State private var isExpandedB = false
    @State private var isExpandedC = false
    @State private var isExpandedD = false
    @State private var isExpandedE = false
    @State private var isExpandedF = false
    @State private var isExpandedG = true
    
    
    let itemA: ItemA = ItemA(title: "Lucky Squares", details: "")
    let itemB: ItemB = ItemB(title: "Lucky Circles", details: "")
    let itemC: ItemC = ItemC(title: "Power Up Stats", details: "")
    let itemD: ItemD = ItemD(title: "Power Up Stats", details: "")
    
    let itemE: ItemE = ItemE(title: "Lucky Patterns", details: "")
    let itemF: ItemF = ItemF(title: "Power Up Stats", details: "")
    
    let itemG: ItemG = ItemG(title: "Personal Stats", details: "")

    
    var body: some View {
        
        VStack {
            Text("High Scores")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            HStack {
                HStack {
                    Button {
                        // Reset Stats action
                        resetAllStats()
                    } label: {
                        HStack {
                            Text("Reset Stats")
                                .padding()
                                .foregroundColor(.black)
                        }
                        .font(.headline)
                        .padding(3)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                        .scaleEffect(isPressedStats ? 0.95 : 1.0)  // Button press animation
                        .animation(.easeInOut(duration: 0.2), value: isPressedStats) // Animation when pressed
                    }
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                        isPressedStats = isPressing
                    }, perform: {})
                    
                    Button(action: {
                        // Reset Coins action
                        resetCoins()
                    }) {
                        HStack(spacing:0) {
                            Text("Reset Coins")
                                .padding()
                                .foregroundColor(.black)
                            
                            Image(systemName: "questionmark.circle")
                                .onTapGesture {
                                    showPopover.toggle()
                                }
                        }
                        .font(.headline)
                        .padding(.horizontal,10)
                        .padding(.vertical,3)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                        .scaleEffect(isPressedCoins ? 0.95 : 1.0)  // Button press animation
                        .animation(.easeInOut(duration: 0.2), value: isPressedCoins) // Animation when pressed
                    }
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                        isPressedCoins = isPressing
                    }, perform: {})
                    
                    .popover(isPresented: $showPopover, arrowEdge: .top) {
                        ZStack {
                            Text("Reset Coins to 300.")
                                .presentationCompactAdaptation(.popover)
                                .frame(height: 100)
                        }
                        .padding()
                    }
                }
            }
            
          
            
       
            ScrollView {
                VStack(spacing: 12) {
                    
                    // Accordion for Item G
                    VStack {
                        HStack {
                            Text(itemG.title)
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: isExpandedG ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                isExpandedG.toggle()
                            }
                        }
                        
                        if isExpandedG {
                            VStack(spacing: 8) {
                                // Highscore Row
                                InfoRow(label: "Coins", value: "\(user.coins ?? 0)")
                                InfoRow(label: "Stats Reset Used", value: "\(user.resetStatsUsed ?? 0)")
                                InfoRow(label: "Coins Reset Used", value: "\(user.resetCoinsUsed ?? 0)")
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .transition(.slide)
                        }
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                    
                    
                    
                    // Accordion for Item A
                    VStack {
                        HStack {
                            Text(itemA.title)
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: isExpandedA ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                isExpandedA.toggle()
                            }
                        }
                        
                        if isExpandedA {
                            VStack(spacing: 8) {
                                
                                // Total Times Played Row
                                InfoRow(label: "Total Times Played", value: "\(user.luckySquaresStats?.totalTimesPlayed ?? 0)")
                                
                                Divider() // Separates sections
                                
                                // Highscore Row
                                InfoRow(label: "Highscore", value: "\(user.luckySquaresStats?.highScore ?? 0)", valueColor: .green)
                                
                                // Power Ups Used Row
                                InfoRow(label: "Power Ups Used", value: "\(user.luckySquaresStats?.powerUpsUsedForHighscore ?? 0)")
                                
                                
                                // Total Times Incorrect in Row Row
                                InfoRow(label: "Opposite Highscore", value: "\(user.luckySquaresStats?.totalTimesIncorrectInRow ?? 0)", valueColor: .red)
                                
                                // coins stats
                                InfoRow(label: "Coins Wagered", value: "\(user.luckySquaresStats?.coinsWagered ?? 0)")
                                InfoRow(label: "Coins Won", value: "\(user.luckySquaresStats?.coinsWon ?? 0)",valueColor: .green)
                                InfoRow(label: "Coins Lost", value: "\(user.luckySquaresStats?.coinsLost ?? 0)",valueColor: .red)
                                
                                
                                Divider() // Separates sections
                                
                                
                                
                                
                                // Accordion for Item C
                                VStack {
                                    HStack {
                                        Text(itemC.title)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: isExpandedC ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        withAnimation {
                                            isExpandedC.toggle()
                                        }
                                    }
                                    
                                    if isExpandedC {
                                        ForEach(user.luckySquaresStats?.powerUpStats ?? [], id: \.self)  { stat in
                                            if(stat.isTrivia) {
                                                HStack {
                                                    Text("\(stat.name)")
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                    Text("\(stat.totalTimesUsed)")
                                                        .foregroundColor(.primary)
                                                    Text("\(stat.totalTriviaCorrects)")
                                                        .foregroundColor(.green)
                                                    Text("\(stat.totalTriviaInCorrects)")
                                                        .foregroundColor(.red)
                                                }
                                                .padding(.vertical, 4)
                                                
                                                // coins stats
                                                VStack {
                                                    InfoRow(label: "Coins Wagered", value: "\(stat.coinsWagered ?? 0)")
                                                    InfoRow(label: "Coins Won", value: "\(stat.coinsWon ?? 0)",valueColor: .green)
                                                    InfoRow(label: "Coins Lost", value: "\(stat.coinsLost ?? 0)",valueColor: .red)
                                                }
                                                .padding(.leading, 2)
                                                
                                            } else {
                                                InfoRow(label: "\(stat.name) Used ",
                                                        value: "\(stat.totalTimesUsed)")
                                            }
                                            
                                        }
                                    }
                                }
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                
                                
                                
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .transition(.slide)
                        }
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Accordion for Item B
                    VStack {
                        HStack {
                            Text(itemB.title)
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: isExpandedB ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                isExpandedB.toggle()
                            }
                        }
                        
                        if isExpandedB {
                            VStack(spacing: 8) {
                                
                                // Total Times Played Row
                                InfoRow(label: "Total Times Played", value: "\(user.luckyCirclesStats?.totalTimesPlayed ?? 0)")
                                
                                Divider() // Separates sections
                                
                                // Highscore Row
                                InfoRow(label: "Highscore", value: "\(user.luckyCirclesStats?.highScore ?? 0)", valueColor: .green)
                                
                                // Power Ups Used Row
                                InfoRow(label: "Power Ups Used", value: "\(user.luckyCirclesStats?.powerUpsUsedForHighscore ?? 0)")
                                
                                
                                // Total Times Incorrect in Row Row
                                InfoRow(label: "Opposite Highscore", value: "\(user.luckyCirclesStats?.totalTimesIncorrectInRow ?? 0)", valueColor: .red)
                                
                                // coins stats
                                InfoRow(label: "Coins Wagered", value: "\(user.luckyCirclesStats?.coinsWagered ?? 0)")
                                InfoRow(label: "Coins Won", value: "\(user.luckyCirclesStats?.coinsWon ?? 0)",valueColor: .green)
                                InfoRow(label: "Coins Lost", value: "\(user.luckyCirclesStats?.coinsLost ?? 0)",valueColor: .red)
                                
                                
                                Divider() // Separates sections
                                
                                
                                
                                
                                // Accordion for Item C
                                VStack {
                                    HStack {
                                        Text(itemD.title)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: isExpandedD ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        withAnimation {
                                            isExpandedD.toggle()
                                        }
                                    }
                                    
                                    if isExpandedD {
                                        ForEach(user.luckyCirclesStats?.powerUpStats ?? [], id: \.self)  { stat in
                                            if(stat.isTrivia) {
                                                HStack {
                                                    Text("\(stat.name)")
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                    Text("\(stat.totalTimesUsed)")
                                                        .foregroundColor(.primary)
                                                    Text("\(stat.totalTriviaCorrects)")
                                                        .foregroundColor(.green)
                                                    Text("\(stat.totalTriviaInCorrects)")
                                                        .foregroundColor(.red)
                                                }
                                                .padding(.vertical, 4)
                                                
                                                // coins stats
                                                VStack {
                                                    InfoRow(label: "Coins Wagered", value: "\(stat.coinsWagered ?? 0)")
                                                    InfoRow(label: "Coins Won", value: "\(stat.coinsWon ?? 0)",valueColor: .green)
                                                    InfoRow(label: "Coins Lost", value: "\(stat.coinsLost ?? 0)",valueColor: .red)
                                                }
                                                .padding(.leading, 2)
                                                
                                                
                                            } else {
                                                InfoRow(label: "\(stat.name) Used ",
                                                        value: "\(stat.totalTimesUsed)")
                                            }
                                            
                                        }
                                    }
                                }
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                
                                
                                
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .transition(.slide)
                        }
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Accordion for Item E
                    /*
                     VStack {
                     HStack {
                     Text(itemE.title)
                     .font(.headline)
                     .foregroundColor(.black)
                     Spacer()
                     Image(systemName: isExpandedE ? "chevron.up" : "chevron.down")
                     .foregroundColor(.gray)
                     }
                     .padding()
                     .background(Color.white)
                     .cornerRadius(10)
                     .onTapGesture {
                     withAnimation {
                     isExpandedE.toggle()
                     }
                     }
                     
                     if isExpandedE {
                     VStack(spacing: 8) {
                     
                     // Total Times Played Row
                     InfoRow(label: "Total Times Played", value: "\(user.luckyPatternsStats?.totalTimesPlayed ?? 0)")
                     
                     Divider() // Separates sections
                     
                     // Highscore Row
                     InfoRow(label: "Highscore", value: "\(user.luckyPatternsStats?.highScore ?? 0)", valueColor: .green)
                     
                     // Power Ups Used Row
                     InfoRow(label: "Power Ups Used", value: "\(user.luckyPatternsStats?.powerUpsUsedForHighscore ?? 0)")
                     
                     Divider() // Separates sections
                     
                     
                     // Accordion for Item F
                     VStack {
                     HStack {
                     Text(itemF.title)
                     .font(.headline)
                     .foregroundColor(.black)
                     Spacer()
                     Image(systemName: isExpandedF ? "chevron.up" : "chevron.down")
                     .foregroundColor(.gray)
                     }
                     .padding()
                     .background(Color.white)
                     .cornerRadius(10)
                     .onTapGesture {
                     withAnimation {
                     isExpandedF.toggle()
                     }
                     }
                     
                     if isExpandedF {
                     Text("Coming Soon")
                     .font(.headline)
                     .foregroundColor(.black)
                     }
                     }
                     .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                     
                     
                     
                     }
                     .padding()
                     .background(Color(UIColor.systemGray6))
                     .cornerRadius(8)
                     .transition(.slide)
                     }
                     }
                     .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                     */
                    
                    
                }
                .padding(.horizontal)
            }
            
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
        
        
    }
}

private extension UserScoresView {
    func resetAllStats() {
        user.luckySquaresStats = MockData.initLuckySquareStats
        user.luckyCirclesStats = MockData.initLuckyCirclesStats
        user.resetStatsUsed = (user.resetStatsUsed ?? 0) + 1
    }
    
    func resetCoins() {
        user.coins = 300
        user.resetCoinsUsed = (user.resetCoinsUsed ?? 0) + 1
    }
}

struct InfoRow: View {
    var label: String
    var value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    UserScoresView(user: MockData.defUser)
}
