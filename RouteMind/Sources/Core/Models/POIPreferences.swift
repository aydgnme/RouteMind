import Foundation

struct POIPreferences: Codable {
    let preferredCategories: [String]

    init() {
        self.preferredCategories = ["Cafe", "Park", "Restaurant"]
    }
}
