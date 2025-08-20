import Foundation

struct Exercise: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let duration: TimeInterval
    let difficulty: ExerciseDifficulty
    let category: ExerciseCategory
    let videoURL: String
    let instructions: [String]
}
