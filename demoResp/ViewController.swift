//
//  ViewController.swift
//  demoResp
//
//  Created by Surinder kumar on 08/08/21.
//

import UIKit
import GoogleSignIn
import Popover

class student{
    
    var group : String = ""
    var roll : String = ""
    var header : String = ""
    var info : String = ""
    
    func setDict(dict:[String:String]){
        self.group = dict["group"] ?? ""
        self.header = dict["header"] ?? ""
    }
}

class ViewController: UIViewController {
    let signInConfig = GIDConfiguration.init(clientID: "1044813994944-uc3spkbil529egtmae3raifovr3pi11b.apps.googleusercontent.com")
    
    @IBOutlet weak var btnAction: UIButton!
    
    
    var arrayDict = [["group":"transportation","roll":"32","header":"txt1","info":""],["group":"other services","roll":"32","header":"string2","info":"info"],["group":"other services","roll":"32","header":"info3","info":""],["group":"other services","roll":"32","header":"txt4","info":"info"],["group":"transportation","roll":"32","header":"info5","info":""]]
    
    var str = "[<a href=https://www.w3schools.com>Visit W3Schools</a>]"
    
    var lastin = 0
    
    var newArray = [student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // perform(#selector(signInGoogle), with: nil, afterDelay: 2.0)
        print("AuthManager.shared.isSignedIn",AuthManager.shared.isSignedIn)
        print("AuthManager.shared.accessToke:- ",AuthManager.shared.accessToken)
        
        let get = str.components(separatedBy: "emails")
    
        
        let url = URL(string: "href=mailto:test@test.com")!
        if url.scheme == "mailto",
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            let email = components.path
            print(email)  // "test@test.com\n"
        }
          
        
        for value in str.components(separatedBy: ":"){
            
            if value != "emails"{
                
            }
            
        }
      /*
        if AuthManager.shared.isSignedIn{
            print("already login")
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpotifyVC") as! SpotifyVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        */
        //handleSignIn()
        checkDict()
    }
    
    func checkDict(){
        
        
        
        for value in arrayDict{
            let obj = student()
            obj.setDict(dict: value)
            self.newArray.append(obj)
        }
        
        
        if let array = newArray.filter({$0.group == "transportation"}) as? [student]{
            
            print(array.count)
            
        }
        
        if let arrayOther = newArray.filter({$0.group == "other services"}) as? [student]{
            for value in arrayOther{
                print(value.header)
            }
        }
        
        
        /*
        for value in arrayDict{
            let obj = student()
            obj.setDict(dict: value)
            self.newArray.append(obj)
        }
        
        for (index,value) in self.newArray.enumerated(){
            if value.header == "info"{
                if index != 0{
                    if (index - 1) <= 0{
                       self.newArray[index - 1].info = "info"
                    }else{
                        self.newArray[index - 1].info = "info"
                    }
                }
            }
        }
        
        for value in self.newArray{
            print("new value",value.info)
        }
        */
    }
    
    @objc func handleSignIn(){
        
         
        //after successfull push to home
        
        for i in 0..<arrayDict.count{
            print("index:-",i)
            print("count:-",arrayDict.count)
            if i < arrayDict.count{
                let j = i + 1
                print("j",j)
                if j != arrayDict.count{
                    print(arrayDict[i+1]["exist"])
                    if (i - 1) < 0{
                        print(i)
                        arrayDict[0]["exist"] = arrayDict[i+1]["exist"]
                        print(arrayDict)
                    }else{
                        print(i+1)
                        print(i-1)
                        lastin = i + 1
                        print("last index",lastin)
                        arrayDict[lastin-1]["exist"] = arrayDict[i+1]["exist"]
                        print(arrayDict)
                    }
                    
                }else{
                    
                    arrayDict[lastin-1]["exist"] = arrayDict[arrayDict.count-1]["exist"]
                }
            }
        }
        
        print(arrayDict)
    }

    @IBAction func btnAtion(_ sender: Any) {
        
        let width = 200
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 150))
        let options = [
          .type(.down),
          .cornerRadius(20),
          .animationIn(0.3),
          .arrowSize(CGSize(width: 20, height: 10))
          ] as [PopoverOption]
        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        popover.show(aView, fromView: self.btnAction)
    }
    
    @objc func signInGoogle(){
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            
            print(user?.profile?.name)

            // If sign in succeeded, display the app's main content View.
          }
    }
    
}

