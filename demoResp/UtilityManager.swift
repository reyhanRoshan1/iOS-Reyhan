//
//  UtilityManager.swift
//  ChitChatApp
//
//  Created by Surinder on 20/08/19.
//  Copyright © 2019 Surinder. All rights reserved.
//
/*
import Foundation
import FirebaseDatabase
import SCLAlertView
import Kingfisher
import Alamofire
import Firebase
import NVActivityIndicatorView
//import FirebaseFirestore

enum NetworkError: Error {
    case badURLs
}

//pod 'NVActivityIndicatorView' , '~> 4.7.0'
typealias completion = (Bool)->()

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

class Indicator : UIViewController,NVActivityIndicatorViewable{
   static var shared = Indicator()
    let size = CGSize(width:50, height: 50)
    func start(_ msg : String){
        startAnimating(size, message: msg, messageFont: UIFont.systemFont(ofSize: 18), type: NVActivityIndicatorType.ballScaleRippleMultiple, color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor().backgroundColor(), textColor: .white)
    }
    
    func stop(){
        stopAnimating()
    }
    
}

class UtilityManager: NSObject {
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    let topController = UIApplication.topViewController()
    
    static var firebaseRef = Database.database().reference()
    
    //static var fireStoreRef = Firestore.firestore()
    
    static var userId : String{
        set{
            UserDefaults.standard.set(newValue, forKey: "userId")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        }
    }
    
    static var application = UIApplication.shared.delegate as! AppDelegate
    
    func getRefreshToken()->String{
        var refreshedToken : String = ""
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                refreshedToken = result.token
            }
        }
        return refreshedToken
    }
    
    func presentController(_ Controller:String){
        let vc = storyBoard.instantiateViewController(withIdentifier: Controller)
        topController?.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func navigateWithFadeTransiton(_ controller:String){
        let vc = storyBoard.instantiateViewController(withIdentifier: controller)
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        topController?.navigationController?.view.layer.add(transition, forKey: kCATransition)
        topController?.navigationController?.pushViewController(vc, animated: false)
    }
    
    func navigateWithRevealTransiton(_ controller:String){
        let vc = storyBoard.instantiateViewController(withIdentifier: controller)
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        topController?.navigationController?.view.layer.add(transition, forKey: kCATransition)
        topController?.navigationController?.pushViewController(vc, animated: false)
    }
    
    func navigateWithMoveInTransiton(_ controller:String){
        let vc = storyBoard.instantiateViewController(withIdentifier: controller)
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = .fromRight
        topController?.navigationController?.view.layer.add(transition, forKey: kCATransition)
        topController?.navigationController?.pushViewController(vc, animated: false)
    }
    
    func navigateWithPresentInTransiton(_ controller:String){
        let vc = storyBoard.instantiateViewController(withIdentifier: controller)
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = .fromTop
        topController?.navigationController?.view.layer.add(transition, forKey: kCATransition)
        topController?.navigationController?.pushViewController(vc, animated: false)
    }
    
    func navigateWithPresentOutTransiton(_ controller:String){
        let vc = storyBoard.instantiateViewController(withIdentifier: controller)
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = .fromBottom
        topController?.navigationController?.view.layer.add(transition, forKey: kCATransition)
        topController?.navigationController?.pushViewController(vc, animated: false)
    }
    
    func showAlert(title:String,subTitle:String,error:Bool?=nil,warning:Bool?=nil,success:Bool?=nil){
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("OK") {
            
        }
        
        if error ?? false{
            alert.showError(title, subTitle: subTitle)
        }else if warning ?? false{
            alert.showWarning(title, subTitle: subTitle)
        }else if success ?? false{
            alert.showSuccess(title, subTitle: subTitle)
        }else{
            alert.showError(title, subTitle: subTitle)
        }
        
    }
    
    
    func showAlertwithCompletion(title:String,subTitle:String,error:Bool?=nil,warning:Bool?=nil,success:Bool?=nil,completion:@escaping(String)->()){
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("OK") {
            completion("OK")
        }
        
        if error ?? false{
            alert.showError(title, subTitle: subTitle)
        }else if warning ?? false{
            alert.showWarning(title, subTitle: subTitle)
        }else if success ?? false{
            alert.showSuccess(title, subTitle: subTitle)
            
        }else{
            alert.showError(title, subTitle: subTitle)
        }
        
    }
    
    static func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    static func userDataDecoded()->UserModel{
        let decoder = JSONDecoder()
        var userDetailData = UserModel()
        if let userData = UserDefaults.standard.data(forKey: "UserModel"),
            let data = try? decoder.decode(UserModel.self, from: userData) {
            userDetailData = data
        }
        return userDetailData
    }
    
    static func userDataEncode(_ obj:UserModel){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(obj) {
            UserDefaults.standard.set(encoded, forKey: "UserModel")
        }
    }
    
    static func setImage(image:UIImageView,urlString:String){
        let url = URL(string: urlString)
        image.kf.indicatorType = .activity
        image.kf.setImage(
            with: url,
            placeholder: UIImage(named: "logo"))
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
}
*/
