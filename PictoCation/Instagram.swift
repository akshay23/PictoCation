//
//  Instagram.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/15/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import Alamofire

struct Instagram {
  enum Router: URLRequestConvertible {
    static let baseURLString = "https://api.instagram.com"
    static let clientID = "719ad856e8224503bef08a0fec2c2ad7"
    static let clientSecret = "ee30a6b26b6146a49d39c6d7cb09396c"
    static let redirectURI = "http://www.pictocation.com/"
    static let authorizationURL = NSURL(string: Router.baseURLString + "/oauth/authorize/?client_id=" + Router.clientID + "&redirect_uri=" + Router.redirectURI + "&response_type=code")!
    
    case TaggedPhotos(String, String)
    case PhotoComments(String, String)
    case LikePost(String, String)
    case requestOauthCode
    
    static func requestAccessTokenURLStringAndParms(code: String) -> (URLString: String, Params: [String: AnyObject]) {
      let params = ["client_id": Router.clientID, "client_secret": Router.clientSecret, "grant_type": "authorization_code", "redirect_uri": Router.redirectURI, "code": code]
      let pathString = "/oauth/access_token"
      let urlString = Instagram.Router.baseURLString + pathString
      return (urlString, params)
    }
    
    var URLRequest: NSMutableURLRequest {
      let (path, parameters): (String, [String: AnyObject]) = {
        switch self {
        case .TaggedPhotos (let topic, let accessToken):
          let params = ["access_token": accessToken]
          let pathString = "/v1/tags/" + topic + "/media/recent"
          return (pathString, params)
          
        case .PhotoComments(let instagramID, let accessToken):
          let params = ["access_token": accessToken]
          let pathString = "/v1/media/\(instagramID)"
          return (pathString, params)
          
        case .LikePost(let instagramID, let accessToken):
          let params = ["access_token": accessToken]
          let pathString = "/v1/media/\(instagramID)/likes"
          return (pathString, params)
          
        case .requestOauthCode:
          let pathString = "/oauth/authorize/?client_id=" + Router.clientID + "&redirect_uri=" + Router.redirectURI + "&response_type=code"
          return (pathString, [:])
        }
        }()
      
      let BaseURL = NSURL(string: Router.baseURLString)
      let URLRequest = NSURLRequest(URL: BaseURL!.URLByAppendingPathComponent(path))
      let encoding = Alamofire.ParameterEncoding.URL
      return encoding.encode(URLRequest, parameters: parameters).0
    }
  }
}
