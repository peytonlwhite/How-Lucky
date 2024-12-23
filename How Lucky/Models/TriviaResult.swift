//
//  TriviaResult.swift
//  How Lucky
//
//  Created by Peyton White on 11/5/24.
//

import Foundation
struct TriviaResult: Decodable, Identifiable {
    var id: UUID {
        UUID()
    }
    var category:String
    var type:String
    var difficulty:String
    var question:String
    var correctAnswer:String
    var incorrectAnswers: [String]
    
    var formattedQuestion: AttributedString {
        do {
            return try AttributedString(markdown:question)
        } catch {
            print("formmated question error: \(error)")
            return ""
        }
    }
    
    var answers: [TriviaAnswer] {
        do {
            let correct = [TriviaAnswer(text: try AttributedString(markdown:correctAnswer), isCorrect: true)]
            let inCorrect = try incorrectAnswers.map { answer in
                TriviaAnswer(text: try AttributedString(markdown:answer), isCorrect: false)
            }
            let allAnswers = correct + inCorrect
            
            return allAnswers.shuffled()
        } catch {
            print("error setting answers: \(error)")
            return []
        }
    }
    
    
}
