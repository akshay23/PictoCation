//
//  Uber.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/18/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import Alamofire

struct Uber {
  enum Router: URLRequestConvertible {
    static let baseURLString = "https://api.uber.com"
    static let clientID = "bks5_JosU049Lie_odAfZC12R_IDo8sd"
    static let clientSecret = "J-uS6vz0qdlQGgKgtR7s8ld_PJyTexoVhAAEZFfK"
    static let redirectURI = "https://www.pictocation.com/"
    static let authorizationURL = NSURL(string: "https://login.uber.com/oauth/authorize?response_type=code&client_id=" + Router.clientID)!
    
    static func requestAccessTokenURLStringAndParms(code: String) -> (URLString: String, Params: [String: AnyObject]) {
      let params = ["client_id": Router.clientID, "client_secret": Router.clientSecret, "grant_type": "authorization_code", "code": code]
      let pathString = "https://login.uber.com/oauth/oauth/token"
      let urlString = pathString
      return (urlString, params)
    }
    
    case TaggedPhotos(String, String)
    case PhotoComments(String, String)
    case requestOauthCode
    
    var URLRequest: NSURLRequest {
      let (path: String, parameters: [String: AnyObject]) = {
        switch self {
        case .TaggedPhotos (let topic, let accessToken):
          let params = ["access_token": accessToken]
          let pathString = "/v1/tags/" + topic + "/media/recent"
          return (pathString, params)
          
        case .PhotoComments(let instagramID, let accessToken):
          let params = ["access_token": accessToken]
          let pathString = "/v1/media/\(instagramID)"
          return (pathString, params)
          
        case .requestOauthCode:
          let pathString = "https://login.uber.com/oauth/authorize/?response_type=code&client_id=" + Router.clientID
          return ("/photos", [:])
        }
        }()
      
      let BaeseURL = NSURL(string: Router.baseURLString)
      var URLRequest = NSURLRequest(URL: BaeseURL!.URLByAppendingPathComponent(path))
      let encoding = Alamofire.ParameterEncoding.URL
      return encoding.encode(URLRequest, parameters: parameters).0
    }
  }
}