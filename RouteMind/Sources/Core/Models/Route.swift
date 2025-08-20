import Foundation
import MapKit
import CoreLocation

struct Route: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let startLocation: CLLocationCoordinate2D
    let endLocation: CLLocationCoordinate2D
    let waypoints: [CLLocationCoordinate2D]
    let polyline: MKPolyline
    let estimatedDuration: TimeInterval
    let distance: CLLocationDistance
    let createdAt: Date
    let isFavorite: Bool
}
