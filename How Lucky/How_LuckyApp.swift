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
                try container.mainContext.save()
                return container
            }
            
            user.repairMissingDefaults()
            try container.mainContext.save()

            return container
        } catch {
            fatalError("Failed to create container")
        }
    }()
}
