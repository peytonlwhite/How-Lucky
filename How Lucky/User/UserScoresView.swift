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

struct UserScoresView: View {
    
    @Bindable var user:User
    
    var list: [String] = ["Lucky Squares", "Lucky Circles", "Lucky Patterns"]

    
    @State private var isExpandedA = true
    @State private var isExpandedB = false
    @State private var isExpandedC = false
    @State private var isExpandedD = false
    @State private var isExpandedE = false
    @State private var isExpandedF = false


    let itemA: ItemA = ItemA(title: "Lucky Squares", details: "")
    let itemB: ItemB = ItemB(title: "Lucky Circles", details: "")
    let itemC: ItemC = ItemC(title: "Power Up Stats", details: "")
    let itemD: ItemD = ItemD(title: "Power Up Stats", details: "")
    
    let itemE: ItemE = ItemE(title: "Lucky Patterns", details: "")
    let itemF: ItemF = ItemF(title: "Power Up Stats", details: "")

    var body: some View {

                    VStack {
                        Text("High Scores")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()

                        ScrollView {
                            VStack(spacing: 12) {
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
                                
                                
                                
                            }
                            .padding(.horizontal)
                        }
                        
                  
                        Spacer()
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                    .edgesIgnoringSafeArea(.bottom)
        
               
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
