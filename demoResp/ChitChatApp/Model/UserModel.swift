//
//  UserModel.swift
//  ChitChatApp
//
//  Created by Surinder on 20/08/19.
//  Copyright © 2019 Surinder. All rights reserved.
//

import Foundation

class UserModel : Codable{
    
    var name : String = ""
    var imgUrl : String = ""
    var email : String = ""
    var userId : String = ""
    var lastScene : String = ""
    var phoneNumber : String = ""
    var latitude : String = ""
    var longitude : String = ""
    var token : String = ""
    var deviceToken : String = ""
    var isOnline : String  = ""
    
    func setData(dict:[String:Any]){
        name      = dict["name"] as? String ?? ""
        imgUrl    = dict["imgUrl"] as? String ?? ""
        
        email     = dict["email"] as? String ?? ""
        userId    = dict["userId"] as? String ?? ""
        lastScene = dict["lastScene"] as? String ?? ""
        phoneNumber =  dict["phoneNumber"] as? String ?? ""
        latitude  = dict["latitude"] as? String ?? ""
        longitude = dict["latitude"] as? String ?? ""
        token = dict["token"] as? String ?? ""
        deviceToken = dict["deviceToken"] as? String ?? ""
        isOnline = dict["isOnline"] as? String ?? ""
        
    }
    
    
}
