import Foundation
import Combine

class ExerciseManager: ObservableObject {
    @Published var recommendedExercise: Exercise?
    @Published var exerciseHistory: [ExerciseResult] = []
    @Published var currentExercise: Exercise?
    @Published var isExerciseInProgress = false
    @Published var isLoading = false
    @Published var error: Error?
    
    private let exerciseService = ExerciseService.shared
    private let mlService = MLService.shared
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = ExerciseManager()
    
    private init() {
        loadExerciseHistory()
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Monitor break completion to recommend exercises
        BreakManager.shared.$upcomingBreak
            .receive(on: DispatchQueue.main)
            .sink { [weak self] breakPoint in
                if let breakPoint = breakPoint {
                    self?.recommendExerciseForBreak(breakPoint)
                } else {
                    self?.recommendedExercise = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func loadExerciseHistory() {
        guard let user = SessionManager.shared.currentUser else { return }
        
        isLoading = true
        Task {
            let result = await exerciseService.getExerciseHistory()
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let history):
                    self.exerciseHistory = history
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
    
    func recommendExerciseForBreak(_ breakPoint: BreakPoint) {
        guard let user = SessionManager.shared.currentUser else { return }
        
        // Use ML service to recommend exercises
        let recommendations = mlService.recommendExercises(
            userProfile: user,
            breakDuration: breakPoint.duration
        )
        
        // For now, just pick the first recommendation
        recommendedExercise = recommendations.first
    }
    
    func startExercise(_ exercise: Exercise) {
        exerciseService.startExercise(exercise: exercise)
        currentExercise = exercise
        isExerciseInProgress = true
    }
    
    func pauseExercise() {
        exerciseService.pauseExercise()
        isExerciseInProgress = false
    }
    
    func resumeExercise() {
        exerciseService.resumeExercise()
        isExerciseInProgress = true
    }
    
    func stopExercise() -> ExerciseResult {
        isExerciseInProgress = false
        let result = exerciseService.stopExercise()
        currentExercise = nil
        
        // Add to history
        exerciseHistory.insert(result, at: 0)
        
        return result
    }
    
    func loadRecommendedExercise() async {
        // This would be called when the home view loads
        // For now, we'll just load a random exercise
        let exercises = exerciseService.availableExercises
        recommendedExercise = exercises.randomElement()
    }
}
