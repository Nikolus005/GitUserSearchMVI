//
//  DOHttpManager.swift
//  GitUserSearchMVI
//
//  Created by Dogether on 28/04/18.
//  Copyright © 2018 Dogether. All rights reserved.
//

import RxAlamofire
import Alamofire

class DOHttpManager: Alamofire.SessionManager {
    static let shared: DOHttpManager = {
        let configuration = Alamofire.URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let manager = DOHttpManager(configuration: configuration)
        return manager
    }()
}
