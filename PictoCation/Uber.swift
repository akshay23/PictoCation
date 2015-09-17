//
//  Uber.swift
//  PictoCation
//
//  Created by Akshay Bharath on 9/4/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import Alamofire

struct Uber {
  enum Router: URLRequestConvertible {
    static let baseAuthURLString = "https://login.uber.com"
    static let baseURLString = "https://api.uber.com"
    static let clientID = "bks5_JosU049Lie_odAfZC12R_IDo8sd"
    static let clientSecret = "J-uS6vz0qdlQGgKgtR7s8ld_PJyTexoVhAAEZFfK"
    static let redirectURI = "https://www.pictocation.com/"
    static let authorizationURL = NSURL(string: Router.baseAuthURLString + "/oauth/authorize?response_type=code&scope=request&client_id=" + Router.clientID)!
    
    case requestOauthCode
    case requestRide(String)
    case getUberTypes(String)
    
    static func requestAccessTokenURLStringAndParms(code: String) -> (URLString: String, Params: [String: AnyObject]) {
      let params = ["client_id": Router.clientID, "client_secret": Router.clientSecret, "grant_type": "authorization_code", "redirect_uri": Router.redirectURI, "code": code]
      let pathString = "/oauth/token"
      let urlString = Uber.Router.baseAuthURLString + pathString
      return (urlString, params)
    }
    
    var URLRequest: NSURLRequest {
      let (baseURL: String, path: String, parameters: [String: AnyObject]) = {
        switch self {
        case .requestOauthCode:
          let pathString = "/oauth/authorize?response_type=code&scope=request&client_id=" + Router.clientID
          return (Uber.Router.baseAuthURLString, pathString, [:])
          
        case .requestRide(let accessToken):
          let params = ["access_token": accessToken]
          let pathString = "/v1/sandbox/requests"
          return (Uber.Router.baseURLString, pathString, params)
        
        case .getUberTypes(let accessToken):
          let params = ["access_token": accessToken]
          let pathString = "/v1/products"
          return (Uber.Router.baseURLString, pathString, params)
        }
        }()
      
      let BaseURL = NSURL(string: baseURL)
      var URLRequest = NSURLRequest(URL: BaseURL!.URLByAppendingPathComponent(path))
      let encoding = Alamofire.ParameterEncoding.URL
      return encoding.encode(URLRequest, parameters: parameters).0
    }
  }
}