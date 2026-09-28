//
//  Trivia.swift
//  How Lucky
//
//  Created by Peyton White on 11/5/24.
//

import Foundation

struct Trivia: Decodable {
    var responseCode: Int
    var results: [TriviaResult]
    
}
