//
//  GameOptionsViewModel.swift
//  How Lucky
//
//  Created by Peyton White on 11/1/24.
//

import Foundation
import SwiftData


class GameOptionsViewModel:ObservableObject {
    
    @Published var users: [User] = []
        
    private let dataSource: UserService
        
    init(dataSource: UserService) {
        print("init optionv eiw model")
        self.dataSource = dataSource
              
        users = dataSource.fetchUsers()
        if(users.isEmpty) {
            addUser()
        } else {
            
        }
        
      
        
    }
        
    func addUser() {
        let user = MockData.initUser
        dataSource.addUser(user)
        // Manually fetch the latest expenses after add new expense
        users = dataSource.fetchUsers()
    }
    
    func editUser(user:User) {
        users[0].luckySquaresStats = user.luckySquaresStats
        users[0].luckyCirclesStats = user.luckyCirclesStats
        dataSource.editUser(user: user)
        fetchUsers()
    }
    
    func fetchUsers() {
        users = dataSource.fetchUsers()
    }
    
    
    func save() {
        dataSource.save()
    }
    
}

// (Optional) Create dummy users
extension User {
    static let dummyUsers: [User] = [
        MockData.initUser
    ]
}
