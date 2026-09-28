import Foundation
import Combine

@MainActor
class TriviaManager: ObservableObject {
    private(set) var trivia: [TriviaResult] = []
    @Published private(set) var length = 0
    @Published private(set) var index = 0
    @Published private(set) var reachedEnd = false
    @Published private(set) var answerSelected = false
    @Published private(set) var question: AttributedString = ""
    @Published private(set) var answerChoices: [TriviaAnswer] = []
    @Published private(set) var progress: CGFloat = 0
    @Published private(set) var score = 0
    @Published private(set) var triviaType = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    private var requestID = UUID()
    private var gameType = "easy"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchTrivia(gameType: String) async {
        resetManager()
        self.gameType = gameType
        let request = requestID
        isLoading = true
        let suffix: String
        switch gameType {
        case "med": triviaType = "Medium"; suffix = "amount=1&difficulty=medium"
        case "tof": triviaType = "T/F"; suffix = "amount=1&type=boolean"
        case "mania": triviaType = "Mania"; suffix = "amount=50"
        case "hard": triviaType = "Hard"; suffix = "amount=1&difficulty=hard"
        default: triviaType = "Easy"; suffix = "amount=1&difficulty=easy"
        }
        defer { if request == requestID { isLoading = false } }
        do {
            let url = URL(string: "https://opentdb.com/api.php?encode=url3986&" + suffix)!
            let (data, response) = try await session.data(for: URLRequest(url: url, timeoutInterval: 20))
            guard request == requestID else { return }
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                errorMessage = "Trivia is unavailable right now. Please try again shortly."
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(Trivia.self, from: data)
            if decoded.responseCode == 5 {
                errorMessage = "Trivia requests are limited. Wait at least five seconds, then retry."
                return
            }
            guard decoded.responseCode == 0, !decoded.results.isEmpty,
                  decoded.results.allSatisfy({ !$0.incorrectAnswers.isEmpty && !$0.correctAnswer.isEmpty }) else {
                errorMessage = "No trivia questions are available. Please try again shortly."
                return
            }
            trivia = decoded.results
            length = trivia.count
            setQuestion()
        } catch {
            guard request == requestID else { return }
            errorMessage = "Could not load trivia. Check your connection and try again."
        }
    }

    func retry() async {
        await fetchTrivia(gameType: gameType)
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
        guard trivia.indices.contains(index) else { return }
        answerSelected = false
        question = trivia[index].formattedQuestion
        answerChoices = trivia[index].answers
    }

    @discardableResult
    func selectAnswer(answer: TriviaAnswer) -> Bool {
        guard !answerSelected, !isLoading, !reachedEnd,
              answerChoices.contains(where: { $0.id == answer.id }) else { return false }
        answerSelected = true
        if answer.isCorrect { score += 1 }
        return true
    }

    func resetManager() {
        requestID = UUID() // Discard responses from a closed or previous round.
        trivia = []
        answerChoices = []
        answerSelected = false
        score = 0
        question = ""
        length = 0
        index = 0
        reachedEnd = false
        triviaType = ""
        isLoading = false
        errorMessage = nil
    }
}
