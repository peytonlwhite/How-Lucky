//
//  TriviaAnswer.swift
//  How Lucky
//
//  Created by Peyton White on 11/5/24.
//

import Foundation

struct TriviaAnswer : Identifiable {
    var id = UUID() // Setting the UUID ourselves inside of the model, because API doesn't return a unique ID for each answer
    var text: AttributedString
    var isCorrect: Bool
}
