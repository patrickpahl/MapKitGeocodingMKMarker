import UIKit
import MapKit

class CoffeeAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    init(_ latitude:CLLocationDegrees, _ longitude:CLLocationDegrees, title:String, subtitle:String){
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.title = title
        self.subtitle = subtitle
    }
}

class CoffeeAnnotations: NSObject {
    var coffeeShops:[CoffeeAnnotation]
    
    override init(){
        coffeeShops = [CoffeeAnnotation(35.493458, -97.525262, title: "Cuppie and Joes", subtitle:"23rd Street")]
        coffeeShops += [CoffeeAnnotation(35.475774, -97.519430, title: "Elemental Coffee", subtitle:"Midtown")]
        coffeeShops += [CoffeeAnnotation(35.477611, -97.514263, title: "Coffee Slingers", subtitle:"Downtown")]
        coffeeShops += [CoffeeAnnotation(35.521499, -97.529998, title: "Vintage Coffee", subtitle:"50th Street")]
        coffeeShops += [CoffeeAnnotation(35.501462, -97.533541, title: "The Red Cup", subtitle:"Classen")]
    }
}
