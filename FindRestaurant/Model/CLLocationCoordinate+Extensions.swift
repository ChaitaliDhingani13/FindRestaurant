//
//  CLLocationCoordinate2D.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 06/07/22.
//

import CoreLocation

extension CLLocationCoordinate2D: CustomStringConvertible {
  public var description: String {
    let lat = String(format: "%.6f", latitude)
    let lng = String(format: "%.6f", longitude)
    return "\(lat),\(lng)"
  }
}
