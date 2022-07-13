//
//  CalculateDistance.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 06/07/22.
//

import Foundation
import CoreLocation
import UIKit

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
