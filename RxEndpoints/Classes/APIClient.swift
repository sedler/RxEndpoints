//
//  APIClient.swift
//  Endpoints
//
//  Created by martindaum on 06/26/2018.
//

import Alamofire
import RxSwift

public final class APIClient {
    private let manager: Alamofire.SessionManager
    private let baseURL: URL
    private let queue = DispatchQueue(label: NSUUID().uuidString)
    private var headers: [String: String] = [:]
    private var logger: NetworkLogger?
    
    private var internalRequestAdapter: APIClientRequestAdapter?
    private var internalRequestRetrier: APIClientRequestRetrier?
    public var requestValidator: RequestValidator?
    
    public init(baseURL: URL, configuration: URLSessionConfiguration = URLSessionConfiguration.default, trustedDomains: [String] = []) {
        
        var serverTrustPolicies: [String: ServerTrustPolicy] = [:]
        trustedDomains.forEach({ serverTrustPolicies[$0] = .disableEvaluation })
        let serverTrustPolicyManger = ServerTrustPolicyManager(policies: serverTrustPolicies)
        
        self.baseURL = baseURL
        self.manager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManger)
    }
    
    public var requestAdapter: RequestAdapter? {
        set {
            if let adapter = newValue {
                internalRequestAdapter = APIClientRequestAdapter(adapter: adapter)
            } else {
                internalRequestAdapter = nil
            }
            manager.adapter = internalRequestAdapter
        }
        get {
            return internalRequestAdapter?.adapter
        }
    }
    
    public var requestRetrier: RequestRetrier? {
        set {
            if let retrier = newValue {
                internalRequestRetrier = APIClientRequestRetrier(retrier: retrier)
            } else {
                internalRequestRetrier = nil
            }
            manager.retrier = internalRequestRetrier
        }
        get {
            return internalRequestRetrier?.retrier
        }
    }
    
    public func setLogger(_ logger: NetworkLogger) {
        self.logger = logger
    }
    
    public func setHeader(_ value: String, for key: String) {
        headers[key] = value
    }
    
    public func removeHeader(for key: String) {
        headers.removeValue(forKey: key)
    }
    
    public func clearHeaders() {
        headers = [:]
    }
    
    public func request<Response>(_ endpoint: Endpoint<Response>) -> Single<Response> {
        return Single<Response>.create { observer in
            let request = self.manager.request(self.url(path: endpoint.path), method: endpoint.method.httpMethod, parameters: endpoint.parameters, encoding: endpoint.encoding.encoding, headers: self.headers)
            request
                .log(with: self.logger, parameters: endpoint.parameters)
                .customValidate(self.requestValidator)
                .responseData(queue: self.queue) { response in
                    self.logger?.logResponse(response)
                    let result = response.result.flatMap(endpoint.decode)
                    switch result {
                    case let .success(value):
                        observer(.success(value))
                    case let .failure(error):
                        observer(.error(error))
                    }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    private func url(path: String) -> URL {
        if (path.starts(with: "http://") || path.starts(with: "https://")), let url = URL(string: path) {
            return url
        }
        return baseURL.appendingPathComponent(path)
    }
}

extension DataRequest {
    fileprivate func log(with logger: NetworkLogger?, parameters: [String: Any]?) -> DataRequest {
        logger?.logRequest(self, parameters: parameters)
        return self
    }
}

extension DataRequest {
    fileprivate func customValidate(_ validator: RequestValidator?) -> Self {
        guard let validator = validator else {
            return validate()
        }
        
        return validate { request, response, data in
            let statusCode = response.httpStatusCode
            
            do {
                try validator.validate(statusCode: statusCode, request: request, response: response, data: data)
                return .success
            } catch {
                return .failure(error)
            }
        }
    }
}
