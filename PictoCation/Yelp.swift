//
//  Yelp.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/21/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import Alamofire

struct Yelp {
  enum Router: URLRequestConvertible {
    static let baseURLString = "http://api.yelp.com"
    static let consumerKey = "9TeaSQnM6v0o_aiVTrxmOw"
    static let consumerSecret = "d0Dkb217FKE4Jw-j5fZnhgaaEzs"
    static let token = "3VVNQLAzOloYeKUVR8paY0f9ObmuXAqZ"
    static let tokenSecret = "Vt-fhy2RAbOo-d4OJnHbyg6dftI"
    static let signatureMethod = "HMAC-SHA1"
    static let dataEncoding = NSUTF8StringEncoding
    
    case Search(Dictionary<String, String>)
    
    var oauth_nonce: String {
      var s = NSMutableData(length: 32)
      SecRandomCopyBytes(kSecRandomDefault, s!.length, UnsafeMutablePointer<UInt8>(s!.mutableBytes))
      return s!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    var oauth_timestamp: String {
      return String(Int(NSDate().timeIntervalSince1970))
    }
    
    func getOauthSignature(searchParams: Dictionary<String, String>, nonce: String, timeStamp: String) -> String {
      let encodedConsumerSecret = Router.consumerSecret.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
      let encodedTokenSecret = Router.tokenSecret.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
      var params = ["oauth_consumer_key": Router.consumerKey, "oauth_token": Router.token, "oauth_signature_method": Router.signatureMethod,
        "oauth_nonce": nonce, "oauth_timestamp": timeStamp]
      params.append(&params, right: searchParams)
      let sortedParams = sorted(params) { $0.0 < $1.0 }
      var paramString: String = ""
      for (k,v) in sortedParams {
        var paramNameEncoded = k.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        var paramValueEncoded = v.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        var oneUrlPiece = paramNameEncoded! + "=" + paramValueEncoded!
        paramString = paramString + (paramString == "" ? "" : "&") + oneUrlPiece
      }
      let encodedParams = paramString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
      let encodedURL = (Router.baseURLString + "/v2/search?").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
      let signatureBaseString = "GET&\(encodedURL!)&\(encodedParams!)"
      let signingKey = "\(encodedConsumerSecret!)&\(encodedTokenSecret!)"
      return signatureBaseString.hmac(CryptoAlgorithm.SHA1, key: signingKey)
    }
    
    var URLRequest: NSURLRequest {
      let (path: String, parameters: [String: AnyObject]) = {
        switch self {
        case .Search (let searchParams):
          let nonce = self.oauth_nonce
          let stamp = self.oauth_timestamp
          var params: Dictionary<String, String> = ["oauth_consumer_key": Router.consumerKey, "oauth_token": Router.token, "oauth_signature_method": Router.signatureMethod,
            "oauth_nonce": nonce, "oauth_timestamp": stamp, "oauth_signature": self.getOauthSignature(searchParams, nonce: nonce, timeStamp: stamp)]
          params.append(&params, right: searchParams)
          let pathString = "/v2/search"
          return (pathString, params)
        }
        }()
      
      let BaseURL = NSURL(string: Router.baseURLString)
      var URLRequest = NSURLRequest(URL: BaseURL!.URLByAppendingPathComponent(path))
      let encoding = Alamofire.ParameterEncoding.URL
      return encoding.encode(URLRequest, parameters: parameters).0
    }
  }
}
