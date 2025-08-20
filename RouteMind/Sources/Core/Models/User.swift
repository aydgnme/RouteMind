import Foundation
import CoreLocation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let name: String
    let profileImageURL: String?
    let preferences: UserPreferences
    let createdAt: Date
    let lastLogin: Date
    
    struct UserPreferences: Codable {
        let preferredBreakInterval: TimeInterval
        let exercisePreferences: ExercisePreferences
        let poiPreferences: POIPreferences
        let notificationSettings: NotificationSettings
        
        struct ExercisePreferences: Codable {
            let preferredCategories: [ExerciseCategory]
            let difficultyLevel: ExerciseDifficulty
            let maxDuration: TimeInterval
        }
        
        struct POIPreferences: Codable {
            let favoriteCategories: [POICategory]
            let minimumRating: Double
            let maxDistance: CLLocationDistance
        }
        
        struct NotificationSettings: Codable {
            let breakReminders: Bool
            let exerciseReminders: Bool
            let routeUpdates: Bool
            let soundEnabled: Bool
        }
    }
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case stretching = "Stretching"
    case mobility = "Mobility"
    case energy = "Energy Boosters"
    case relaxation = "Relaxation"
}

enum ExerciseDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

enum POICategory: String, Codable, CaseIterable {
    case restaurant = "Restaurant"
    case cafe = "Cafe"
    case park = "Park"
    case museum = "Museum"
    case viewpoint = "Viewpoint"
    case restArea = "Rest Area"
    case gasStation = "Gas Station"
}
