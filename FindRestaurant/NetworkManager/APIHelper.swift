//
//  APIHelper.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import Foundation

enum EndPoint: String {
    case placeAPI = "place/nearbysearch/json?"
    case directionAPI = "directions/json?"
    case photoAPI = "lace/photo?maxwidth=5184&photoreference="
}

class APIHelper{
    static  let baseUrl = "https://maps.googleapis.com/maps/api/"
}
