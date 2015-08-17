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
import MBProgressHUD
import FlatUIKit

class LoginViewController: UIViewController {

  @IBOutlet var webView: UIWebView!
  @IBOutlet var closeButton: FUIButton!
  
  var coreDataStack: CoreDataStack!
  var progressHUD: MBProgressHUD!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    closeButton.shadowHeight = 4.0
    closeButton.buttonColor = UIColor.turquoiseColor()
    closeButton.shadowColor = UIColor.greenSeaColor()
    closeButton.setTitleColor(UIColor.cloudsColor(), forState: UIControlState.Normal)
    closeButton.setTitleColor(UIColor.cloudsColor(), forState: UIControlState.Highlighted)
    closeButton.setTitle("Close", forState: .Normal)
    closeButton.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
    closeButton.hidden = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    webView.delegate = self
    webView.hidden = true
    closeButton.hidden = false
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
      let request = NSURLRequest(URL: Instagram.Router.authorizationURL, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
      self.webView.loadRequest(request)
    }
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
  
  func close() {
    self.performSegueWithIdentifier("unwindToMapView", sender: nil)
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
            user.placesType = "Establishment"
            self.coreDataStack.saveContext()
            self.performSegueWithIdentifier("unwindToMapView", sender: ["user": user])
          }
        }
        
    }
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    webView.hidden = false
    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
  }
  
  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
  }
}
