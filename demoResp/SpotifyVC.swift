//
//  SpotifyVC.swift
//  demoResp
//
//  Created by Surinder kumar on 15/08/21.
//

import UIKit
import WebKit

class SpotifyVC: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var webVw: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let link = AuthManager.shared.signInUrl else {return}
        let request = URLRequest(url: link)
        webVw.navigationDelegate = self
        webVw.load(request)
    }
    

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else{
            return
        }
        
        //Exchange the code
        let component = URLComponents(string: url.absoluteString)
        guard  let code = component?.queryItems?.first(where: {$0.name == "code"})?.value else{return}
        print("here is your code:-",code)
        
        webVw.isHidden = true

        AuthManager.shared.exhangeCodeForToken(code ?? "") { [weak self](sucess) in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)

            }
        }
        
    }
   

}
    
