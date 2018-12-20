import UIKit
import MapKit

class NewViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    let coffeeAnnotations = CoffeeAnnotations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Local Coffee"
        mapView.delegate = self
        setupRegionOnMap()
        mapView.addAnnotations(coffeeAnnotations.coffeeShops)
    }
    
    func setupRegionOnMap() {
        let visableRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(35.495098, -97.526381), latitudinalMeters: 4000, longitudinalMeters: 4000)
        self.mapView.setRegion(self.mapView.regionThatFits(visableRegion), animated: true)
    }
    
    // MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? CoffeeAnnotation else { return nil }
        let identifier = ""
        let color = UIColor.black

        if let dequedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView.markerTintColor = color
        annotationView.glyphImage = UIImage(named: "coffee")
        annotationView.glyphTintColor = .yellow
        annotationView.clusteringIdentifier = identifier
        return annotationView
    }

}

