import Foundation
import CoreLocation

struct POI: Identifiable, Codable {
    let id: String
    let name: String
    let category: POICategory
    let location: CLLocationCoordinate2D
    let address: String
    let phoneNumber: String?
    let website: String?
    let rating: Double
    let reviewCount: Int
    let priceLevel: Int?
    let photoReference: String?
    let openingHours: [String]?
    let isOpenNow: Bool?
    
    var formattedRating: String {
        return String(format: "%.1f", rating)
    }
    
    var priceIndicator: String {
        guard let priceLevel = priceLevel else { return "" }
        return String(repeating: "$", count: priceLevel)
    }
}
