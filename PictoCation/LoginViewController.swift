//
//  LoginViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/15/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  @IBOutlet var webView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    webView.hidden = true
    NSURLCache.sharedURLCache().removeAllCachedResponses()

    // Delete all cookies (if any)
    if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as? [NSHTTPCookie]{
      for cookie in cookies {
        NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
      }
    }
    
    // Create new request
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }


}

