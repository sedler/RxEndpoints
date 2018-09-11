//
//  API.swift
//  APIClient_Example
//
//  Created by Martin Daum on 26.06.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxEndpoints

struct API {
    static func getPosts() -> Endpoint<[Post]> {
        return Endpoint(path: "posts")
    }
}
