//
//  UberViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/18/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import SwiftyJSON
import CoreData
import FlatUIKit

class UberViewController: UIViewController {

  @IBOutlet var webView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    webView.delegate = self
    webView.hidden = true
    NSURLCache.sharedURLCache().removeAllCachedResponses()
    
    checkReachabilityWithBlock {
      // Show progress HUD
      let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      loadingNotification.mode = MBProgressHUDMode.Indeterminate
      loadingNotification.labelText = "Loading"
      
      // Delete all cookies (if any)
      if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as? [NSHTTPCookie]{
        for cookie in cookies {
          NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }
      }
      
      // Create new request
      let request = NSURLRequest(URL: Uber.Router.authorizationURL, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
      self.webView.loadRequest(request)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
  }
}

extension UberViewController: UIWebViewDelegate {
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    println(request.URLString)
    let urlString = request.URLString
    if let range = urlString.rangeOfString("?code=") {
      let location = range.endIndex
      let code = urlString.substringFromIndex(location)
      println(code)
      requestAccessToken(code)
      return false
    }
    return true
  }
  
  func requestAccessToken(code: String) {
    let request = Uber.Router.requestAccessTokenURLStringAndParms(code)
    
    Alamofire.request(.POST, request.URLString, parameters: request.Params)
      .responseJSON {
        (_, _, jsonObject, error) in
        
        if (error == nil) {
          let json = JSON(jsonObject!)
          
          if let accessToken = json["access_token"].string, userID = json["user"]["id"].string {
            println("Logged in")
//            let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: self.coreDataStack.context) as! User
//            user.userID = userID
//            user.accessToken = accessToken
//            user.placesType = "Establishment"
//            self.coreDataStack.saveContext()
//            self.performSegueWithIdentifier("unwindToMapView", sender: ["user": user])
          }
        }
        
    }
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    webView.hidden = false
    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
  }
}
