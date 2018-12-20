import CoreLocation
import MapKit
import UIKit

// In the plist, add 'Privacy - Location When In Use Usage Description'

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var startTextField: UITextField!
    @IBOutlet var endTextField: UITextField!
    
    let locationManger = CLLocationManager()
    var usersLastLocation: CLLocation?
    var regionInMeters: Double = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "MapKit"
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkLocationServices()
    }
    
    // CoreLocation
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            turnOnLocationServicesAlert()
        }
    }
    
    func setupLocationManager() {
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManger.startUpdatingLocation()
            centerOnUsersLocation()
        case .notDetermined:
            locationManger.requestWhenInUseAuthorization()
        case .denied:
            locationDeniedAlert()
            break
        case .restricted:
            // Show alert showing them its restricted, i.e. by parental controls
            break
        default:
            break
        }
    }
    
    func locationDeniedAlert() {
        let alertController = UIAlertController(title: "Location Denied", message: "Change app location preferences in Settings", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    func turnOnLocationServicesAlert() {
        let alertController = UIAlertController(title: "Turn on location services", message: "Do it", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    func centerOnUsersLocation() {
        if let location = locationManger.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        
        manager.stopUpdatingLocation()
        usersLastLocation = userLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    // MapView Polyline view
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    
    // CLGeocoder
    
    func getCoordinatesForLocationsText() {
        
        // Clear old pins and route first
        let annotations = self.mapView.annotations
        mapView.removeAnnotations(annotations)
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        guard let startAddress = startTextField.text,
            !startAddress.isEmpty else {
                print("No text in the START text field")
                return
        }
        
        guard let endAddress = endTextField.text,
            !endAddress.isEmpty else {
                print("No text in the END text field")
                return
        }
        
        var startPin: CustomPin?
        var endPin: CustomPin?
        
        // Get coordinates for the first location
        CLGeocoder().geocodeAddressString(startAddress) { (placemarks, error) in
            if error != nil {
                print("CLGeocoder error")
                return
            }
            
            if let placemark = placemarks?[0] {
                let startLatitudeString = String(format: "%.04f", placemark.location?.coordinate.latitude ?? 0.0)
                let startLongitudeString = String(format: "%.04f", placemark.location?.coordinate.longitude ?? 0.0)
                print("👉 Start Address text = \(startAddress), latitude: \(startLatitudeString), longitude: \(startLongitudeString)")
                
                let startLatitude = placemark.location?.coordinate.latitude ?? 0.0
                let startLongitude = placemark.location?.coordinate.longitude ?? 0.0
                let coordinate = CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
                let pin = CustomPin(pinTitle: startAddress, pinSubTitle: startAddress, location: coordinate)
                startPin = pin

                // Get coordinates for the second location
                CLGeocoder().geocodeAddressString(endAddress) { (placemarks, error) in
                    if error != nil {
                        print("CLGeocoder error")
                        return
                    }
                    
                    if let placemark = placemarks?[0] {
                        let endLatitudeText = String(format: "%.04f", placemark.location?.coordinate.latitude ?? 0.0)
                        let endLongitudeText = String(format: "%.04f", placemark.location?.coordinate.longitude ?? 0.0)
                        print("👉 End Address text = \(endAddress), latitude: \(endLatitudeText), longitude: \(endLongitudeText)")
                        let endLatitude = placemark.location?.coordinate.latitude ?? 0.0
                        let endLongitude = placemark.location?.coordinate.longitude ?? 0.0
                        let coordinate = CLLocationCoordinate2D(latitude: endLatitude, longitude: endLongitude)
                        let pin = CustomPin(pinTitle: endAddress, pinSubTitle: endAddress, location: coordinate)
                        endPin = pin

                        // Now that we have the coordinates, call the getRoute Method
                        if let startPin = startPin,
                            let endPin = endPin {
                            self.getRouteForPins(startPin: startPin, endPin: endPin)
                        }
                    }
                }
            }
        }
    }
    
    func getRouteForPins(startPin: CustomPin, endPin: CustomPin) {
        self.mapView.addAnnotation(startPin)
        self.mapView.addAnnotation(endPin)
        
        //In order to get directions for routes between our two locations, we need to create a placmark using MKPlaceMark class which accepts coordinate. We will create two placmarks for source location and destination location.
        
        let startPlacemark = MKPlacemark(coordinate: startPin.coordinate)
        let endPlacemark = MKPlacemark(coordinate: endPin.coordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: startPlacemark)
        directionRequest.destination = MKMapItem(placemark: endPlacemark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            if let error = error {
                print("🔴 directions error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else { return }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            var mapRect = route.polyline.boundingMapRect
            // Add Padding
            let widthPadding = mapRect.size.width * 0.25
            let heightPadding = mapRect.size.height * 0.25
            // Center route
            mapRect.origin.x -= widthPadding/2
            mapRect.origin.y -= heightPadding/2
            
            mapRect.size.width += widthPadding
            mapRect.size.height += heightPadding
            
            let region = MKCoordinateRegion(mapRect)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func getAddressFromUserCoordinates() {
        guard let userLocation = usersLastLocation else {
            print("User's location unavailable")
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Reverse geocoder error = \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks")
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""
            
            DispatchQueue.main.async {
                self.startTextField.text = "\(streetNumber) \(streetName) \(city) \(state) \(country)"
            }
        }
        
    }
    
    // Action
    
    @IBAction func getMyLocationTapped(_ sender: UIButton) {
        getAddressFromUserCoordinates()
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        startTextField.text = ""
        endTextField.text = ""
    }
    
    @IBAction func routeButtonTapped(_ sender: UIButton) {
        getCoordinatesForLocationsText()
    }
    
}
