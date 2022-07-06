//
//  LikedRestaurant+CoreDataProperties.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 05/07/22.
//
//

import Foundation
import CoreData


extension LikedRestaurant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikedRestaurant> {
        return NSFetchRequest<LikedRestaurant>(entityName: "LikedRestaurant")
    }

    @NSManaged public var address: String?
    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var photoReference: String?
    @NSManaged public var rating: Double
    @NSManaged public var openNow: Bool
    @NSManaged public var distance: Double
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double

    
    func convertToRestaurant() -> LikedRestaurantModel{
        return LikedRestaurantModel(name: self.name, address: self.address, photoReference: self.photoReference, distance: self.distance, rating: self.rating, latitude: self.latitude, longitude: self.longitude, openNow: self.openNow, id: self.id)
        
    }

    
}

extension LikedRestaurant : Identifiable {

}
