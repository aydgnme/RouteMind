import Foundation
import CoreLocation

struct BreakPoint: Identifiable, Codable {
    let id: String
    let routeId: String
    let location: CLLocationCoordinate2D
    let scheduledTime: Date
    let poi: POI?
    let duration: TimeInterval
    let isCompleted: Bool
    let notes: String?
}
