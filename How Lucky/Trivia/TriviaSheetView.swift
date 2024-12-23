//
//  PowerUpSheetView.swift
//  How Lucky
//
//  Created by Peyton White on 11/2/24.
//

import SwiftUI

struct TriviaSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var triviaManager:TriviaManager
    var function: (_ isCorrect: Bool) -> Void
    let type:String
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 40) {
                       HStack {
                           Text("Trivia \(type)")
                           
                           Spacer()
                           
                           Text("\(triviaManager.index + 1) out of \(triviaManager.length)")
                               .foregroundColor(Color(.green))
                               .fontWeight(.heavy)
                       }
                        
                       //ProgressBar(progress: triviaManager.progress) 
                       
                       VStack(alignment: .leading, spacing: 20) {
                           Text(triviaManager.question)  
                               .font(.system(size: 20))
                               .bold()
                               .foregroundColor(.gray)
                           
                           //when answer is clicked, go to next question or close the sheet if done
                           
                           ForEach(triviaManager.answerChoices, id: \.id) { answer in
                               VStack {
                                   AnswerRow(answer: answer, function:answerClicked)
                                       .environmentObject(triviaManager)
                               }
                           }
                       }
                        
                       Spacer()
                   }
                   .padding()
                   .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                   .background(Color(hex: "#e6e6ff"))
                   .toolbar {
                       /*
                       Button("Cancel") {
                           dismiss()
                       }
                        */
                   }
            
               }
        
        }
    }

private extension TriviaSheetView {
    func answerClicked(isCorrect:Bool) {
        print("TriviaSheetView answer is correct: \(isCorrect)")
        triviaManager.goToNextQuestion()
        if(!isCorrect) {
            function(false)
            dismissAfterSelection()
        } else if(triviaManager.reachedEnd) {
            function(true)
            dismissAfterSelection()
        }
    }
    
    func dismissAfterSelection() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            dismiss()
        }
    }
    
}




#Preview {
    TriviaSheetView(function: { isCorrect in
        
    }, type: "Easy").environmentObject(TriviaManager())
}
