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
    let thumbnailURL: String
    
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}

struct ExerciseResult: Identifiable, Codable {
    let id: String
    let exerciseId: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let completionPercentage: Double
    let feedback: String?
    
    var caloriesBurned: Double {
        // Simple estimation based on duration
        return duration * 0.05
    }
}
