//
//  LoginViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/15/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class LoginViewController: UIViewController {

  @IBOutlet var webView: UIWebView!
  
  var coreDataStack: CoreDataStack!

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    webView.delegate = self
    webView.hidden = true
    NSURLCache.sharedURLCache().removeAllCachedResponses()

    // Delete all cookies (if any)
    if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as? [NSHTTPCookie]{
      for cookie in cookies {
        NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
      }
    }
    
    // Create new request
    let request = NSURLRequest(URL: Instagram.Router.authorizationURL, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
    self.webView.loadRequest(request)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "unwindToMapView" && segue.destinationViewController.isKindOfClass(MapViewController.classForCoder()) {
      let mapViewController = segue.destinationViewController as! MapViewController
      if let user = sender?.valueForKey("user") as? User {
        mapViewController.user = user
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

extension LoginViewController: UIWebViewDelegate {
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    println(request.URLString)
    let urlString = request.URLString
    if let range = urlString.rangeOfString(Instagram.Router.redirectURI + "?code=") {
      let location = range.endIndex
      let code = urlString.substringFromIndex(location)
      println(code)
      requestAccessToken(code)
      return false
    }
    return true
  }
  
  func requestAccessToken(code: String) {
    let request = Instagram.Router.requestAccessTokenURLStringAndParms(code)
    
    Alamofire.request(.POST, request.URLString, parameters: request.Params)
      .responseJSON {
        (_, _, jsonObject, error) in
        
        if (error == nil) {
          let json = JSON(jsonObject!)
          
          if let accessToken = json["access_token"].string, userID = json["user"]["id"].string {
            println("Logged in")
            let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: self.coreDataStack.context) as! User
            user.userID = userID
            user.accessToken = accessToken
            self.coreDataStack.saveContext()
            self.performSegueWithIdentifier("unwindToMapView", sender: ["user": user])
          }
        }
        
    }
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    webView.hidden = false
  }
  
  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
  }
}
