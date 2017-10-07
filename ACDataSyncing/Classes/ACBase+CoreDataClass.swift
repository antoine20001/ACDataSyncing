//
//  ACBase+CoreDataClass.swift
//  ACDataSyncing
//
//  Created by Antoine COINTEPAS on 05/10/2017.
//  Copyright © 2017 Antoine Cointepas. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper

public class ACBase: NSManagedObject, Mappable, ACBaseSync {
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init?(map: Map) {
        let context = ACDataLoader.sharedInstance.privateContext
        super.init(entity: NSEntityDescription.entity(forEntityName: NSStringFromClass(type(of: self)), in: context)!,
                   insertInto: context)
    }
    
    required public init?(response: HTTPURLResponse, representation: Any) {
        let context = ACDataLoader.sharedInstance.privateContext
        
        let entityName = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        super.init(entity: entity!, insertInto: context)
        
        guard let representation = representation as? [String: Any],
            let name = representation["name"] as? String else {
                return nil
        }
        
        self.identifiant = representation["id"] as! Int16
        self.name = name
    }
    func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> NSSet {
        guard let tmpArray = representation as? [Any] else {
            return []
        }
        var bases: [ACBase] = []
        for item in tmpArray {
            if let representation = item as? [String: Any], let identifiant = representation["id"] as? Int16, let object = ACBase.findOneBy(key: #keyPath(ACBase.identifiant), value: identifiant) {
                object.update(json : representation)
                bases.append(object)
            } else {
            bases.append(type(of: self).init(response: response, representation: item)!)
            }
        }
        return NSSet(array: bases)
    }
    
    public func mapping(map: Map) {
        identifiant <- map["id"]
        name <- map["name"]
    }
    
    public func update(json: [String: Any] ) {
        if let identifiant = json["id"] as? Int16 {
            self.identifiant = identifiant
        }
        if let name = json["name"] as? String {
            self.name = name
        }
    }
    
    public static func createOrUpdate(json: [String : Any]) -> Self? {
        if let identifiant = json["id"] as? Int16, let object = self.findById(identifiant: identifiant) {
            object.update(json : json)
            return object
        }
        return self.init(response: HTTPURLResponse(), representation: json)
    }
    
    override public var description: String {
        return ""
        //        if let ident = identifiant {
        //            print(ident.doubleValue)
        //        }
        //        if let nam = name {
        //            print(nam)
        //        }
        //        return "\(String(describing: self)): { identifiant: \(String(describing: identifiant?.doubleValue ?? 0.0)), name: \(name ?? "NC") }"
    }

}
