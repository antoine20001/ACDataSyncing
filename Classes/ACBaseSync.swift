//
//  ACBaseSync.swift
//  ACDataSyncing
//
//  Created by Antoine COINTEPAS on 05/10/2017.
//  Copyright © 2017 Antoine Cointepas. All rights reserved.
//

import UIKit
import CoreData
import ObjectMapper

public protocol ACBaseSync : Mappable  {
    func update(json: [String : Any])
    static func createOrUpdate(json: [String : Any]) -> Self?
}

extension ACBaseSync {
    static func findById(identifiant: Int16) -> Self? {
        let objectFetch = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing:self))
        let predicate = NSPredicate(format: "%K == %i", "identifiant", identifiant)
        objectFetch.predicate = predicate
        do {
            let fetchedObjects = try ACDataLoader.sharedInstance.privateContext.fetch(objectFetch) as! [Self]
            if fetchedObjects.count > 0 {
                return fetchedObjects[0]
            } else {
                return nil
            }
        } catch {
            fatalError("Failed to fetch object: \(error)")
        }
        
        return nil
    }
    
    static func findByName(name: String) -> [Self] {
        let objectFetch = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing:self))
        let predicate = NSPredicate(format: "%K == %@", "name", name)
        objectFetch.predicate = predicate
        do {
            let fetchedObjects = try ACDataLoader.sharedInstance.privateContext.fetch(objectFetch) as! [Self]
            return fetchedObjects
            //            if fetchedObjects.count > 0 {
            //                return fetchedObjects[0]
            //            } else {
            //                return nil
            //            }
        } catch {
            fatalError("Failed to fetch object: \(error)")
        }
        
        return []
    }
    
    static func findOneBy(key: String, value: Any) -> Self? {
        let fetchedObjects = findBy(key: key, value: value)
        if fetchedObjects.count > 0 {
            return fetchedObjects[0]
        } else {
            return nil
        }
    }
    
    static func findBy(key: String, value: Any) -> [Self] {
        let objectFetch = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing:self))
        let predicate : NSPredicate
        
        if let value = value as? String {
            predicate = NSPredicate(format: "%K == %@", key, value)
            objectFetch.predicate = predicate
        } else if let value = value as? Int {
            predicate = NSPredicate(format: "%K == %i", key, value)
            objectFetch.predicate = predicate
        } else if let value = value as? Int16 {
            predicate = NSPredicate(format: "%K == %i", key, value)
            objectFetch.predicate = predicate
        } else {
            return []
        }
        do {
            let fetchedObjects = try ACDataLoader.sharedInstance.privateContext.fetch(objectFetch) as! [Self]
            return fetchedObjects
        } catch {
            fatalError("Failed to fetch object: \(error)")
        }
        
        return []
    }
    
    static func findAll() -> [Self] {
        let objectFetch = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing:self))
        do {
            let fetchedObjects = try ACDataLoader.sharedInstance.privateContext.fetch(objectFetch) as! [Self]
            return fetchedObjects
        } catch {
            fatalError("Failed to fetch object: \(error)")
        }
        return []
    }
}
