//
//  ViewController.swift
//  demoResp
//
//  Created by Surinder kumar on 08/08/21.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController {
    let signInConfig = GIDConfiguration.init(clientID: "1044813994944-uc3spkbil529egtmae3raifovr3pi11b.apps.googleusercontent.com")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // perform(#selector(signInGoogle), with: nil, afterDelay: 2.0)
        print("AuthManager.shared.isSignedIn",AuthManager.shared.isSignedIn)
        print("AuthManager.shared.accessToke:- ",AuthManager.shared.accessToken)
        if AuthManager.shared.isSignedIn{
            print("already login")
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpotifyVC") as! SpotifyVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    @objc func handleSignIn(){
        
         
        //after successfull push to home
        
    }


    @objc func signInGoogle(){
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            
            print(user?.profile?.name)

            // If sign in succeeded, display the app's main content View.
          }
    }
    
}

