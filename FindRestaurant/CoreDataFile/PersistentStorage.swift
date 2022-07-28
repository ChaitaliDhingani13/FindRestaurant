//
//  PersistentStorage.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 05/07/22.
//


import Foundation
import CoreData

open class PersistentStorage {
    
    public init(){}
    static let shared = PersistentStorage()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "FindRestaurant")
        let desc = NSPersistentStoreDescription()
        desc.shouldMigrateStoreAutomatically = true
        desc.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [desc]

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    lazy var context = persistentContainer.viewContext
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchManagedObject<T: NSManagedObject>(managedObject: T.Type) -> [T]?
    {
        do {
            guard let result = try context.fetch(managedObject.fetchRequest()) as? [T] else {return nil}
            
            return result

        } catch let error {
            debugPrint(error)
        }

        return nil
    }
    
}
