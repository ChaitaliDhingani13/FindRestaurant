//
//  LocationManager.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 11/07/22.
//

import Foundation
import CoreLocation
import UIKit


class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    let locationManager : CLLocationManager
    var locationInfoCallBack: ((_ info:LocationInformation)->())!
    var currentLocation = CLLocationCoordinate2D()
    
    override init() {
        locationManager = CLLocationManager()
        //        A designated initializer must ensure that all of the "properties introduced by its class are initialized before it delegates up to a superclass initializer".
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
    }
    
    func start(locationInfoCallBack:@escaping ((_ info: LocationInformation)->())) {
        self.locationInfoCallBack = locationInfoCallBack
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        print(mostRecentLocation)
        let info = LocationInformation()
        info.latitude = mostRecentLocation.coordinate.latitude
        info.longitude = mostRecentLocation.coordinate.longitude
        currentLocation = CLLocationCoordinate2D(latitude: info.latitude ?? 0.0, longitude: info.longitude ?? 0.0)
        self.locationInfoCallBack(info)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Did Location access permission was changed: \(status)")
        
        switch status {
        case .denied:
            print("get Location permission to access")
            
            Utility.alert(message: "The location permission was not authorized. Please enable it in setting to continue.", title: "Location Permission Required.", button1: "Open Setting") { index in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            
        case .notDetermined,.restricted:
            print("get Location permission to access")
            manager.requestWhenInUseAuthorization()
        default:
            print("Permission given")
        }
    }
    
    
    func hasLocationPermission() -> Bool {
        var hasPermission = false
        let manager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 14.0, *) {
                switch manager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    hasPermission = false
                case .authorizedAlways, .authorizedWhenInUse:
                    hasPermission = true
                @unknown default:
                    break
                }
            } else {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    hasPermission = false
                case .authorizedAlways, .authorizedWhenInUse:
                    hasPermission = true
                @unknown default:
                    break
                }
            }
        } else {
            hasPermission = false
        }
        return hasPermission
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationManager.stopUpdatingLocation()
    }
}

class LocationInformation {
    var latitude:CLLocationDegrees?
    var longitude:CLLocationDegrees?
    
    init(latitude:CLLocationDegrees? = Double(0.0),longitude:CLLocationDegrees? = Double(0.0)) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
class CalculateDistance {
    static let sharedInstance = CalculateDistance()
    
    func distanceInMile(source: CLLocationCoordinate2D?, destination: CLLocationCoordinate2D?) -> CGFloat {
        let current = CLLocation(latitude: source?.latitude ?? 0.0, longitude: source?.longitude ?? 0.0)
        let destination = CLLocation(latitude: destination?.latitude ?? 0.0, longitude: destination?.longitude ?? 0.0)
        let distanceInMeters = current.distance(from: destination)
        let float = CGFloat(distanceInMeters)
        let mile = float.getMiles()
        return Double(round(100*mile)/100)

    }
}
