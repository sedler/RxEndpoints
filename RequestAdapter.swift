//
//  File.swift
//  RxEndpoints
//
//  Created by Martin Daum on 22.01.19.
//

import Foundation
import Alamofire

public protocol RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest
}

struct APIClientRequestAdapter: Alamofire.RequestAdapter {
    let adapter: RequestAdapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return try adapter.adapt(urlRequest)
    }
}
