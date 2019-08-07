//
//  Uploader.swift
//  RxEndpoints
//
//  Created by Martin Daum on 24.07.19.
//

import Foundation
import Alamofire
import RxSwift

public protocol Uploadable {
    var fileUrl: URL { get }
}

extension URL: Uploadable {
    public var fileUrl: URL {
        return self
    }
}

public enum UploadError: Error {
    case cancelled
}

public enum UploadState {
    case none
    case waiting
    case inProgress(progress: Progress)
}

public final class UploadInfo<T: Uploadable> {
    public let identifier: String
    public let object: T
    let request: UploadRequest
    
    private let stateSubject = BehaviorSubject<UploadState>(value: .none)

    public private(set) lazy var state: Observable<UploadState> = stateSubject.asObservable()
    
    init(_ object: T, request: UploadRequest) {
        self.identifier = NSUUID().uuidString
        self.object = object
        self.request = request
        
        request
            .uploadProgress { [weak self] progess in
                if progess.fractionCompleted > 0 {
                    self?.stateSubject.onNext(.inProgress(progress: progess))
                }
            }
            .response { [weak self] response in
                if let error = response.error {
                    self?.stateSubject.onError(error)
                } else {
                    self?.stateSubject.onCompleted()
                }
            }
    }
    
    public func upload() {
        request.resume()
        stateSubject.onNext(.waiting)
    }
    
    public func cancel() {
        request.cancel()
        stateSubject.onError(UploadError.cancelled)
    }
}

public final class Uploader<T: Uploadable> {
    private let manager: Alamofire.SessionManager
    
    private var internalRequestAdapter: APIClientRequestAdapter?
    
    private var queue: [UploadInfo<T>] = []
    
    public init(configuration: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: NSUUID().uuidString), trustedDomains: [String] = []) {
        var serverTrustPolicies: [String: ServerTrustPolicy] = [:]
        trustedDomains.forEach({ serverTrustPolicies[$0] = .disableEvaluation })
        let serverTrustPolicyManger = ServerTrustPolicyManager(policies: serverTrustPolicies)

        configuration.httpMaximumConnectionsPerHost = 10
        
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
    
    public func upload(_ uploadable: T, toURL url: URL, method: Method = .post, headers: [String: String]? = nil, startImmediately: Bool = true) -> UploadInfo<T> {
        let uploadRequest = manager.upload(uploadable.fileUrl, to: url, method: method.httpMethod, headers: headers)
        let info = UploadInfo<T>(uploadable, request: uploadRequest)
        queue.append(info)
        
        if startImmediately {
            info.upload()
        }
        
        return info
    }
    
    public func activeUploads(cleanQueue: Bool = false) -> [UploadInfo<T>] {
        if cleanQueue {
            self.cleanQueue()
        }
        return queue
    }
    
    public func cleanQueue() {
        var runningUploads: [UploadInfo<T>] = []
        for upload in queue {
            if upload.request.uploadProgress.isCancelled || upload.request.uploadProgress.isFinished {
                continue
            }
            runningUploads.append(upload)
        }
        queue = runningUploads
    }
}
