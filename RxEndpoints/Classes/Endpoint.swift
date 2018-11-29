//
//  Endpoint.swift
//  Endpoints
//
//  Created by martindaum on 06/26/2018.
//

import Foundation
import Alamofire

public enum Method: String {
    case options, get, head, post, put, patch, delete, trace, connect
    
    var httpMethod: Alamofire.HTTPMethod {
        switch self {
        case .options:
            return HTTPMethod.options
        case .get:
            return HTTPMethod.get
        case .head:
            return HTTPMethod.head
        case .post:
            return HTTPMethod.post
        case .put:
            return HTTPMethod.put
        case .patch:
            return HTTPMethod.patch
        case .delete:
            return HTTPMethod.delete
        case .trace:
            return HTTPMethod.trace
        case .connect:
            return HTTPMethod.connect
        }
    }
}

public enum ParameterEncoding {
    case json, url, plist
    
    var encoding: Alamofire.ParameterEncoding {
        switch self {
        case .url:
            return URLEncoding.methodDependent
        case .json:
            return JSONEncoding.default
        case .plist:
            return PropertyListEncoding.default
        }
    }
}

public final class Endpoint<Response> {
    let method: Method
    let path: String
    let parameters: [String: Any]?
    let encoding: ParameterEncoding
    let decode: (Data) throws -> Response
    
    public init(method: Method = .get, path: String, parameters: [String: Any]? = nil, encoding: ParameterEncoding = .url, decode: @escaping (Data) throws -> Response) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.encoding = encoding
        self.decode = decode
    }
}

extension Endpoint where Response: Swift.Decodable {
    public convenience init(method: Method = .get, path: String, parameters: [String: Any]? = nil, encoding: ParameterEncoding = .url, decoder: JSONDecoder = JSONDecoder()) {
        self.init(method: method, path: path, parameters: parameters, encoding: encoding) {
            try decoder.decode(Response.self, from: $0)
        }
    }
}

extension Endpoint where Response == Void {
    public convenience init(method: Method = .get, path: String, parameters: [String: Any]? = nil, encoding: ParameterEncoding = .url) {
        self.init(method: method, path: path, parameters: parameters, encoding: encoding, decode: { _ in () })
    }
}
