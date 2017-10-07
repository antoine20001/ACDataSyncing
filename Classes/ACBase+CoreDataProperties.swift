//
//  ACBase+CoreDataProperties.swift
//  ACDataSyncing
//
//  Created by Antoine COINTEPAS on 05/10/2017.
//  Copyright © 2017 Antoine Cointepas. All rights reserved.
//

import Foundation
import CoreData


extension ACBase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ACBase> {
        return NSFetchRequest<ACBase>(entityName: "ACBase")
    }

    @NSManaged public var identifiant: Int16
    @NSManaged public var name: String?
    
    
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> NSSet {
        guard let tmpArray = representation as? [Any] else {
            return []
        }
        var bases: [ACBase] = []
        for item in tmpArray {
            bases.append(ACBase.createOrUpdate(json: item as! [String : Any])!)
        }
        return NSSet(array: bases)
    }
    
    

}
