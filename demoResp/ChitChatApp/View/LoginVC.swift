//
//  ViewController.swift
//  Parentr
//
//  Created by Surinder on 08/06/19.
//  Copyright © 2019 Surinder. All rights reserved.
//

import UIKit
import AgoraRtcKit

class LoginVC: UIViewController {

    @IBOutlet weak var tfPassword: TextFieldCustom!
    @IBOutlet weak var tfEmail: TextFieldCustom!
    
    var objLoginVM = UserViewModel()
    
    var agoraKit: AgoraRtcEngineKit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnLoginAction(_ sender: Any) {
        
        if tfEmail.text?.isEmpty ?? false{
            
            initializeAgoraEngine()
            joinChannel()
            
        }else if tfPassword.text?.isEmpty ?? false{
            
        }else{
            objLoginVM.login(txtEmail: tfEmail, txtPassword: tfPassword) { (result) in
                switch result {
                case .success( _):
                    print("\("") unread messages.")
                    UtilityManager().navigateWithMoveInTransiton("MessagesVC")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func btnRegisterAction(_ sender: Any) {
        UtilityManager().navigateWithPresentInTransiton("RegisterVC")
    }
    
    func initializeAgoraEngine() {
        // Initializes the Agora engine with your app ID.
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "09a927dc928e497c8cc11919d79fa799", delegate: nil)
    }
    
    func joinChannel() {
        // Allows a user to join a channel.
        agoraKit.joinChannel(byToken: "00609a927dc928e497c8cc11919d79fa799IADFsphjX87SH1hF/1FGLB7PhHNJ7DkFrhZEP8uHwOYje2chkp4AAAAAEAAM2hL3CmD6YAEAAQAIYPpg", channelId: "demoChannelpopJerrying", info:nil, uid:0) {[unowned self] (sid, uid, elapsed) -> Void in
            // Joined channel "demoChannel"
            self.agoraKit.setEnableSpeakerphone(true)
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
}

