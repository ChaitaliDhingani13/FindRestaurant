//
//  likedResDataRepository.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 05/07/22.
//

import Foundation
import CoreData

protocol LikedRestaurantRepository {
    
    
    
    
    func create(likedRestaurant: LikedRestaurantModel)
    func getAll() -> [LikedRestaurantModel]?
    func get(byIdentifier id:String) -> LikedRestaurantModel?
    func update(likedRestaurant: LikedRestaurantModel) -> Bool
    func delete(id: String) -> Bool
    func checkIfRecordExist(id: String) -> Bool
}


struct LikedRestaurantDataRepository: LikedRestaurantRepository{
    func checkIfRecordExist(id: String) -> Bool {
        
        let results = getRestaurantByID(byIdentifier: id)
        guard results != nil else {return false}
        return true
    }
    
    func create(likedRestaurant: LikedRestaurantModel) {
        
        let likedRes = LikedRestaurant(context: PersistentStorage.shared.context)
        likedRes.name = likedRestaurant.name
        likedRes.address = likedRestaurant.address
        likedRes.photoReference = likedRestaurant.photoReference
        likedRes.rating = likedRestaurant.rating ?? 0.0
        likedRes.openNow = likedRestaurant.openNow ?? false
        likedRes.distance = likedRestaurant.distance ?? 0.0
        likedRes.id = likedRestaurant.id
        likedRes.latitude = likedRestaurant.latitude ?? 0.0
        likedRes.longitude = likedRestaurant.longitude ?? 0.0

        PersistentStorage.shared.saveContext()
    }
    
    func getAll() -> [LikedRestaurantModel]? {
        let results = PersistentStorage.shared.fetchManagedObject(managedObject: LikedRestaurant.self)
        var likedRess: [LikedRestaurantModel] = []
        results?.forEach({ (likedRestaurant) in
            likedRess.append(likedRestaurant.convertToRestaurant())
        })
        return likedRess
    }
    
    func get(byIdentifier id: String) -> LikedRestaurantModel? {
        let results = getRestaurantByID(byIdentifier: id)
        
        guard results != nil else {return nil}
        
        return results?.convertToRestaurant()
    }
    
    func update(likedRestaurant: LikedRestaurantModel) -> Bool {
        let restaurant = getRestaurantByID(byIdentifier: likedRestaurant.id!)
        guard restaurant != nil else {return false}
        
        restaurant?.name = likedRestaurant.name
        restaurant?.address = likedRestaurant.address
        restaurant?.photoReference = likedRestaurant.photoReference
        restaurant?.rating = likedRestaurant.rating ?? 0.0
        restaurant?.openNow = likedRestaurant.openNow ?? false
        restaurant?.distance = likedRestaurant.distance ?? 0.0
        restaurant?.latitude = likedRestaurant.latitude ?? 0.0
        restaurant?.longitude = likedRestaurant.longitude ?? 0.0

//        restaurant?.id = likedRestaurant.id
        
        PersistentStorage.shared.saveContext()
        
        return true
    }
    
    func delete(id: String) -> Bool{
        let likedRestaurant = getRestaurantByID(byIdentifier: id)
        guard likedRestaurant != nil else {return false}
        
        PersistentStorage.shared.context.delete(likedRestaurant!)
        PersistentStorage.shared.saveContext()
        
        return true
    }
    
    private func getRestaurantByID(byIdentifier id:String) -> LikedRestaurant?{
        
        let fetchRequest = NSFetchRequest<LikedRestaurant>(entityName: "LikedRestaurant")
        let predicate = NSPredicate(format: "id==%@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do{
            
            let results = try PersistentStorage.shared.context.fetch(fetchRequest).first
            guard results != nil else {return nil}
            
            return results
        }
        catch let error{
            debugPrint("Error is \(error)")
            return nil
        }
    }
}
