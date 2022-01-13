//
//  LoginViewModel.swift
//  Parentr
//
//  Created by Surinder on 08/06/19.
//  Copyright © 2019 Surinder. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class UserViewModel: NSObject {
    
    static var shared = UserViewModel()
    
    var userDetailDictionary = UserModel()
    
    /*
    func getFireStoreUserData(completion : @escaping completion){
        Indicator.shared.start("Please wait...");
        
        UtilityManager.fireStoreRef.collection("users").document(UtilityManager.userId).getDocument(source: .default) { (snapshot, error) in
            
            if let dict = snapshot?.data() as? [String:String]{
                    let obj = UserModel()
               obj.setData(dict: dict)
               UtilityManager.userDataEncode(obj)
            }
            
        }
    }
    */
    
    func getUserData(completion : @escaping ()->()){
       if Connectivity.isConnectedToInternet(){
        Indicator.shared.start("Please wait..."); UtilityManager.firebaseRef.child("users").child(UtilityManager.userId).observeSingleEvent(of: DataEventType.value) { (snapshot) in
        Indicator.shared.stop()
           if let dict = snapshot.value as? [String:String]{
                  let obj = UserModel()
             obj.setData(dict: dict)
             UtilityManager.userDataEncode(obj)
           }
         }
       }else{
        //utility.noInternetAlert()
        UtilityManager().showAlert(title: "Internet issue", subTitle: "No internet connection", error: true, warning: false, success: false)
        }
    }
    
    func login(txtEmail:UITextField,txtPassword:UITextField,completion:@escaping((Result<Bool,NetworkError>))->()){
        
        if Connectivity.isConnectedToInternet(){
            Indicator.shared.start("Signing in...")
            Auth.auth().signIn(withEmail: txtEmail.text ?? "", password: txtPassword.text ?? "") { (authResult, error) in
            Indicator.shared.stop()
                if error != nil{
                    UtilityManager().showAlert(title: "Error!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
                     completion(.success(false))
                }else{
                    Indicator.shared.start("Please wait...")
                    let values = ["token":authResult?.user.refreshToken ?? "","deviceToken":UtilityManager().getRefreshToken(),"isOnline":"true"]
                  
                    /*
                    UtilityManager.fireStoreRef.collection("users").document(authResult?.user.uid ?? "").updateData(values) { (error) in
                        
                        if error != nil{
                            UtilityManager().showAlert(title: "Error!", subTitle: error?.localizedDescription ?? "", error: true)
                            completion(.failure(.badURLs))
                        }else{
                            print("successfully saved")
                            UtilityManager.userId = authResult?.user.uid ?? ""
                            self.getUser()
                            completion(.success(true))
                        }
                        
                    }
                    */
                    
                    
                    UtilityManager.firebaseRef.child("users").child(authResult?.user.uid ?? "").updateChildValues(values, withCompletionBlock: { (error, dbRef) in
                        Indicator.shared.stop()
                        if error != nil{
                            UtilityManager().showAlert(title: "Error!", subTitle: error?.localizedDescription ?? "", error: true)
                            completion(.failure(.badURLs))
                        }else{
                            print("successfully saved")
                            UtilityManager.userId = authResult?.user.uid ?? ""
                            self.getUser()
                            completion(.success(true))
                        }
                    })
                    
                }
            }
        }else{
            //utility.noInternetAlert()
            UtilityManager().showAlert(title: "Internet issue", subTitle: "No internet connection", error: true, warning: false, success: false)
            completion(.failure(.badURLs))
        }
    }

    func register(txtFullName:UITextField,txtPhoneNumber:UITextField,txtEmail:UITextField,txtPassword:UITextField,completion:@escaping((Result<Bool,NetworkError>))->()){
        
        if txtFullName.text?.isEmpty ?? false{
            
        }else if txtPhoneNumber.text?.isEmpty ?? false{
            
        }else if txtEmail.text?.isEmpty ?? false{
            
        }else if !UtilityManager.isValidEmail(testStr: txtEmail.text ?? ""){
            
        }else{
            
            if Connectivity.isConnectedToInternet(){
                Indicator.shared.start("Creating account...")
            Auth.auth().createUser(withEmail: txtEmail.text ?? "", password: txtPassword.text ?? "") { (authResult, error) in
                Indicator.shared.stop()
                if error != nil{
                    UtilityManager().showAlert(title: "Error!", subTitle: error?.localizedDescription ?? "", error: true, warning: false, success: false)
                }else{
                    print("sucesss")
                    let values = ["token":authResult?.user.refreshToken ?? "","deviceToken":UtilityManager().getRefreshToken(),"name":txtFullName.text ?? "","imgUrl":"","email":authResult?.user.email ?? "","userId":authResult?.user.uid ?? "","lastScene":"","phoneNumber":txtPhoneNumber.text ?? "","latitude":"","longitude":"","isOnline":"true"]
                    Indicator.shared.start("Please wait...")
                    
                    /*
                    UtilityManager.fireStoreRef.collection("users").document(authResult?.user.uid ?? "").setData(values) { (error) in
                        
                        Indicator.shared.stop()
                        if error != nil{
                            UtilityManager().showAlert(title: "Error!", subTitle: error?.localizedDescription ?? "", error: true)
                            completion(.failure(.badURLs))
                        }else{
                            print("successfully saved")
                            UtilityManager.userId = authResult?.user.uid ?? ""
                            self.getUser()
                            completion(.success(true))
                        }
                        
                        
                    }
                    */
                    
                    
                    
                    UtilityManager.firebaseRef.child("users").child(authResult?.user.uid ?? "").setValue(values, withCompletionBlock: { (error, dbRef) in
                        Indicator.shared.stop()
                        if error != nil{
                            UtilityManager().showAlert(title: "Error!", subTitle: error?.localizedDescription ?? "", error: true)
                            completion(.failure(.badURLs))
                        }else{
                            print("successfully saved")
                            
                            UtilityManager.userId = authResult?.user.uid ?? ""
                            self.getUser()
                            completion(.success(true))
                        }
                    })
                   
                }
                
              }
            }else{
                UtilityManager().showAlert(title: "Internet issue", subTitle: "No internet connection", error: true, warning: false, success: false)
                completion(.failure(.badURLs))
            }
        }
    }
    
    func getUser(){
        Indicator.shared.start("Please wait...")
        self.getUserData(completion: {
            Indicator.shared.stop()
        })
        
        /*
        self.getFireStoreUserData { (success) in
            Indicator.shared.stop()
        }
 */
        
    }
    //->(lastScene:String,isOnline:String)
    func setUserStatus(childId:String,completion:@escaping(String,String)->()){
    
        UtilityManager.firebaseRef.child("users").child(childId).observe(.value) { (snapshot) in
            
            if let dict = snapshot.value as? [String:String]{
                let obj = UserModel()
                obj.setData(dict: dict)
                self.userDetailDictionary =  obj
                
            }
            completion(self.userDetailDictionary.isOnline,self.userDetailDictionary.lastScene)
        }
    }
    
    func getUserStatus()->(lastScene:String,isOnline:String){
        return (lastScene : self.userDetailDictionary.lastScene, isOnline : self.userDetailDictionary.isOnline)
    }
    
}
