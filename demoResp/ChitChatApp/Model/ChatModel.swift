//
//  ChatModel.swift
//  ChitChatApp
//
//  Created by Surinder on 20/08/19.
//  Copyright © 2019 Surinder. All rights reserved.
//

import Foundation

class ChatModel {
    var userSendId : String = ""
    var userReciverId : String = ""
    var msg : String = ""
    var timeStamp : String = "0"
    var imgUrl : String = ""
    var msgType : String = ""
    var videoUrl : String = ""
    var msgRead : String = ""
    var TempUUId : String = ""
    
    func setData(dict:[String:Any]){
        userSendId = dict["userSendId"] as? String ?? ""
        userReciverId = dict["userReciverId"] as? String ?? ""
        msg = dict["msg"] as? String ?? ""
        timeStamp = dict["timeStamp"] as? String ?? ""
        imgUrl = dict["imgUrl"] as? String ?? ""
        msgType = dict["msgType"] as? String ?? ""
        videoUrl = dict["videoUrl"] as? String ?? ""
        msgRead = dict["msgRead"] as? String ?? ""
        TempUUId = dict["TempUUId"] as? String ?? ""
    }
}

class MsgChatList : Codable {
    
    var chatUserId : String = ""
    var imgUrl : String = ""
    var lastMsg : String = ""
    var lastUpdate : String = ""
    var userName : String = ""
    var msgReadCount : String = ""
    var msgRead : String = ""
    var lastMsgTime : String = ""
    
    func setData(dict:[String:Any]){
        print(dict)
        chatUserId = dict["chatUserId"] as? String ?? ""
        imgUrl = dict["imgUrl"] as? String ?? ""
        lastUpdate = dict["lastUpdate"] as? String ?? ""
        userName = dict["userName"] as? String ?? ""
        lastMsg = dict["lastMsg"] as? String ?? ""
        msgReadCount = dict["msgReadCount"] as? String ?? ""
        msgRead = dict["msgRead"] as? String ?? ""
        lastMsgTime = dict["lastMsgTime"] as? String ?? ""
    }
    
}
