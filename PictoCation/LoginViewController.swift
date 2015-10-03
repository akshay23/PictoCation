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

enum LoginType {
  case Instagram, Uber
}

class LoginViewController: UIViewController {

  @IBOutlet var webView: UIWebView!
  @IBOutlet var closeButton: FUIButton!
  
  var coreDataStack: CoreDataStack!
  var progressHUD: MBProgressHUD!
  var loginType: LoginType!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    closeButton.shadowHeight = 3.0
    closeButton.buttonColor = UIColor.turquoiseColor()
    closeButton.shadowColor = UIColor.greenSeaColor()
    closeButton.setTitle("Close", forState: .Normal)
    closeButton.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
    closeButton.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    closeButton.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
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
      if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as [NSHTTPCookie]?{
        for cookie in cookies {
          NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }
      }
      
      // Create new request
      var request: NSURLRequest!
      if (self.loginType == .Instagram) {
        self.closeButton.hidden = true
        request = NSURLRequest(URL: Instagram.Router.authorizationURL, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
      } else if (self.loginType == .Uber) {
        self.closeButton.hidden = false
        request = NSURLRequest(URL: Uber.Router.authorizationURL, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
      }
      
      self.webView.loadRequest(request)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "unwindToMapView" && segue.destinationViewController.isKindOfClass(MapViewController.classForCoder()) {
      let mapViewController = segue.destinationViewController as! MapViewController
      if let user = sender?.valueForKey("user") as? User {
        mapViewController.user = user
        mapViewController.isFirstLogin = true
      }
    } else if segue.identifier == "unwindToUberView" && segue.destinationViewController.isKindOfClass(MapViewController.classForCoder()) {
      let uberViewController = segue.destinationViewController as! UberViewController
      if let user = sender?.valueForKey("user") as? User {
        uberViewController.user = user
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
    print(request.URLString)
    let urlString = request.URLString
    var redirectURI: String!
    if (loginType == .Instagram) {
      redirectURI = Instagram.Router.redirectURI
    } else if(loginType == .Uber) {
      redirectURI = Uber.Router.redirectURI
    }
    
    if let range = urlString.rangeOfString(redirectURI + "?code=") {
      let location = range.endIndex
      let code = urlString.substringFromIndex(location)
      print(code)
      requestAccessToken(code)
      return true
    }
    return true
  }
  
  func requestAccessToken(code: String) {
    var request: (URLString: String, Params: [String: AnyObject])!
    if (loginType == .Instagram) {
      request = Instagram.Router.requestAccessTokenURLStringAndParms(code)
    } else if (loginType == .Uber) {
      request = Uber.Router.requestAccessTokenURLStringAndParms(code)
    }
    
    Alamofire.request(.POST, request.URLString, parameters: request.Params)
      .validate()
      .responseJSON {
        (_, _, result) in
        
        if (result.isSuccess) {
          let json = JSON(result.value!)
          
          if (self.loginType == .Instagram) {
            if let accessToken = json["access_token"].string, userID = json["user"]["id"].string {
              print("Logged into Instagram")
              let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: self.coreDataStack.context) as! User
              user.userID = userID
              user.accessToken = accessToken
              user.placesType = "Establishment"
              user.uberAccessToken = ""
              self.coreDataStack.saveContext()
              self.performSegueWithIdentifier("unwindToMapView", sender: ["user": user])
            }
          } else if (self.loginType == .Uber) {
            if let accessToken = json["access_token"].string {
              print("Logged into Uber")
              if let fetchRequest = self.coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
                do {
                  let results = try self.coreDataStack.context.executeFetchRequest(fetchRequest) as! [User]
                  let user = results.first!
                  user.uberAccessToken = accessToken
                  user.uberAccessTokenExpiryDate = NSDate().dateByAddingTimeInterval((60 * 60 * 24) * 30)
                  user.uberMostRecentRequestID = ""
                  self.coreDataStack.saveContext()
                  self.performSegueWithIdentifier("unwindToUberView", sender: ["user": user])
                } catch {
                  self.showAlertWithMessage("Please try again!", title: "Couln't Fetch User", button: "Ok")
                  print("Couldn't fetch user")
                  self.close()
                }
              }
            }
          }
        }
        
    }
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    webView.hidden = false
    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
  }
}
