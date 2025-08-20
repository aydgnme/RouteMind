import Foundation
import CoreLocation

struct POI: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let rating: Double
    let imageURL: String?
}
