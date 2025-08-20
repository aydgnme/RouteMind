import Foundation
import CoreLocation

struct BreakPoint: Identifiable, Codable {
    let id: String
    let routeId: String
    let location: CLLocationCoordinate2D
    let scheduledTime: Date
    var poi: POI?
    let duration: TimeInterval
    var isCompleted: Bool
    var notes: String?
    
    var timeUntilBreak: TimeInterval {
        return scheduledTime.timeIntervalSinceNow
    }
    
    var formattedTimeUntilBreak: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: timeUntilBreak) ?? ""
    }
}
