import Foundation

struct ExercisePreferences: Codable {
    let preferredCategories: [ExerciseCategory]
    let difficultyLevel: ExerciseDifficulty

    init() {
        self.preferredCategories = [.stretching, .mobility]
        self.difficultyLevel = .easy
    }
}
