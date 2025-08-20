import Foundation

struct UserPreferences: Codable {
    let preferredBreakInterval: TimeInterval
    let exercisePreferences: ExercisePreferences
    let poiPreferences: POIPreferences
    let notificationSettings: NotificationSettings

    init() {
        self.preferredBreakInterval = 7200 // 2 hours
        self.exercisePreferences = ExercisePreferences()
        self.poiPreferences = POIPreferences()
        self.notificationSettings = NotificationSettings()
    }
}
