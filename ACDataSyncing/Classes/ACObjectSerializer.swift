//
//  ACObjectSerializer.swift
//  ACDataSyncing
//
//  Created by Antoine COINTEPAS on 05/10/2017.
//  Copyright © 2017 Antoine Cointepas. All rights reserved.
//

import Alamofire
import UIKit

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case jsonSerialization(error: Error)
    case objectSerialization(reason: String)
}

protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, representation: Any)
    func update(json: [String: Any])
}

extension Alamofire.DataRequest {
    func responseObject<T: ResponseObjectSerializable>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (Alamofire.DataResponse<T>) -> Void)
        -> Self {
            let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
                guard error == nil else { return .failure(BackendError.network(error: error!)) }
                
                let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
                let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)
                
                guard case let .success(jsonObject) = result else {
                    return .failure(BackendError.jsonSerialization(error: result.error!))
                }
                
                if let representation = jsonObject as? [String: Any],
                    let identifiant = representation["id"] as? Int16,
                    let object = ACDataLoader.findById(type: T.self as! ACBase.Type, identifiant: identifiant) {
                    object.update(json : representation)
                    return .success(object as! T)
                }
                
                guard let response = response, let responseObject = T(response: response, representation: jsonObject) else {
                    return .failure(BackendError.objectSerialization(reason: "JSON could not be serialized: \(jsonObject)"))
                }
                
                return .success(responseObject)
            }
            
            return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

protocol ResponseCollectionSerializable {
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self]
}

extension ResponseCollectionSerializable where Self: ResponseObjectSerializable {
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self] {
        var collection: [Self] = []
        
        if let representation = representation as? [[String: Any]] {
            for itemRepresentation in representation {
                if let identifiant = itemRepresentation["id"] as? Int16,
                    let object = ACDataLoader.findById(type: Self.self as! ACBase.Type, identifiant: identifiant) {
                    object.update(json : itemRepresentation)
                    collection.append(object as! Self)
                } else if let item = Self(response: response, representation: itemRepresentation) {
                    collection.append(item)
                }
            }
        }
        return collection
    }
}

extension DataRequest {
    @discardableResult
    func responseCollection<T: ResponseCollectionSerializable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil else { return .failure(BackendError.network(error: error!)) }
            
            let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonSerializer.serializeResponse(request, response, data, nil)
            
            guard case let .success(jsonObject) = result else {
                return .failure(BackendError.jsonSerialization(error: result.error!))
            }
            
            guard let response = response else {
                let reason = "Response collection could not be serialized due to nil response."
                return .failure(BackendError.objectSerialization(reason: reason))
            }
            
            return .success(T.collection(from: response, withRepresentation: jsonObject))
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
