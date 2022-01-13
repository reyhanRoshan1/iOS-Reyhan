//
//  MessagesVC.swift
//  Parentr
//
//  Created by Surinder on 11/06/19.
//  Copyright © 2019 Surinder. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {

    @IBOutlet weak var grpChatTblView: UITableView!
    @IBOutlet weak var msgChatTblView: UITableView!
    @IBOutlet weak var activeUserClcView: UICollectionView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var imgUserProfile: ImageCustom!
    @IBOutlet weak var scrollVw: UIScrollView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activeUserClcView.delegate = self
        activeUserClcView.dataSource = self
        
        delegateDatasource(tblView: msgChatTblView)
        delegateDatasource(tblView: grpChatTblView, clcView: activeUserClcView)
        scrollVw.isScrollEnabled = false
        
        
        UserViewModel.shared.getUser()
        
        /*
        let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: .hi)
        let englishGermanTranslator = NaturalLanguage.naturalLanguage().translator(options: options)
        
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        
        englishGermanTranslator.downloadModelIfNeeded(with: conditions) { error in
            print(error?.localizedDescription)
            guard error == nil else { return }
   
            // Model downloaded successfully. Okay to start translating.
            
            englishGermanTranslator.translate("How are you") { translatedText, error in
                
                guard error == nil, let translatedText = translatedText else { return }
                print("error here,",error?.localizedDescription)
                print("this is here you got something:- ",translatedText)
                // Translation succeeded.
            }
            
            
            
        }
        */
        
        
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
        MessageViewModel.shared.getFireStoreUserList { (success) in
            
        }
        */
        
        
        MessageViewModel.shared.getUserList { (success) in
            print(MessageViewModel.shared.userOnlineListArray.count)
            if success{
                self.activeUserClcView.reloadData()
                print(MessageViewModel.shared.getActiveUserList().count)
                MessageViewModel.shared.getChatList { (success) in
                    if success{
                        self.msgChatTblView.reloadData()
                    }
                }
            }
        }
        
 
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.x/2)
    }

    
    func delegateDatasource(tblView:UITableView,clcView:UICollectionView? = nil){
        tblView.delegate = self
        tblView.dataSource = self
        
        clcView?.delegate = self
        clcView?.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MessageViewModel.shared.getActiveUserList().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellActive", for: indexPath) as! ActiveUserCollectionViewCell
        
        UtilityManager.setImage(image: cell.imgFrndUser, urlString: MessageViewModel.shared.getActiveUserList()[indexPath.row].imgUrl)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.frndChatId = MessageViewModel.shared.getActiveUserList()[indexPath.row].userId
        vc.frndUserName = MessageViewModel.shared.getActiveUserList()[indexPath.row].name
        vc.frndImgUrl = MessageViewModel.shared.getActiveUserList()[indexPath.row].imgUrl
        MessageViewModel.shared.chatMsgArray.removeAll()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("hello msg count :- ",MessageViewModel.shared.getMsgChatListCount())
        return MessageViewModel.shared.getMsgChatListCount() 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == msgChatTblView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellChat", for: indexPath) as! MsgChatListTableViewCell
            
            UtilityManager.setImage(image: cell.imgUserFrnd, urlString: MessageViewModel.shared.getMsgChatList(indexPath: indexPath).imgUrl )
            
            print("last msg:- ",MessageViewModel.shared.msgChatListArray[indexPath.row].lastMsg)
            
            cell.lblUserFrndName.text = MessageViewModel.shared.getMsgChatList(indexPath: indexPath).userName
            
            if MessageViewModel.shared.getMsgReadStatus(indexPath: indexPath) == "false"{
                cell.lblLastMsg.font = UIFont(name:"SourceSansPro-Semibold", size:15)
                cell.lblLastMsg.textColor = UIColor.black
            }else{
                cell.lblLastMsg.font = UIFont(name:"SourceSansPro-Regular", size:15)
                cell.lblLastMsg.textColor = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1.0)
            }
            
            
            cell.lblLastMsg.text = MessageViewModel.shared.getMsgChatList(indexPath: indexPath).lastMsg
            cell.lblLastUpdate.text = MessageViewModel.shared.getMsgChatList(indexPath: indexPath).lastUpdate.getDateStringFromUTC()
            
            if MessageViewModel.shared.getMsgReadStatus(indexPath: indexPath) == "false"{
                cell.lblMsgCount.isHidden = false
                cell.lblMsgCount.text = MessageViewModel.shared.getMsgChatCount(indexPath: indexPath)
            }else{
                cell.lblMsgCount.isHidden = true
            }
            
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellGrp", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.frndChatId = MessageViewModel.shared.getMsgChatList(indexPath: indexPath).userId
        vc.frndUserName = MessageViewModel.shared.getMsgChatList(indexPath: indexPath).userName
        vc.frndImgUrl = MessageViewModel.shared.getMsgChatList(indexPath: indexPath).imgUrl
        
        //UserViewModel.shared.setUserStatus(childId: MessageViewModel.shared.getMsgChatList(indexPath: indexPath).userId)
        
        MessageViewModel.shared.chatMsgArray.removeAll()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    /*
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        print("triggered!")

        let more = UITableViewRowAction(style: .default, title: "More") { action, index in
            print("more button tapped")
        }
        more.backgroundColor = UIColor.blue

        return [more]
    }
    */
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            MessageViewModel.shared.deleteUserChat(frndUserId: MessageViewModel.shared.getMsgChatList(indexPath: indexPath).userId) { (success) in
                self.msgChatTblView.beginUpdates()
                self.msgChatTblView.deleteRows(at: [indexPath], with: .automatic)
                self.msgChatTblView.endUpdates()
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    

}
