//
//  UserService.swift
//  How Lucky
//
//  Created by Peyton White on 11/1/24.
//

import Foundation
import SwiftData

class UserService {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    @MainActor
    static let shared = UserService()
    
    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: User.self)
        self.modelContext = modelContainer.mainContext
    }
    
    func fetchUsers() -> [User] {
        do {
            return try modelContext.fetch(FetchDescriptor<User>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func addUser(_ user: User) {
        modelContext.insert(user)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func editUser(user:User) {
        modelContext.insert(user)
        save()
    }
    
    
    func save() {
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
