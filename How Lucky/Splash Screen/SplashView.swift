//
//  SplashView.swift
//  How Lucky
//
//  Created by Peyton White on 12/10/24.
//

import SwiftUI

struct SplashView: View {
    
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @Environment(\.colorScheme) var colorScheme // Detect dark or light mode
    
    
    var body: some View {
        if isActive {
            GameOptionsView()
        } else {
            ZStack {
                // Background Color adapts to Light/Dark Mode
                (colorScheme == .dark ? Color.black : Color.white)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    // Brand Logo
                    Image("foowibblelogo") // Replace with your logo asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .scaleEffect(scaleEffect)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)) {
                                scaleEffect = 1.0
                                opacity = 1.0
                            }
                        }
                    
                    // Brand Name
                    Text("FooWibble") // Replace with your brand name
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2).delay(0.5)) {
                                opacity = 1.0
                            }
                        }
                    
                    Spacer()
                    
                    // Optional: A slogan or tagline
                    Text("Seamless")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                        .opacity(opacity)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
                .background(Color.white.edgesIgnoringSafeArea(.all)) // Replace with your brand color
            }
        }
    }
    
    #Preview {
        SplashView()
    }
