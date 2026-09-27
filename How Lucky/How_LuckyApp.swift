//
//  How_LuckyApp.swift
//  How Lucky
//
//  Created by Peyton White on 10/29/24.
//

import SwiftUI
import SwiftData

@main
struct How_LuckyApp: App {
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(appContainer)
    }
    
    @MainActor
    let appContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: User.self)
            
            // Make sure the persistent store is not empty
            var itemFetchDescriptor = FetchDescriptor<User>()
            itemFetchDescriptor.fetchLimit = 1
            
            // Fetch the existing user
            guard let user = try container.mainContext.fetch(itemFetchDescriptor).first else {
                // If no user is found, insert a mock user and return the container
                let newUser = MockData.initUser
                container.mainContext.insert(newUser)
                return container
            }
            
            // Check if the new property exists and initialize if missing and pull from mock data
            /*
            if user.luckySquaresStats?.newPowerUpStat == nil {
                // Initialize the missing property with default values
                user.luckySquaresStats?.newPowerUpStat = PowerUpStat() // Replace this with your default initialization
            }
             */
            
            // Add other checks for new fields or properties you added
            
            return container
        } catch {
            fatalError("Failed to create container")
        }
    }()
}
