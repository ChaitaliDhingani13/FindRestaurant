//
//  CoreDataTests.swift
//  FindRestaurantTests
//
//  Created by Chaitali Patel on 14/07/22.
//

import XCTest
import CoreData
@testable import FindRestaurant

class CoreDataTests: XCTestCase {
    
    
    var likedRestaurantManager: LikedRestaurantManager!
    
    override func setUp() {
        super.setUp()
        likedRestaurantManager = LikedRestaurantManager.shared
    }
    
    func test_coreDataStackInitialization() {
        let coreDataStack = PersistentStorage.shared.persistentContainer
        XCTAssertNotNil( coreDataStack )
    }
    
    func test_create_wishList() {
        let rest = LikedRestaurantModel(name: "test", address: "test", photoReference: "test", distance: 10.0, rating: 4.5, latitude: 0.0, longitude: 0.0, openNow: true, id: "aaa")
        let wishList = likedRestaurantManager.createLikedRestaurantRecord(likedRestaurant: rest)
        XCTAssertNotNil( wishList )
    }
    
    func test_fetch_all_wishList() {
        let results = likedRestaurantManager.getAllLikedRestaurantRecords()
        XCTAssertEqual(results?.count, 3)
    }
    
    func test_remove_wishList() {
        
        let items = likedRestaurantManager.getAllLikedRestaurantRecords()
        let wishList = items![0]
        let numberOfItems = items?.count
        let _ = likedRestaurantManager.deleteLikedRestaurant(id: wishList.id ?? "")
        XCTAssertEqual(likedRestaurantManager.getAllLikedRestaurantRecords()?.count, numberOfItems!-1)
    }
    
    func test_update_wishList(){
        
        let items = likedRestaurantManager.getAllLikedRestaurantRecords()
        let wishList = items![0]
        let _ = LikedRestaurantManager.shared.updateLikedRestaurant(likedRestaurant: wishList)
        let itemsFetched = likedRestaurantManager.getAllLikedRestaurantRecords()
        let item = itemsFetched![0]
        XCTAssertEqual(wishList.name, item.name)
    }
    
}
