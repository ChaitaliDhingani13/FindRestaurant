//
//  PlaceMaker.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 06/07/22.
//

import UIKit
import GoogleMaps

class PlaceMarkerModel: GMSMarker {
    let place: GooglePlaceModel?
    
    init(place: GooglePlaceModel) {
        self.place = place
        super.init()
        
        position = place.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
        icon = ImageUtility.shared.restImg
    }
}

