//
//  MessageViewModel.swift
//  ChitChatApp
//
//  Created by Surinder on 24/08/19.
//  Copyright © 2019 Surinder. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class MessageViewModel: NSObject {
    
    static var shared = MessageViewModel()
    
    var userOnlineListArray = [UserModel]()
    var userActiveArray = [UserModel]()
    var msgTblArray = [String]()
    var chatMsgArray = [ChatModel]()
    var msgChatListArray = [MsgChatList]()
    var tempTimeStampArray = [[String:String]]()
    
    var msgCount : Int = 0
    /*
    func getFireStoreUserList(completion:@escaping completion){
        Indicator.shared.start("Please wait...")
        UtilityManager.fireStoreRef.collection("users").getDocuments { (snapshot, error) in
            Indicator.shared.stop()
            guard let mySnapshot = snapshot?.documents as? [DataSnapshot] else {return}
            print(mySnapshot)
        }
    }
    */
    
    func getUserList(completion:@escaping completion){
        
    if Connectivity.isConnectedToInternet(){
            Indicator.shared.start("Please wait...")
        UtilityManager.firebaseRef.child("users").observe(.value) { (snapshot) in
               Indicator.shared.stop()
            guard let mySnapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for snap in mySnapshot {
              if let userDictionary = snap.value as? [String: String] {
                    let obj = UserModel()
                    obj.setData(dict: userDictionary)
                     
                if !self.userOnlineListArray.contains(where: {$0.userId == obj.userId}){
                    
                    if obj.isOnline == "true" && obj.userId != UtilityManager.userDataDecoded().userId {
                        self.userOnlineListArray.append(obj)
                    }else{
                        self.userOnlineListArray.removeAll(where: {$0.userId == obj.userId})
                    }
                }else{
                    if self.userOnlineListArray.contains(where: {($0.userId == obj.userId)}){
                          if obj.isOnline == "false"{
                                self.userOnlineListArray.removeAll(where: {$0.userId == obj.userId})
                          }
                     }
                  }
               }
            }
            completion(true)
          }
        }else
        {
            UtilityManager().showAlert(title: "Internet issue", subTitle: "No internet connection", error: true, warning: false, success: false)
            completion(false)
        }
    }
    
    func getMessageUserList(completion:@escaping completion){
        
        if Connectivity.isConnectedToInternet(){
            UtilityManager.firebaseRef.child("messageUserList").child(UtilityManager.userDataDecoded().userId).observe(.value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:String]{
                    print(dictionary)
                  completion(true)
                }
            }
        }else{
            UtilityManager().showAlert(title: "Internet issue", subTitle: "No internet connection", error: true, warning: false, success: false)
            completion(false)
        }
        
    }
    
    func getMessageIndividual(frndChatId:String,completion:@escaping completion){
        if Connectivity.isConnectedToInternet(){
            
            let fromId = UtilityManager.userDataDecoded().userId
            let toId = frndChatId
            
            let chatRoomId = (fromId < toId) ? fromId + "_" + toId : toId + "_" + fromId
            
            UtilityManager.firebaseRef.child("messageUserList")
                .child(chatRoomId).observe(.value) { (snapshot) in
                    guard let mySnapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    for snap in mySnapshot {
                    if var userDictionary = snap.value as? [String: String] {
                     
                        let obj = ChatModel()
                        let uuid = UUID().uuidString
                        userDictionary["TempUUId"] = uuid
                        obj.setData(dict: userDictionary)
                        if !self.chatMsgArray.contains(where: {$0.timeStamp == obj.timeStamp}){
                             self.chatMsgArray.append(obj)
                        }else{
                            self.chatMsgArray.filter({$0.timeStamp == obj.timeStamp}).first?.imgUrl = obj.imgUrl
                            self.chatMsgArray.filter({$0.timeStamp == obj.timeStamp}).first?.msgType = obj.msgType
                            self.chatMsgArray.filter({$0.timeStamp == obj.timeStamp}).first?.videoUrl = obj.videoUrl
                        }
                      }
                    }
                  completion(true)
            }
        }else{
            UtilityManager().showAlert(title: "Internet issue", subTitle: "No internet connection", error: true, warning: false, success: false)
            completion(false)
        }
    }
    
    func sendMsg(frndChatId:String,msg:String,imgUrl:String,msgType:String,videoUrl:String,isUpdate:Bool,uImgid:String,completion:@escaping (Bool,String)->()){
        
       if Connectivity.isConnectedToInternet(){
        
     if isUpdate == false{
        let timeIntervl = NSDate().timeIntervalSince1970
        let value = ["userSendId":UtilityManager.userDataDecoded().userId,"userReciverId":frndChatId,"msg":msg,"timeStamp": "\(timeIntervl)","imgUrl":imgUrl,"msgType":msgType,"videoUrl":videoUrl]
        
        let fromId = UtilityManager.userDataDecoded().userId
        let toId = frndChatId
        
        let chatRoomId = (fromId < toId) ? fromId + "_" + toId : toId + "_" + fromId
        
        let kingId = UtilityManager.firebaseRef.childByAutoId()
        print("unique generate autoChild Id :-",kingId.key ?? "")
        UtilityManager.firebaseRef.child("messageUserList").child(chatRoomId).child(kingId.key ?? "").setValue(value) { (error, dRef) in
            
            if error != nil{
                UtilityManager().showAlert(title: "Oops!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
                completion(false, "")
            }else{
                if msgType == "img" || msgType == "mov"{
                    let uid = UUID().uuidString
                    let dict = ["imgId":uid,"uniqueChildId":kingId.key ?? "","timeIntervl":"\(timeIntervl)"]
                    self.tempTimeStampArray.append(dict)
                  print("unique generate autoChild Id :-",self.tempTimeStampArray)
                    completion(true, uid)
                }else{
                    completion(true , "")
                }
                
            }
        }
      }else{
        
        let fromId = UtilityManager.userDataDecoded().userId
        let toId = frndChatId
        
        let chatRoomId = (fromId < toId) ? fromId + "_" + toId : toId + "_" + fromId
        
        let value = ["imgUrl":imgUrl,"msgType":msgType,"videoUrl":videoUrl]
        
        let userDict = self.tempTimeStampArray.filter({$0["imgId"] == uImgid})
        print("imgId:-",uImgid)
        
        if userDict.count != 0{
        UtilityManager.firebaseRef.child("messageUserList").child(chatRoomId).child(userDict[0]["uniqueChildId"] ?? "").updateChildValues(value) { (error, dRef) in
            
            if error != nil{
                UtilityManager().showAlert(title: "Oops!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
                completion(false, "")
            }else{
                
                print("update unique generate autoChild Id :-",self.tempTimeStampArray.last ?? "")
                completion(true, "")
            }
          }
         }
        }
       }else{
          UtilityManager().showAlert(title: "Internet issue", subTitle: "No internet connection", error: true, warning: false, success: false)
        completion(false, "")
        }
    }
    
    func uploadMedia(data :Data?,mediaType:String,uid:String,completion: @escaping (_ url: String?) -> Void) {
        //let uid = UUID().uuidString
        print("image name with uid:- ",uid)
        let storageRef = Storage.storage().reference().child("\(uid).\(mediaType)")
        if let uploadData = data{
            //if let uploadData = imageData {
              let updateDat = storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                   
                if error != nil {
                        print("error")
                        completion(nil)
                    } else {
                        
                        storageRef.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print(error!.localizedDescription)
                                return
                            }
                            if let profileImageUrl = url?.absoluteString {
                                print(profileImageUrl)
                                completion(profileImageUrl)
                            }
                        })
                        // your uploaded photo url.
                    }
                 }
           // }
            
            updateDat.observe(.progress, handler: { (snap) in
               print("Our upload progress is: \(String(describing: snap.progress?.fractionCompleted))")
            })
        }
    }
    
    
    func getChatList(completion : @escaping completion){
        
        UtilityManager.firebaseRef.child("msgChatList").child(UtilityManager.userDataDecoded().userId).observe(.value) { (snapshot) in
            
            guard let mySnapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            print("chatListCount :-",mySnapshot.count)
            if mySnapshot.count != 0{
                
            var tempArr = [MsgChatList]()
                
            for snap in mySnapshot {
              if let userDictionary = snap.value as? [String: Any] {
                let obj = MsgChatList()
                obj.setData(dict: userDictionary)
                if !self.msgChatListArray.contains(where: {$0.lastMsgTime == obj.lastMsgTime}){
                    self.msgChatListArray.removeAll(where: {$0.chatUserId == obj.chatUserId})
                    tempArr.append(obj)
                    tempArr.sort { (obj1, obj2) -> Bool in
                        
                        return obj1.lastMsgTime > obj2.lastMsgTime
                    }
                    
                    self.msgChatListArray = tempArr
                }else{
                    self.msgChatListArray.filter({$0.lastMsgTime == obj.lastMsgTime}).first?.msgRead = obj.msgRead
                    self.msgChatListArray.filter({$0.lastMsgTime == obj.lastMsgTime}).first?.msgReadCount = obj.msgReadCount
                 }
               }
              }
            }else{
                self.msgChatListArray.removeAll()
            }
             // print(dictionary)
            completion(true)
            
        }
        
    }
    
    func createChatList(frndUserId:String,imgUrl:String,lastMsg:String,userName:String){
        let value = ["chatUserId":frndUserId,"imgUrl":imgUrl,"lastMsg":lastMsg,"userName":userName,"lastUpdate":"\(Date().timeIntervalSince1970)","msgRead":"false","msgReadCount":"1","lastMsgTime":"\(Date().timeIntervalSince1970)"]
        
        print(value)
        UtilityManager.firebaseRef.child("msgChatList").child(UtilityManager.userDataDecoded().userId).child(frndUserId).updateChildValues(value) { (error, dRef) in
            if error != nil{
                UtilityManager().showAlert(title: "Oops!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
            }
            
           // self.updateOtherStatus("false", frndUserId, lastMsg)
            self.updateOtherStatus("false", frndUserId, lastMsg, imgUrl, userName: userName)
        }
        /*
        UtilityManager.firebaseRef.child("msgChatList").child(UtilityManager.userDataDecoded().userId).child(frndUserId).setValue(value) { (error, dRef) in
            if error != nil{
                UtilityManager().showAlert(title: "Oops!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
            }
        }
        */
    }
    
    
    func updateMsgReadStatus(_ readStatus : String, _ frndUserId : String){
        
        let value = ["msgRead": readStatus,"lastUpdate":"\(Date().timeIntervalSince1970)","msgReadCount":"0"]
        
        UtilityManager.firebaseRef.child("msgChatList").child(UtilityManager.userDataDecoded().userId).child(frndUserId).updateChildValues(value) { (error, dRef) in
            if error != nil{
                UtilityManager().showAlert(title: "Oops!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
            }
        }
    }
    
    
    
    @objc func updateOtherStatus(_ readStatus : String , _ FrndUserId : String, _ lastMsg : String, _ imgUrl : String,userName:String){
        
        let value = ["chatUserId":UtilityManager.userDataDecoded().userId,"imgUrl":UtilityManager.userDataDecoded().imgUrl,"userName":UtilityManager.userDataDecoded().name,"msgRead": readStatus,"lastUpdate":"\(Date().timeIntervalSince1970)","lastMsg":lastMsg, "lastMsgTime":"\(Date().timeIntervalSince1970)"]
        
    UtilityManager.firebaseRef.child("msgChatList").child(FrndUserId).child(UtilityManager.userDataDecoded().userId).updateChildValues(value) { (error, dref) in
            print("update")
            
            print("error:-",error?.localizedDescription ?? "")
        
            if error != nil{
                UtilityManager().showAlert(title: "Oops!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
            }

        //Changes Start Here and Copy it
           OperationQueue.main.addOperation {
            self.getOtherUserMsgChat(FrndUserId: FrndUserId)
          }
       }
    }
    
    
    func getOtherUserMsgChat(FrndUserId : String){
        UtilityManager.firebaseRef.child("msgChatList").child(FrndUserId).child(UtilityManager.userDataDecoded().userId).observeSingleEvent(of: .value) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:String]{
                print(dictionary)
                guard var msgCount = Int(dictionary["msgReadCount"] ?? "0") else {return}
                print("oldMsgCount:-",msgCount)
                msgCount = msgCount + 1
                print("NewMsgCount:-",msgCount)
                self.updateMsgChatCount("\(msgCount)", FrndUserId)
            }
        }
    }
    
    
    func updateMsgChatCount( _ msgCount : String, _ frndUserId : String){
        
        let value = ["msgReadCount" : msgCount]
        
        UtilityManager.firebaseRef.child("msgChatList").child(frndUserId).child(UtilityManager.userDataDecoded().userId).updateChildValues(value) { (error, dRef) in
            if error != nil{
                UtilityManager().showAlert(title: "Oops!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
            }
        }
    }
    
    
    func deleteUserChat(frndUserId:String,completion : @escaping completion){
        
        let fromId = UtilityManager.userDataDecoded().userId
        let toId = frndUserId
        
        let chatRoomId = (fromId < toId) ? fromId + "_" + toId : toId + "_" + fromId
     
        UtilityManager.firebaseRef.child("messageUserList").child(chatRoomId).removeValue { (error, dRef) in
            if error != nil{
                UtilityManager().showAlert(title: "Oops!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
            }else{
                self.deleteChatUserList(frndUserId: frndUserId) { (success) in
                    
                }
            }
        }
    }
    
    func deleteChatUserList(frndUserId:String,completion : @escaping completion){
    
        UtilityManager.firebaseRef.child("msgChatList").child(UtilityManager.userDataDecoded().userId).child(frndUserId).removeValue { (error, dRef) in
            
           if error != nil{
                UtilityManager().showAlert(title: "Oops!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
            }
        }
      }
   }


extension MessageViewModel {
    
    func removeOtherUserUpdateObserver(FrndUserId:String){
        UtilityManager.firebaseRef.child("msgChatList").child(FrndUserId).child(UtilityManager.userDataDecoded().userId).removeAllObservers()
    }
    
    func removeUpdateUserObserver(frndUserId:String){
        UtilityManager.firebaseRef.child("msgChatList").child(UtilityManager.userDataDecoded().userId).child(frndUserId).removeAllObservers()
    }
    
    func removeIndividualMsg(frndChatId:String){
        let fromId = UtilityManager.userDataDecoded().userId
        let toId = frndChatId
        
        let chatRoomId = (fromId < toId) ? fromId + "_" + toId : toId + "_" + fromId
        
        UtilityManager.firebaseRef.child("messageUserList").child(chatRoomId).removeAllObservers()
    }
    
    
    func insertFakeImgData(frndChatId:String,msg:String,completion:@escaping (Bool,String)->()){
        sendMsg(frndChatId: frndChatId, msg: msg, imgUrl: "", msgType: "img", videoUrl: "", isUpdate: false, uImgid: "") { (success, imgUUID)  in
            completion(true,imgUUID)
        }
    }
    
    func getActiveUserList()->[UserModel]{
       return userOnlineListArray.filter({$0.isOnline == "true"})
    }
    
    func getMsgChatListCount()->Int{
        return msgChatListArray.count
    }
    
    func getMsgChatList(indexPath:IndexPath)->(userName:String,lastUpdate:String,lastMsg:String,userId:String,imgUrl:String){
        return (userName : msgChatListArray[indexPath.row].userName, lastUpdate : msgChatListArray[indexPath.row].lastUpdate, lastMsg : msgChatListArray[indexPath.row].lastMsg, userId : msgChatListArray[indexPath.row].chatUserId,imgUrl:msgChatListArray[indexPath.row].imgUrl)
    }
    
    func getMsgReadStatus(indexPath:IndexPath)->String{
        return msgChatListArray[indexPath.row].msgRead
    }
    
    func getMsgChatCount(indexPath:IndexPath)->String{
        return msgChatListArray[indexPath.row].msgReadCount
    }
    
}
