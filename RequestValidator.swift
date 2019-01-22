//
//  RequestValidator.swift
//  RxEndpoints
//
//  Created by Martin Daum on 22.01.19.
//

import Foundation
import Alamofire

public protocol RequestValidator {
    func validate(statusCode: HTTPStatusCode, request: URLRequest?, response: HTTPURLResponse, data: Data?) throws
}
