//
//  Post.swift
//  APIClient_Example
//
//  Created by Martin Daum on 26.06.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
