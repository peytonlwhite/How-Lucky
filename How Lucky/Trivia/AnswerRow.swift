//
//  AnswerRow.swift
//  TriviaGame
//
//  Created by Stephanie Diep on 2021-12-17.
//

import SwiftUI

struct AnswerRow: View {
    @EnvironmentObject var triviaManager: TriviaManager
    var answer: TriviaAnswer
    @State private var isSelected = false
    let showCorrect: Bool
    var function: (_ isCorrect: Bool) -> Void


    // Custom colors
    var green = Color(hue: 0.437, saturation: 0.711, brightness: 0.711)
    var red = Color(red: 0.71, green: 0.094, blue: 0.1)
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "circle.fill")
                .font(.caption)
                .foregroundColor(isSelected || showCorrect ? answer.isCorrect ? green : red : .gray)
            
            Text(answer.text)
                .bold()
                .foregroundStyle(.primary)
            
            if isSelected {
                Spacer()
                Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                    .foregroundColor(answer.isCorrect ? green : red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(triviaManager.answerSelected ? (isSelected ? Color(.red) : .gray) : Color(.blue))
        .background(GamePalette.surface)
        .cornerRadius(16)
        .shadow(color: isSelected ? answer.isCorrect ? green : red : .gray, radius: 5, x: 0.5, y: 0.5)
        .onTapGesture {
            if !triviaManager.answerSelected {
                guard triviaManager.selectAnswer(answer: answer) else { return }
                isSelected = true
                function(answer.isCorrect)
            }
        }
    }
}

struct AnswerRow_Previews: PreviewProvider {
    static var previews: some View {
        AnswerRow(answer: TriviaAnswer(text: "Single", isCorrect:  false), showCorrect:false,
        function: { isCorrect in
            
        })
        .environmentObject(TriviaManager())
    }
}
