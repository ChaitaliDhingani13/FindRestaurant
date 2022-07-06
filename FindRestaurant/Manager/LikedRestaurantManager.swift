//
//  LikedRestaurantManager.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 05/07/22.
//

import Foundation


class LikedRestaurantManager{
    private let _likedRestaurantDataRepository = LikedRestaurantDataRepository()
    
    func createLikedRestaurantRecord(likedRestaurant: LikedRestaurantModel){
        _likedRestaurantDataRepository.create(likedRestaurant: likedRestaurant)
    }
    
    func getAllLikedRestaurantRecords() -> [LikedRestaurantModel]?{
        _likedRestaurantDataRepository.getAll()
    }
    
    func updateLikedRestaurant(likedRestaurant: LikedRestaurantModel) -> Bool{
        _likedRestaurantDataRepository.update(likedRestaurant: likedRestaurant)
    }
    
    func fetchLikedRestaurant(byIdentifier id: String) -> LikedRestaurantModel?{
        _likedRestaurantDataRepository.get(byIdentifier: id)
    }
    
    func deleteLikedRestaurant(id: String) -> Bool{
        _likedRestaurantDataRepository.delete(id: id)
    }
    
    func checkIfLikedRestaurantExist(id : String) -> Bool{
        _likedRestaurantDataRepository.checkIfRecordExist(id: id)
    }
    
}
