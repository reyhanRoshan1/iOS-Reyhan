//
//  AuthManager.swift
//  demoResp
//
//  Created by Surinder kumar on 15/08/21.
//

import Foundation

final class AuthManager {
    
    
    static let shared = AuthManager()
    
    
    private init(){}
    
    
    struct constant {
        static let clientID = "2e0ef0e6ef2c4992afaf4bd16c0d3998"
        static let clientSecret = "c4a5ff410b2b42e9a41d9d1427ae06e4"
        static let tokenAPIUrl = "https://accounts.spotify.com/api/token"
    }
    
    
    public var signInUrl : URL?{
        let scrope = "user-read-private"
        let string = "https://accounts.spotify.com/authorize?response_type=code&client_id=\(constant.clientID)&scope=\(scrope)&redirect_uri=\("https://iosacademy.io")&show_dialog=TRUE"
        
        return URL(string: string)
        
    }
    
    public var completionHandler : ((Bool)->Void)?
    
    var isSignedIn : Bool{
        return accessToken != nil
    }
    
     var accessToken : String?{
        return UserDefaults.standard.value(forKey: "access_token") as? String ?? nil
    }
    
    private var refreshToken : String?{
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate : Date?{
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken : Bool{
        
        guard let expirationDate = tokenExpirationDate else{return false}
        
        let currentDate = Date()
        let fiveMinutes : TimeInterval = 300
        
        
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exhangeCodeForToken(_ code: String,completion:@escaping (Bool)->()){
        
        guard let url = URL(string: constant.tokenAPIUrl)else{return}
        
        
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: "https://iosacademy.io")
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let basicToken = constant.clientID+":"+constant.clientSecret
        let data = basicToken.data(using: .utf8)
        
        guard let base64String = data?.base64EncodedString() else{
            completion(false)
            return
        }
        print("king:- ",base64String)
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpBody = components.query?.data(using: .utf8)
        
        
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            
            guard let data = data, error == nil else{
            completion(false)
                return
            }
            
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                self.cacheToken(result: result)
                completion(true)
                
            }catch{
                print(error.localizedDescription)
                completion(false)
            }
            
        }
        
        task.resume()
    }
    
    
    public func refreshIfNeeded(completion: @escaping (Bool)->Void){
        
//        guard shouldRefreshToken else{
//            completion(true)
//            return
//        }
        
        guard let refreshToken = self.refreshToken else{
            print("failed")
            return
            
        }
        
        guard let url = URL(string: constant.tokenAPIUrl)else{return}
        
        
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let basicToken = constant.clientID+":"+constant.clientSecret
        let data = basicToken.data(using: .utf8)
        
        guard let base64String = data?.base64EncodedString() else{
            completion(false)
            return
        }
        print("king:- ",base64String)
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpBody = components.query?.data(using: .utf8)
        
        
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            
            guard let data = data, error == nil else{
                print("after api hit failed")
            completion(false)
                return
            }
            
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("resfreshed ")
                self.cacheToken(result: result)
                completion(true)
                
            }catch{
                print(error.localizedDescription)
                completion(false)
            }
            
        }
        
        task.resume()
        
        
    }
    
    private func cacheToken(result:AuthResponse){
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        
        if let refresh_token = result.refresh_token{
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
}
