//
//  RequestRetrier.swift
//  RxEndpoints
//
//  Created by Martin Daum on 22.01.19.
//

import Foundation
import Alamofire

public protocol RequestRetrier {
    func should(retry request: URLRequest, with error: Error, completion: @escaping (_ shouldRetry: Bool, _ timeDelay: TimeInterval) -> Void)
}

struct APIClientRequestRetrier: Alamofire.RequestRetrier {
    let retrier: RequestRetrier

    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard let request = request.request else {
            completion(false, 0)
            return
        }
        return retrier.should(retry: request, with: error, completion: completion)
    }
}
