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
    case requestOauthCode
    
    static func requestAccessTokenURLStringAndParms(code: String) -> (URLString: String, Params: [String: AnyObject]) {
      let params = ["client_id": Router.clientID, "client_secret": Router.clientSecret, "grant_type": "authorization_code", "redirect_uri": Router.redirectURI, "code": code]
      let pathString = "/oauth/access_token"
      let urlString = Instagram.Router.baseURLString + pathString
      return (urlString, params)
    }
    
    var URLRequest: NSURLRequest {
      let (path: String, parameters: [String: AnyObject]) = {
        switch self {
        case .TaggedPhotos (let userID, let accessToken):
          let params = ["access_token": accessToken]
          let pathString = "/v1/users/" + userID + "/media/recent"
          return (pathString, params)
          
        case .requestOauthCode:
          let pathString = "/oauth/authorize/?client_id=" + Router.clientID + "&redirect_uri=" + Router.redirectURI + "&response_type=code"
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

extension Alamofire.Request {
  
  public typealias Serializer = (NSURLRequest, NSHTTPURLResponse?, NSData?) -> (AnyObject?, NSError?)
  
  class func imageResponseSerializer() -> Serializer {
    return { request, response, data in
      if data == nil {
        return (nil, nil)
      }
      
      let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
      return (image, nil)
    }
  }
  
  func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
    return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
      completionHandler(request, response, image as? UIImage, error)
    })
  }
}