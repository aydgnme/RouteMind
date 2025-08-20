import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let name: String
    let profileImageURL: String?
    let preferences: UserPreferences
    let createdAt: Date
    let lastLogin: Date
}
