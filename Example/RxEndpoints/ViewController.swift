//
//  ViewController.swift
//  RxEndpoints
//
//  Created by martindaum on 09/11/2018.
//  Copyright (c) 2018 martindaum. All rights reserved.
//

import UIKit
import RxEndpoints
import RxSwift

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let apiClient: APIClient = APIClient(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        apiClient.request(API.getPosts())
            .subscribe(onSuccess: { posts in
                print(posts)
            }) { error in
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
