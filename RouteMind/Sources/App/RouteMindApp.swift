import SwiftUI
import FirebaseCore

@main
struct RouteMindApp: App {
    
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // MARK: - App State Managers
    
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var routeManager = RouteManager.shared
    @StateObject private var breakManager = BreakManager.shared
    @StateObject private var exerciseManager = ExerciseManager.shared
    @StateObject private var locationService = LocationService.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if sessionManager.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(sessionManager)
            .environmentObject(routeManager)
            .environmentObject(breakManager)
            .environmentObject(exerciseManager)
            .environmentObject(locationService)
            .preferredColorScheme(.dark)
        }
    }
}
