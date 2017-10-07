//
//  ACApplicationDelegate.swift
//  ACDataSyncing
//
//  Created by Antoine COINTEPAS on 05/10/2017.
//  Copyright © 2017 Antoine Cointepas. All rights reserved.
//

import UIKit
import CoreData

private var xoAssociationKey: UInt8 = 0

extension UIApplicationDelegate {
    // MARK: - Core Data stack
    var _persistentContainer: NSPersistentContainer? {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? NSPersistentContainer
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    var persistentContainer : NSPersistentContainer {
        if _persistentContainer == nil {
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        
        let container = NSPersistentContainer(name: appName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        _persistentContainer = container
        }
        
        return _persistentContainer!
    }
}
