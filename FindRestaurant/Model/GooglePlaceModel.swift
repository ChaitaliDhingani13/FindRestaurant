//
//  GooglePlace.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 06/07/22.
//

import UIKit
import CoreLocation

struct GooglePlaceModel: Codable {
    let name: String?
    let address: String?
    let reference: String?
    let types: [String]?
    let photos: [Photo]?
    let rating: Double?

    let openingHours: OpeningHours?

    private let geometry: Gemoetry?

    var coordinate: CLLocationCoordinate2D? {
        return CLLocationCoordinate2D(latitude: geometry?.location.lat ?? 0.0, longitude: geometry?.location.lng ?? 0.0)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case address = "vicinity"
        case reference
        case types
        case geometry
        case photos
        case rating
        case openingHours = "opening_hours"
    }
}

extension GooglePlaceModel {
    struct Response: Codable {
        let results: [GooglePlaceModel]?
        let errorMessage: String?
    }
    
    private struct Gemoetry: Codable {
        let location: Coordinate
    }
    struct OpeningHours: Codable {
        let openNow: Bool?

        enum CodingKeys: String, CodingKey {
            case openNow = "open_now"
        }
    }
    struct Photo: Codable {
        let photoReference: String?
        
        enum CodingKeys: String, CodingKey {
            case photoReference = "photo_reference"
        }
    }
    
    private struct Coordinate: Codable {
        let lat: CLLocationDegrees?
        let lng: CLLocationDegrees?
    }
}
