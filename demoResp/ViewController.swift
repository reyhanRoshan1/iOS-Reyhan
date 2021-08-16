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
    
    var name : String = ""
    var roll : String = ""
    var header : String = ""
    var info : String = ""
    
    func setDict(dict:[String:String]){
        self.name = dict["name"] ?? ""
        self.roll = dict["roll"] ?? ""
        self.header = dict["header"] ?? ""
        self.info = dict["info"] ?? ""
    }
}

class ViewController: UIViewController {
    let signInConfig = GIDConfiguration.init(clientID: "1044813994944-uc3spkbil529egtmae3raifovr3pi11b.apps.googleusercontent.com")
    
    @IBOutlet weak var btnAction: UIButton!
    
    
    var arrayDict = [["name":"hh1","roll":"32","header":"txt","info":""],["name":"hh2","roll":"32","header":"string","info":"info"],["name":"hh3","roll":"32","header":"info","info":""],["name":"hh4","roll":"32","header":"txt","info":"info"],["name":"hh5","roll":"32","header":"info","info":""]]
    
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

