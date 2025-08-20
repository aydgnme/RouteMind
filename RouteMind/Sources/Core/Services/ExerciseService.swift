import Foundation
import AVFoundation

class ExerciseService: ObservableObject {
    @Published var availableExercises: [Exercise] = []
    @Published var exerciseHistory: [ExerciseResult] = []
    @Published var currentExercise: Exercise?
    @Published var isPlaying = false
    @Published var error: Error?
    
    static let shared = ExerciseService()
    
    private let firestoreService = FirestoreService.shared
    private var audioPlayer: AVAudioPlayer?
    private var videoPlayer: AVPlayer?
    
    private init() {
        loadDefaultExercises()
    }
    
    private func loadDefaultExercises() {
        // Load default exercise library
        availableExercises = [
            Exercise(
                id: "1",
                name: "Neck Stretches",
                description: "Gentle neck stretches to relieve tension",
                duration: 120,
                difficulty: .easy,
                category: .stretching,
                videoURL: "neck_stretches.mp4",
                instructions: [
                    "Slowly tilt your head to the right",
                    "Hold for 15 seconds",
                    "Return to center and repeat on left side"
                ],
                thumbnailURL: "neck_stretch_thumb.jpg"
            ),
            Exercise(
                id: "2",
                name: "Shoulder Rolls",
                description: "Loosen up tight shoulders",
                duration: 90,
                difficulty: .easy,
                category: .mobility,
                videoURL: "shoulder_rolls.mp4",
                instructions: [
                    "Roll shoulders forward in circular motion",
                    "Repeat 10 times",
                    "Reverse direction and repeat"
                ],
                thumbnailURL: "shoulder_rolls_thumb.jpg"
            ),
            // More exercises...
        ]
    }
    
    func getRecommendedExercises(breakDuration: TimeInterval, userPreferences: User.UserPreferences.ExercisePreferences) -> [Exercise] {
        return availableExercises.filter { exercise in
            exercise.duration <= breakDuration &&
            userPreferences.preferredCategories.contains(exercise.category) &&
            exercise.difficulty == userPreferences.difficultyLevel
        }
    }
    
    func getExerciseById(id: String) -> Result<Exercise, Error> {
        if let exercise = availableExercises.first(where: { $0.id == id }) {
            return .success(exercise)
        } else {
            return .failure(NSError(domain: "ExerciseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Exercise not found"]))
        }
    }
    
    func startExercise(exercise: Exercise) {
        currentExercise = exercise
        isPlaying = true
        
        // Load and play video
        if let url = Bundle.main.url(forResource: exercise.videoURL, withExtension: nil) {
            videoPlayer = AVPlayer(url: url)
            videoPlayer?.play()
        }
        
        // Load and play audio instructions
        if let url = Bundle.main.url(forResource: "\(exercise.id)_audio", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                self.error = error
            }
        }
    }
    
    func pauseExercise() {
        isPlaying = false
        videoPlayer?.pause()
        audioPlayer?.pause()
    }
    
    func resumeExercise() {
        isPlaying = true
        videoPlayer?.play()
        audioPlayer?.play()
    }
    
    func stopExercise() -> ExerciseResult {
        isPlaying = false
        videoPlayer?.pause()
        audioPlayer?.pause()
        
        let result = ExerciseResult(
            id: UUID().uuidString,
            exerciseId: currentExercise?.id ?? "",
            startTime: Date().addingTimeInterval(-300), // 5 minutes ago
            endTime: Date(),
            duration: 300, // 5 minutes
            completionPercentage: 100,
            feedback: nil
        )
        
        // Save to history
        exerciseHistory.append(result)
        
        // Save to Firestore
        Task {
            await firestoreService.saveExerciseResult(result)
        }
        
        currentExercise = nil
        return result
    }
    
    func saveExerciseResult(result: ExerciseResult) async -> Result<Void, Error> {
        return await firestoreService.saveExerciseResult(result)
    }
    
    func getExerciseHistory() async -> Result<[ExerciseResult], Error> {
        guard let userId = AuthService.shared.currentUser?.uid else {
            return .failure(NSError(domain: "ExerciseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
        }
        
        return await firestoreService.fetchExerciseHistory(userId: userId)
    }
}
