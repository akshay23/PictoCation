//
//  Yelp.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/21/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import Alamofire
import BDBOAuth1Manager

let yelpBaseURLString = "http://api.yelp.com/v2/"
let yelpConsumerKey = "9TeaSQnM6v0o_aiVTrxmOw"
let yelpConsumerSecret = "d0Dkb217FKE4Jw-j5fZnhgaaEzs"
let yelpToken = "3VVNQLAzOloYeKUVR8paY0f9ObmuXAqZ"
let yelpTokenSecret = "Vt-fhy2RAbOo-d4OJnHbyg6dftI"
let dataEncoding = NSUTF8StringEncoding

class Yelp: BDBOAuth1RequestOperationManager {
  var accessToken: String!
  var accessSecret: String!
  
  class var sharedInstance: Yelp {
    struct Static {
      static var token : dispatch_once_t = 0
      static var instance : Yelp? = nil
    }
    
    dispatch_once(&Static.token) {
      Static.instance = Yelp(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
    }
    return Static.instance!
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }
  
  init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
    self.accessToken = accessToken
    self.accessSecret = accessSecret
    let baseUrl = NSURL(string: yelpBaseURLString)
    super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
    
    let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
    self.requestSerializer.saveAccessToken(token)
  }
  
  func searchWithParams(parameters: [String: String], completion: ([NSDictionary]?, NSError?) -> Void) {
    self.GET("search", parameters: parameters, success: {
      (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let dictionaries = response["businesses"] as? [NSDictionary]
        if dictionaries != nil {
          completion(dictionaries, nil)
        }
      }, failure: {
        (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion(nil, error)
    })
  }
}
