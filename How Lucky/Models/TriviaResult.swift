import Foundation

struct TriviaResult: Decodable, Identifiable {
    let id = UUID()
    var category: String
    var type: String
    var difficulty: String
    var question: String
    var correctAnswer: String
    var incorrectAnswers: [String]

    private enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question, correctAnswer, incorrectAnswers
    }

    // Requests use Open Trivia DB's RFC 3986 encoding. Decode once and show
    // plain text so punctuation, percent signs, and Markdown-like text survive.
    var formattedQuestion: AttributedString {
        AttributedString(question.removingPercentEncoding ?? question)
    }

    var answers: [TriviaAnswer] {
        let correct = TriviaAnswer(text: AttributedString(correctAnswer.removingPercentEncoding ?? correctAnswer), isCorrect: true)
        let incorrect = incorrectAnswers.map {
            TriviaAnswer(text: AttributedString($0.removingPercentEncoding ?? $0), isCorrect: false)
        }
        return ([correct] + incorrect).shuffled()
    }
}
