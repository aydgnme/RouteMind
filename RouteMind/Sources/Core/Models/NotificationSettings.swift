import Foundation

struct NotificationSettings: Codable {
    let breakReminders: Bool
    let exerciseReminders: Bool
    let routeUpdates: Bool

    init() {
        self.breakReminders = true
        self.exerciseReminders = true
        self.routeUpdates = true
    }
}
