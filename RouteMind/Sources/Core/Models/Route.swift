import Foundation
import MapKit

struct Route: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let startLocation: CLLocationCoordinate2D
    let endLocation: CLLocationCoordinate2D
    let waypoints: [CLLocationCoordinate2D]
    let polyline: MKPolyline?
    let estimatedDuration: TimeInterval
    let distance: CLLocationDistance
    let createdAt: Date
    var isFavorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, userId, name, startLocation, endLocation, waypoints
        case estimatedDuration, distance, createdAt, isFavorite
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        startLocation = try container.decode(CLLocationCoordinate2D.self, forKey: .startLocation)
        endLocation = try container.decode(CLLocationCoordinate2D.self, forKey: .endLocation)
        waypoints = try container.decode([CLLocationCoordinate2D].self, forKey: .waypoints)
        estimatedDuration = try container.decode(TimeInterval.self, forKey: .estimatedDuration)
        distance = try container.decode(CLLocationDistance.self, forKey: .distance)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        polyline = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(startLocation, forKey: .startLocation)
        try container.encode(endLocation, forKey: .endLocation)
        try container.encode(waypoints, forKey: .waypoints)
        try container.encode(estimatedDuration, forKey: .estimatedDuration)
        try container.encode(distance, forKey: .distance)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
    
    init(id: String, userId: String, name: String, startLocation: CLLocationCoordinate2D, endLocation: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D], polyline: MKPolyline?, estimatedDuration: TimeInterval, distance: CLLocationDistance, createdAt: Date, isFavorite: Bool) {
        self.id = id
        self.userId = userId
        self.name = name
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.waypoints = waypoints
        self.polyline = polyline
        self.estimatedDuration = estimatedDuration
        self.distance = distance
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}
