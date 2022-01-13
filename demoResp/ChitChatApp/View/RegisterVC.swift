//
//  RegisterVC.swift
//  Parentr
//
//  Created by Surinder on 08/06/19.
//  Copyright © 2019 Surinder. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

    @IBOutlet weak var tfPassword: TextFieldCustom!
    @IBOutlet weak var tfEmail: TextFieldCustom!
    @IBOutlet weak var tfFullName: TextFieldCustom!
    @IBOutlet weak var tfPhoneNumber: TextFieldCustom!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        UtilityManager().navigateWithPresentOutTransiton("LoginVC")
    }
    
    
    @IBAction func btnRegisterAction(_ sender: Any) {
        UserViewModel.shared.register(txtFullName: tfFullName, txtPhoneNumber: tfPhoneNumber, txtEmail: tfEmail, txtPassword: tfPassword) { (result) in
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
