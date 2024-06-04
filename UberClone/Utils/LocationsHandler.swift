//
//  LocationsHandler.swift
//  UberClone
//


import CoreLocation



class LocationsHandler: NSObject, CLLocationManagerDelegate {
    static let shared = LocationsHandler()
    
    var locationManager: CLLocationManager!
    var location: CLLocation?
    
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    
    func locationManager(_ manager: CLLocationManager,
                                               didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
