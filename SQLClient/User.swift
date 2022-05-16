//
//  User.swift
//  SQLClient
//
//  Created by Helen Wang on 5/6/22.
//  Copyright © 2022 vinayaka s yattinahalli. All rights reserved.
//

import Foundation
class User{
    var uid: Int
    var userName: String?
    var firstName: String?
    var lastName: String?
    var role: String?
    var rank: String?
    
    public init(uid: Int){
        self.uid = uid
    }
    
}
