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
            print("in app container")
            let container = try ModelContainer(for: User.self)
            
            // Make sure the persistent store is empty. If it's not, return the non-empty container.
            var itemFetchDescriptor = FetchDescriptor<User>()
            itemFetchDescriptor.fetchLimit = 1
            
            print("checking store")
            guard try container.mainContext.fetch(itemFetchDescriptor).count == 0 else { return container }
            
            // This code will only run if the persistent store is empty.
            let user = MockData.initUser
            print("persistent store is empty")
            container.mainContext.insert(user)
            
            return container
        } catch {
            fatalError("Failed to create container")
        }
    }()
  
}

