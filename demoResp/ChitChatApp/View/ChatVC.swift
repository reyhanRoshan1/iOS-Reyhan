//
//  ChatVC.swift
//  Footsii
//
//  Created by webastral on 9/17/18.
//  Copyright © 2018 webastral. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import NRVideoCompression
import AVKit

class ChatVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var viewChatHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtChatHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewChatOption: UIView!
    @IBOutlet weak var viewChatBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtChatView: IQTextView!
    @IBOutlet weak var chatTblView: UITableView!
    @IBOutlet weak var imgUserFrnd: ImageCustom!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblLastSeen: UILabel!
    
    
    var ref : DatabaseReference! = nil
    
    var messageArr = [[String:String]]()
    var chatArray = [ChatModel]()
    
    var frndChatId : String = ""
    var isVideoUpload : Bool = false
    var videoUrl : String = ""
    var frndUserName : String = ""
    var frndImgUrl : String = ""
    
    var tempArr = [ChatModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        chatTblView.dataSource = self
        chatTblView.delegate = self
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        txtChatView.delegate = self
        
        chatTblView.estimatedRowHeight = 50
        chatTblView.rowHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
       /* let tapGestuer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        view.addGestureRecognizer(tapGestuer)
        tapGestuer.delegate = self*/
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        chatTblView.addGestureRecognizer(tapGestureRecognizer)
        
        ref = Database.database().reference()
       // self.sendMsg()
        self.fetchUserChat()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // viewChatOption.isHidden = true
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UtilityManager.setImage(image: imgUserFrnd, urlString: frndImgUrl)
        
        lblUserName.text = frndUserName
        
        /*
        print(UserViewModel.shared.getUserStatus().isOnline)
        if UserViewModel.shared.getUserStatus().isOnline == "false"{
            lblLastSeen.text =  UserViewModel.shared.getUserStatus().lastScene.getDateStringFromUTC()
        }else{
            lblLastSeen.text =  "Online"
        }
        */
        
        UserViewModel.shared.setUserStatus(childId: frndChatId) { (isOnline, timeStamp) in
            
            if isOnline == "false"{
                self.lblLastSeen.text =  timeStamp.getDateStringFromUTC()
            }else{
                self.lblLastSeen.text =  "Online"
            }
        }
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
       // viewChatHeightConstraint.constant = 53
        //txtChatView.frame.size.height = 33
       // textViewDidChange(txtChatView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isCameraOpen{
          MessageViewModel.shared.removeIndividualMsg(frndChatId: frndChatId)
          MessageViewModel.shared.removeUpdateUserObserver(frndUserId: frndChatId)
          MessageViewModel.shared.removeOtherUserUpdateObserver(FrndUserId: frndChatId)
        }
    }
    
    func fetchUserChat(){
        MessageViewModel.shared.getMessageIndividual(frndChatId: frndChatId) { (success) in
            if success{
                self.chatTblView.reloadData()
                self.scrollTbl()
                self.perform(#selector(self.updateStatus), with: nil, afterDelay: 2.0)
            }
        }
        
        /*
        ref.child("Chat").child("1,3").observe(DataEventType.childAdded) { (snapShot) in
            if let dictChat = snapShot.value as? [String:Any]{
               // self.messageArr.append(dictChat)
                let obj = ChatModel()
                obj.setData(dict: dictChat)
                self.chatArray.append(obj)
            }
            
            if self.chatArray.count != 0{
                self.chatTblView.reloadData()
                
               // self.chatTblView.insertRows(at: [IndexPath(item: self.chatArray.count-1, section: 0)], with:UITableView.RowAnimation.bottom)
                self.scrollTbl()
            }else{
                
            }
        }
        */
    }
    
    @objc func updateStatus(){
        if MessageViewModel.shared.chatMsgArray.count != 0{
            MessageViewModel.shared.updateMsgReadStatus("true", self.frndChatId)
          //  MessageViewModel.shared.updateOtherStatus("true", self.frndChatId, "poop")
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view is ChatTableViewCell) {
            return false
        }
        // UITableViewCellContentView => UITableViewCell
        if (touch.view?.superview is ChatTableViewCell) {
            return false
        }
        // UITableViewCellContentView => UITableViewCellScrollView => UITableViewCell
        if (touch.view?.superview?.superview is ChatTableViewCell) {
            return false
        }
        return true // handle the touch
    }
    
    @objc func hideKeyboard() {
        txtChatView.resignFirstResponder()
    }
    
    @objc  func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = true
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
          perform(#selector(scrollTbl), with: nil, afterDelay: 0.2)
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 2436:
                    viewChatBottomConstraint.constant =  +keyboardSize.height - 32
                    self.view.layoutIfNeeded()
                default:
                    viewChatBottomConstraint.constant =  +keyboardSize.height
                    self.view.layoutIfNeeded()
                }
            }else if UIDevice().userInterfaceIdiom == .pad {
                switch UIScreen.main.nativeBounds.height {
                case 2436:
                    viewChatBottomConstraint.constant =  +keyboardSize.height - 32
                    self.view.layoutIfNeeded()
                default:
                    viewChatBottomConstraint.constant =  +keyboardSize.height
                    
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
   @objc func scrollTbl(){
    if MessageViewModel.shared.chatMsgArray.count != 0{
      
       // self.chatTblView.scrollToRow(at: IndexPath(item: (MessageViewModel.shared.chatMsgArray.count )-1, section: 0), at: .top, animated: true)
        //self.scrollTbl()
        scrollToTop()
       }
    }
    
    
    func scrollToTop() {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: (MessageViewModel.shared.chatMsgArray.count) - 1, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.chatTblView.scrollToRow(at: indexPath, at: .top, animated: true)
           }
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.chatTblView.numberOfSections && indexPath.row < self.chatTblView.numberOfRows(inSection: indexPath.section)
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
            viewChatBottomConstraint.constant = 20
            self.view.layoutIfNeeded()
    }

    func textViewDidChange(_ textView: UITextView) {
        
        var frame : CGRect = textView.bounds
        frame.size.height = textView.contentSize.height
        if(frame.height >= 100.0){
            textView.isScrollEnabled = true
            viewChatHeightConstraint.constant = 100
        }
        else{
                textView.isScrollEnabled = false
                txtChatView.frame.size = frame.size
            if textView.text == "" {
                viewChatHeightConstraint.constant = 53
            }else if frame.size.height >= 53{
                viewChatHeightConstraint.constant = frame.size.height
            }else{
                viewChatHeightConstraint.constant = 53
            }
        }
        
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let chatText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return chatText.count < 250
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnRecieverAction(_ sender: Any) {
        let dict = ["msg":txtChatView.text!,"type":"receiver"]
        messageArr.append(dict)
        chatTblView.insertRows(at: [IndexPath(item: messageArr.count-1, section: 0)], with:UITableView.RowAnimation.bottom)
        chatTblView.scrollToRow(at: IndexPath(item: messageArr.count-1, section: 0), at: .top, animated: true)
    }
    
    @IBAction func btnChatOptionAction(_ sender: Any) {
      //  viewChatOption.isHidden = false
        ImagePickerManager().pickImage(self){ (image, url, mediaType)   in
            //here is the image
            if let imageData = image.jpeg(.lowest) {
                print(imageData.count)
             //   MessageViewModel.shared.uploadImagePic(data: imageData, frndChatId: self.frndChatId)
                if mediaType == "mov"{
                if let ur = url{
                  NRVideoCompressor.compressVideoWithQuality(presetName: "AVAssetExportPresetMediumQuality", inputURL: ur ) { (outputUrl) in
                       let compressSize = NSData(contentsOf: outputUrl)
                    
                       let sizeinMB = ByteCountFormatter.string(fromByteCount: Int64((compressSize?.length)!), countStyle: .file)
                       print("size of file",sizeinMB)
                    if compressSize?.count != 0{
                        if let videoData = compressSize{
                            //self.uploadData(data: videoData as Data, mediaType: "mov")
                            
                            MessageViewModel.shared.insertFakeImgData(frndChatId: self.frndChatId, msg: "video") { (success, imgUUID)  in
                                self.uploadData(data: videoData as Data, mediaType: "mov",uid: imgUUID) { (success) in
                                    self.isVideoUpload = true
                                    self.uploadData(data: imageData, mediaType: "png",isVideo:true, uid: imgUUID) { (success) in
                                        
                                    }
                                }
                            }
                        }
                     }
                  }
                }
             }else{
                    //self.uploadData(data: imageData, mediaType: "png", completion: (Bool) -> ())
                    MessageViewModel.shared.insertFakeImgData(frndChatId: self.frndChatId, msg: "image") { (success, imgUUID)  in
                        self.uploadData(data: imageData, mediaType: "png", uid : imgUUID) { (success) in
                        }
               }
            }
          }
        }
    }
    
    func uploadData(data:Data,mediaType:String,isVideo:Bool?=nil,uid:String,completion: @escaping (Bool)->()){
        MessageViewModel.shared.uploadMedia(data: data, mediaType: mediaType, uid: uid) { (imgUrl) in
            if mediaType == "png" && !(isVideo ?? false){
                self.sendMsg(msg: "image", imgUrl: imgUrl ?? "", msgType: "img", videoUrl: "", isUpdate: true, uImgid: uid)
                self.videoUrl = ""
            }else{
                
                if self.isVideoUpload{
                    self.sendMsg(msg: "video", imgUrl: imgUrl ?? "", msgType: "mov", videoUrl: self.videoUrl, isUpdate: true, uImgid: uid)
                    self.videoUrl = ""
                }else{
                    self.videoUrl = imgUrl ?? ""
                    print("video uploaded")
                    completion(true)
                }
            }
        }
    }
    
    
    @IBAction func btnSenderAction(_ sender: Any) {
        if !txtChatView.text.isEmpty {
            self.sendMsg(msg: (txtChatView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines), imgUrl: "", msgType: "txt", videoUrl: "", isUpdate: false, uImgid: "")
        }
    }
    
    
    func sendMsg(msg:String,imgUrl:String,msgType:String,videoUrl:String,isUpdate:Bool,uImgid:String){
        MessageViewModel.shared.sendMsg(frndChatId: frndChatId, msg: msg, imgUrl: imgUrl, msgType: msgType, videoUrl: videoUrl, isUpdate: isUpdate, uImgid: uImgid) { (success, imgUUID) in
            if success{
                self.txtChatView.text = ""
                if MessageViewModel.shared.chatMsgArray.count != 0{
                    MessageViewModel.shared.createChatList(frndUserId: self.frndChatId, imgUrl: self.frndImgUrl, lastMsg: MessageViewModel.shared.chatMsgArray.last?.msg ?? "", userName: self.frndUserName)
                }
            }
        }
    }
    
}

extension ChatVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("hello world",MessageViewModel.shared.chatMsgArray.count)
        return MessageViewModel.shared.chatMsgArray.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dict = MessageViewModel.shared.chatMsgArray[indexPath.row]

        if(dict.userSendId == UtilityManager.userDataDecoded().userId){
            if dict.msgType == "txt"{
              let cell = tableView.dequeueReusableCell(withIdentifier: "cellSend") as! ChatTableViewCell
                cell.lblSender.text = dict.msg
              return cell
            }else if dict.msgType == "img"{
              let cell = tableView.dequeueReusableCell(withIdentifier: "cellSenderImage") as! ChatTableViewCell
                
                UtilityManager.setImage(image: cell.imgSenderUpload, urlString: dict.imgUrl )
              return cell
            }else if dict.msgType == "mov"{
             // let cell = tableView.dequeueReusableCell(withIdentifier: "cellSenderMov") as! ChatTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSenderMov", for: indexPath) as! ChatTableViewCell
                
                    DispatchQueue.main.async {
                       // self.getImage(cell: cell, fileUrl: fileUrl)
                        UtilityManager.setImage(image: cell.imgSenderMov, urlString: dict.imgUrl )
                    }
                    
              return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSend") as! ChatTableViewCell
                cell.lblSender.text = dict.msg
                return cell
            }
        }
        
        if dict.msgType == "txt"{
           let cell = tableView.dequeueReusableCell(withIdentifier: "sendReciever") as! ChatTableViewCell
            cell.lblReciever.text = dict.msg
           return cell
        }else if dict.msgType == "img"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellRecieverImage") as! ChatTableViewCell
            UtilityManager.setImage(image: cell.imgRecieverUpload, urlString: dict.imgUrl )
            return cell
        }else if dict.msgType == "mov"{
          let cell = tableView.dequeueReusableCell(withIdentifier: "cellRecieverMov") as! ChatTableViewCell
             DispatchQueue.main.async {
                // self.getImage(cell: cell, fileUrl: fileUrl)
                UtilityManager.setImage(image: cell.imgRecieverMov, urlString: dict.imgUrl )
              }
          return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendReciever") as! ChatTableViewCell
            cell.lblReciever.text = dict.msg
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        txtChatView.resignFirstResponder()
        let dict = MessageViewModel.shared.chatMsgArray[indexPath.row]
        
        if dict.msgType == "mov" {
            let videoURL = URL(string: dict.videoUrl )
            if let vidUrl = videoURL{
            let player = AVPlayer(url: vidUrl)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
           }
          }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dict = MessageViewModel.shared.chatMsgArray[indexPath.row]
        
        if(dict.userSendId == UtilityManager.userDataDecoded().userId){
            if dict.msgType == "img" || dict.msgType == "mov" {
              return 180
            }else{
              return UITableView.automaticDimension
            }
        }else{
            if dict.msgType == "img" || dict.msgType == "mov" {
              return 180
            }else{
              return UITableView.automaticDimension
            }
        }
    }
    
}
