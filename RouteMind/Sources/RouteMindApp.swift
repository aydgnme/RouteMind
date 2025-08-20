import SwiftUI
import FirebaseCore
import FirebaseAppCheck

/*
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
*/

@main
struct RouteMindApp: App {
    // register app delegate for Firebase setup
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // ✅ Register Debug Provider for App Check
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
