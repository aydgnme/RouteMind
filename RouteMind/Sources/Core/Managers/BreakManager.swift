import Foundation
import Combine

class BreakManager: ObservableObject {
    @Published var upcomingBreak: BreakPoint?
    @Published var scheduledBreaks: [BreakPoint] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firestoreService = FirestoreService.shared
    private let poiService = POIService.shared
    private let mlService = MLService.shared
    private var cancellables = Set<AnyCancellable>()
    private var breakTimer: Timer?
    
    static let shared = BreakManager()
    
    private init() {
        setupBreakMonitoring()
    }
    
    private func setupBreakMonitoring() {
        // Monitor route changes to schedule breaks
        RouteManager.shared.$activeRoute
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                if let route = route {
                    self?.scheduleBreaksForRoute(route)
                } else {
                    self?.clearScheduledBreaks()
                }
            }
            .store(in: &cancellables)
    }
    
    func scheduleBreaksForRoute(_ route: Route) {
        isLoading = true
        
        Task {
            // Calculate optimal break times using ML
            let breakInterval = mlService.predictOptimalBreakTime(
                drivingDuration: route.estimatedDuration,
                userHistory: [] // Would use actual history
            )
            
            // Schedule breaks along the route
            let breaks = await calculateBreakPoints(for: route, interval: breakInterval)
            
            DispatchQueue.main.async {
                self.scheduledBreaks = breaks
                self.upcomingBreak = breaks.first
                self.isLoading = false
                self.startBreakMonitoring()
            }
        }
    }
    
    private func calculateBreakPoints(for route: Route, interval: TimeInterval) async -> [BreakPoint] {
        var breakPoints: [BreakPoint] = []
        var currentTime = Date().addingTimeInterval(interval)
        
        // This is a simplified implementation
        // In a real app, we would calculate actual positions along the route
        
        for i in 0..<Int(route.estimatedDuration / interval) {
            let breakPoint = BreakPoint(
                id: UUID().uuidString,
                routeId: route.id,
                location: route.startLocation, // Simplified - would calculate actual position
                scheduledTime: currentTime,
                poi: nil, // Would find nearby POIs
                duration: 900, // 15 minutes
                isCompleted: false,
                notes: "Break #\(i + 1)"
            )
            
            breakPoints.append(breakPoint)
            currentTime = currentTime.addingTimeInterval(interval)
        }
        
        // Save break points to Firestore
        for breakPoint in breakPoints {
            await firestoreService.saveBreakPoint(breakPoint)
        }
        
        return breakPoints
    }
    
    private func startBreakMonitoring() {
        breakTimer?.invalidate()
        breakTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkUpcomingBreaks()
        }
    }
    
    private func checkUpcomingBreaks() {
        guard let nextBreak = scheduledBreaks.first(where: { !$0.isCompleted }) else {
            upcomingBreak = nil
            return
        }
        
        // Check if break time is approaching (within 15 minutes)
        if nextBreak.scheduledTime.timeIntervalSinceNow <= 900 {
            upcomingBreak = nextBreak
            NotificationService.shared.scheduleBreakNotification(
                at: nextBreak.scheduledTime,
                title: "Time for a break!",
                body: "You've been driving for a while. Time to stretch and refresh."
            )
        } else {
            upcomingBreak = nil
        }
    }
    
    func completeBreak(_ breakPoint: BreakPoint) {
        guard let index = scheduledBreaks.firstIndex(where: { $0.id == breakPoint.id }) else { return }
        
        var updatedBreak = breakPoint
        updatedBreak.isCompleted = true
        scheduledBreaks[index] = updatedBreak
        
        // Update in Firestore
        Task {
            await firestoreService.updateBreakPoint(updatedBreak)
        }
        
        // Check for next break
        checkUpcomingBreaks()
    }
    
    func findNearbyPOIs(for breakPoint: BreakPoint) async -> Result<[POI], Error> {
        return await poiService.searchNearbyPOIs(location: breakPoint.location, radius: 5000)
    }
    
    private func clearScheduledBreaks() {
        scheduledBreaks = []
        upcomingBreak = nil
        breakTimer?.invalidate()
        breakTimer = nil
    }
    
    func loadUpcomingBreak() async {
        guard let activeRoute = RouteManager.shared.activeRoute else { return }
        
        let result = await firestoreService.fetchBreakPoints(routeId: activeRoute.id)
        switch result {
        case .success(let breakPoints):
            DispatchQueue.main.async {
                self.scheduledBreaks = breakPoints
                self.upcomingBreak = breakPoints.first(where: { !$0.isCompleted })
                self.startBreakMonitoring()
            }
        case .failure(let error):
            self.error = error
        }
    }
}
