//
//  ACBaseService.swift
//  ACDataSyncing
//
//  Created by Antoine COINTEPAS on 05/10/2017.
//

import Alamofire
import UIKit

class ACBaseService {
    
    private static let baseURLString: String = ""
    //    var sessionManager: SessionManager?
    
    static let sharedInstance: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        let sessionManager = SessionManager(configuration: configuration)
        
        return sessionManager
    }()
    
    static func getRequest(_ url: String, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil) -> DataRequest {
        return ACBaseService.sharedInstance.request(baseURLString + url,
                                                    method: method,
                                                    parameters: parameters,
                                                    encoding: JSONEncoding.default,
                                                    headers:nil)
    }
    
    static func getJSON(_ url: String, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil, completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let request = getRequest(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        
        request.responseJSON(completionHandler: { (response) in
            completionHandler(response)
        })
    }
    
    static func getObject<T:ResponseObjectSerializable>(_ url: String, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.DataResponse<T>) -> Void) {
        let request = getRequest(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        
        _ = request.responseObject { (response: DataResponse<T>) in
            completionHandler(response)
        }
    }
    
    static func getCollection<T:ResponseCollectionSerializable>(_ url: String, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.DataResponse<[T]>) -> Void) {
        let request = getRequest(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        _ = request.responseCollection { (response: DataResponse<[T]>) in
            completionHandler(response)
        }
    }
}
