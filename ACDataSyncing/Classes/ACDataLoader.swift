//
//  ACDataLoader.swift
//  ACDataSyncing
//
//  Created by Antoine COINTEPAS on 05/10/2017.
//  Copyright © 2017 Antoine Cointepas. All rights reserved.
//

import UIKit
import CoreData

public struct ACDataLoader {
    
    static let size = 500
    var privateContext : NSManagedObjectContext
    var parentContext : NSManagedObjectContext?
    
    public static let sharedInstance : ACDataLoader = {
        let instance = ACDataLoader.init()
        return instance
    }()
    
    init() {
        privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        parentContext = UIApplication.shared.delegate?.persistentContainer.viewContext
        privateContext.parent = parentContext
        //moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    
    static func sendNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DataLoader_Finished"), object: nil)
    }
    
    
    //    static func getContext() -> NSManagedObjectContext {
    //        var moc = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
    //        moc.parent = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //        //moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    //        return moc
    //    }
    
    //    + (NSManagedObjectContext*) newObjectContext
    //    {
    //    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];           //step 1
    //
    //    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //
    //    [context setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    //    [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //    [appDelegate.managedObjectContext observeContextOnMainThread:context];
    //
    //    return context;
    //    }
    
    public static func saveContext() {
        
        let privateContext = self.sharedInstance.privateContext
        let parentContext = self.sharedInstance.parentContext
        privateContext.perform {
            do {
                try privateContext.save()
                parentContext?.performAndWait {
                    do {
                        try parentContext?.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        
        //        DispatchQueue.main.async {
        //            let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        //            appDel.saveContext()
        //        }
    }
    
    public static func findById<T: ACBase>(type: T.Type, identifiant: Int16) -> T? {
        //        print("DataLoader findById type : " + String(describing:type))
        let objectFetch = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing:type))
        let predicate = NSPredicate(format: "%K == %i", "identifiant", identifiant)
        objectFetch.predicate = predicate
        do {
            let fetchedObjects = try self.sharedInstance.privateContext.fetch(objectFetch) as! [T]
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
}
