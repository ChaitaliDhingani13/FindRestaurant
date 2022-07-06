//
//  APIHelper.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import Foundation

enum EndPoint: String {
    case placeApi = "place/nearbysearch/json?"
    case directionAPI = "directions/json?"
}

class APIHelper{
    static  let baseUrl = "https://maps.googleapis.com/maps/api/"
}
