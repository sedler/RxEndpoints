//
//  APIErrorHandler.swift
//  Endpoints
//
//  Created by Martin Daum on 10.07.18.
//

import Foundation
import RxSwift

public final class APIErrorHandler {
    private let errorSubject = PublishSubject<Void>()
    
    public var customValidation: ((_ statusCode: HTTPStatusCode, _ json: Data?) -> Error?)?
    
    public init() {}

    public var usesCustomValidation: Bool {
        return customValidation != nil
    }
    
    public func validate(statusCode: HTTPStatusCode, json: Data?) -> Error? {
        return customValidation?(statusCode, json)
    }
    
    public var errorObserver: Observable<Void> {
        return errorSubject.asObserver()
    }
    
    func publishError(_ error: Error) {
        errorSubject.onError(error)
    }
}
