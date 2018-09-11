//
//  NetworkLogger.swift
//  Endpoints
//
//  Created by Martin Daum on 26.06.18.
//

import Foundation
import Alamofire

public final class NetworkLogger {
    private var closure: (_ data: String, _ isSuccess: Bool) -> Void
    
    public init(closure: ((_ data: String, _ isSuccess: Bool) -> Void)? = nil) {
        self.closure = closure ?? { data, _ in print(data) }
    }
    
    func logRequest(_ request: DataRequest, parameters: [String: Any]?) {
        guard  let method = request.request?.httpMethod, let path = request.request?.url?.absoluteString else {
            return
        }
        
        var log = "↗️ \(method) \(path)"
        if let headers = request.request?.allHTTPHeaderFields,
            !headers.isEmpty,
            let json = getJSONString(headers) {
            log += "\nHEADERS ----------"
            log += "\n\(json)"
        }
        
        if let parameters = parameters,
            !parameters.isEmpty,
            let json = getJSONString(parameters) {
            log += "\nPARAMETERS ----------"
            log += "\n\(json)"
        }
        
        closure(log, true)
    }
    
    func logResponse(_ response: DataResponse<Data>) {
        guard let request = response.request, let method = request.httpMethod, let statusCode = response.response?.statusCode, let path = request.url?.absoluteString else {
            return
        }
        
        var log = "↘️ \(method) \(statusCode) \(path)"
        if let headers = response.response?.allHeaderFields,
            let json = getJSONString(headers) {
            log += "\nHEADERS ----------"
            log += "\n\(json)"
        }
        
        if let data = response.data,
            let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let json = getJSONString(dict) {
            log += "\nRESPONSE ----------"
            log += "\n\(json)"
        }
        
        closure(log, response.result.isSuccess)
    }
    
    private func getJSONString(_ object: Any) -> String? {
        guard let json = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else {
            return nil
        }
        return String(data: json, encoding: .utf8)
    }
}
