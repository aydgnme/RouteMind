import SwiftUI
import MapKit

struct NavigationMapView: UIViewRepresentable {
    @Binding var route: MKRoute?
    @Binding var breakPoints: [CLLocationCoordinate2D]
    @Binding var userTrackingMode: MKUserTrackingMode

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = userTrackingMode
        mapView.showsTraffic = true
        mapView.mapType = .mutedStandard
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.userTrackingMode = userTrackingMode
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        if let route = route {
            uiView.addOverlay(route.polyline)
            uiView.setVisibleMapRect(route.polyline.boundingMapRect,
                                     edgePadding: UIEdgeInsets(top: 100, left: 50, bottom: 200, right: 50),
                                     animated: true)
        }

        for coordinate in breakPoints {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Break Point"
            uiView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: NavigationMapView

        init(_ parent: NavigationMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let identifier = "BreakPoint"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.markerTintColor = .systemGreen
                view?.glyphImage = UIImage(systemName: "pause.circle.fill")
                view?.canShowCallout = true
            } else {
                view?.annotation = annotation
            }
            return view
        }
    }
}


#Preview {
    NavigationMapView(route: .constant(nil), breakPoints: .constant([]), userTrackingMode: .constant(.follow))
}
