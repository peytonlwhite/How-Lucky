//
//  TriviaManager.swift
//  How Lucky
//
//  Created by Peyton White on 11/5/24.
//

import Foundation

class TriviaManager: ObservableObject, @unchecked Sendable {
    
    private(set) var trivia: [TriviaResult] = []
    @Published private(set) var length = 0
    @Published private(set) var index = 0
    @Published private(set) var reachedEnd = false
    @Published private(set) var answerSelected = false
    @Published private(set) var question: AttributedString = ""
    @Published private(set) var url: String = ""
    @Published private(set) var answerChoices:[TriviaAnswer] = []
    @Published private(set) var progress: CGFloat = 0.00
    @Published private(set) var score: Int = 0
    @Published private(set) var triviaType: String = ""
    
    init() {
        Task.init {
            //await fetchTrivia(gameType: "1")
        }
    }
    
    func fetchTrivia(gameType:String) async {
        await setUrl(gameType: gameType)
        
        guard let url = URL(string: url) else { fatalError("Missing URL") }
        
        let urlRequest = URLRequest(url:url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for:urlRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("error while fetching data") }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(Trivia.self,from:data)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.trivia = decodedData.results
                self.length = self.trivia.count
                self.setQuestion()
            }
            
        } catch {
            print("error fetching trivia \(error)")
        }
    }
    
    
    @MainActor
    func setUrl(gameType: String) {
        switch gameType {
        case "easy":
            triviaType = "Easy"
            url = "https://opentdb.com/api.php?amount=1&difficulty=easy"
        case "med":
            triviaType = "Medium"
            url = "https://opentdb.com/api.php?amount=1&difficulty=medium"
        case "tof":
            triviaType = "T/F"
            url = "https://opentdb.com/api.php?amount=1&type=boolean"
        case "mania":
            triviaType = "Mania"
            url = "https://opentdb.com/api.php?amount=50"
        case "hard":
            triviaType = "Hard"
            url = "https://opentdb.com/api.php?amount=1&difficulty=hard"
        default:
            triviaType = "Easy"
            url = "https://opentdb.com/api.php?amount=1&difficulty=easy"
        }
    }


    
    func setTriviaType(type:String) {
        triviaType = type
    }
    
    func goToNextQuestion() {
        if index + 1 < length {
            index += 1
            setQuestion()
        } else {
            reachedEnd = true
        }
    }
                  
    
    func setQuestion() {
        answerSelected = false
        //progress = CGFloat((Double(index)+1)/Double(length) * 360)
        
        if index < length {
            let currentTriviaQuestion = trivia[index]
            question = currentTriviaQuestion.formattedQuestion
            answerChoices = currentTriviaQuestion.answers
        }
    }
    
    func selectAnswer(answer:TriviaAnswer) {
        answerSelected = true
        if answer.isCorrect {
            score += 1
        }
    }
    
    func resetManager() {
        answerSelected = false
        score = 0
        question = ""
        length = 0
        index = 0
        reachedEnd = false
        triviaType = ""
    }
    

                  
}
