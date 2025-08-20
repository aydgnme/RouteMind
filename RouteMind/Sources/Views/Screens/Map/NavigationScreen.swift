import SwiftUI
import MapKit

struct NavigationScreen: View {
    @State private var route: MKRoute?
    @State private var breakPoints: [CLLocationCoordinate2D] = []
    @State private var userTrackingMode: MKUserTrackingMode = .follow

    var body: some View {
        ZStack {
            NavigationMapView(route: $route, breakPoints: $breakPoints, userTrackingMode: $userTrackingMode)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Button("Start Navigation") {
                        calculateRoute()
                    }
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Spacer()
                }
                .padding()
            }
        }
    }

    func calculateRoute() {
        let source = MKMapItem(placemark: .init(coordinate: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784))) // Istanbul
        let destination = MKMapItem(placemark: .init(coordinate: CLLocationCoordinate2D(latitude: 39.9208, longitude: 32.8541))) // Ankara

        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                self.route = route
                self.breakPoints = [route.polyline.points()[Int(route.polyline.pointCount/2)].coordinate] // örnek break point
            }
        }
    }
}


#Preview {
    NavigationScreen()
}
