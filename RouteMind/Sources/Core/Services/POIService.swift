import Foundation
import MapKit

class POIService: ObservableObject {
    @Published var nearbyPOIs: [POI] = []
    @Published var favoritePOIs: [POI] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    static let shared = POIService()
    
    private let firestoreService = FirestoreService.shared
    
    private init() {}
    
    func searchNearbyPOIs(location: CLLocationCoordinate2D, radius: CLLocationDistance = 5000) async -> Result<[POI], Error> {
        isLoading = true
        defer { isLoading = false }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        request.region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            
            let pois = response.mapItems.map { item in
                POI(
                    id: "\(item.placemark.coordinate.latitude),\(item.placemark.coordinate.longitude)",
                    name: item.name ?? "Unknown",
                    category: .restaurant, // This would be determined from the result
                    location: item.placemark.coordinate,
                    address: item.placemark.title ?? "",
                    phoneNumber: item.phoneNumber,
                    website: item.url?.absoluteString,
                    rating: 0, // Would come from additional API calls
                    reviewCount: 0,
                    priceLevel: nil,
                    photoReference: nil,
                    openingHours: nil,
                    isOpenNow: nil
                )
            }
            
            nearbyPOIs = pois
            return .success(pois)
        } catch {
            self.error = error
            return .failure(error)
        }
    }
    
    func searchPOIsByCategory(location: CLLocationCoordinate2D, category: POICategory, radius: CLLocationDistance = 5000) async -> Result<[POI], Error> {
        // Similar implementation to searchNearbyPOIs but filtered by category
        return await searchNearbyPOIs(location: location, radius: radius)
    }
    
    func getPOIDetails(id: String) async -> Result<POI, Error> {
        // This would fetch detailed information about a specific POI
        // For now, we'll search our local array
        if let poi = nearbyPOIs.first(where: { $0.id == id }) {
            return .success(poi)
        } else if let poi = favoritePOIs.first(where: { $0.id == id }) {
            return .success(poi)
        } else {
            return .failure(NSError(domain: "POIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "POI not found"]))
        }
    }
    
    func saveFavoritePOI(poi: POI) async -> Result<Void, Error> {
        favoritePOIs.append(poi)
        
        guard let firebaseUser = AuthService.shared.currentUser else {
            return .failure(NSError(domain: "POIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
        }
        
        // Fetch the current user from Firestore first
        let userResult = await firestoreService.fetchUser(userId: firebaseUser.uid)
        switch userResult {
        case .success(let user):
            // Create updated preferences with the new favorite category
            var updatedFavoriteCategories = user.preferences.poiPreferences.favoriteCategories
            if !updatedFavoriteCategories.contains(poi.category) {
                updatedFavoriteCategories.append(poi.category)
            }
            
            // Create new POI preferences
            let updatedPOIPreferences = User.UserPreferences.POIPreferences(
                favoriteCategories: updatedFavoriteCategories,
                minimumRating: user.preferences.poiPreferences.minimumRating,
                maxDistance: user.preferences.poiPreferences.maxDistance
            )
            
            // Create new user preferences
            let updatedUserPreferences = User.UserPreferences(
                preferredBreakInterval: user.preferences.preferredBreakInterval,
                exercisePreferences: user.preferences.exercisePreferences,
                poiPreferences: updatedPOIPreferences,
                notificationSettings: user.preferences.notificationSettings
            )
            
            // Create updated user
            let updatedUser = User(
                id: user.id,
                email: user.email,
                name: user.name,
                profileImageURL: user.profileImageURL,
                preferences: updatedUserPreferences,
                createdAt: user.createdAt,
                lastLogin: Date()
            )
            
            return await firestoreService.updateUser(updatedUser)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getFavoritePOIs() async -> Result<[POI], Error> {
        // This would fetch from Firestore
        return .success(favoritePOIs)
    }
}
