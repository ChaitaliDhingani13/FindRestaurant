//
//  GoogleDataProviderModel.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 06/07/22.
//

import UIKit
import CoreLocation

typealias PlacesCompletion = ([GooglePlace]) -> Void
typealias MapCompletion = (GoogleMap?) -> Void

class GoogleDataProviderModel {
    
    func fetchPlaces(coordinate: CLLocationCoordinate2D, completion: @escaping PlacesCompletion
    ) -> Void {
        
        let url = EndPoint.placeApi.rawValue + "location=\(coordinate)&radius=1500&types=restaurant&keyword=cruise&key=\(googleApiKey)"
        WebService.shared.getDataFromWebService(task: url, httpMethod: .POST, modType: GooglePlace.Response.self) { googlePlaceArr, err in
            if err == nil {
                if let result = googlePlaceArr?.results {
                    completion(result)

                }

            } else {
                completion([])

            }
        }
        
    }
    
    func fetchDirection(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, completion: @escaping MapCompletion
    ) -> Void {

        let url = EndPoint.directionAPI.rawValue + "origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(googleApiKey)"
        WebService.shared.getDataFromWebService(task: url, httpMethod: .POST, modType: GoogleMap.self) { googleMap, err in
            if err == nil {
                if let result = googleMap {
                    completion(result)

                }

            } else {
                completion(nil)

            }
        }
        
    }
}
