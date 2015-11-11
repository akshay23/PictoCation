//
//  Utils.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/8/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import FlatUIKit
import Alamofire

extension UIViewController {
  // Show an alert
  func showAlertWithMessage(message: String, title: String, button: String) {
    let alert = FUIAlertView()
    alert.title = title
    alert.message = message
    alert.delegate = nil
    alert.addButtonWithTitle(button)
    
    alert.titleLabel!.textColor = UIColor.cloudsColor()
    alert.titleLabel!.font = UIFont.boldFlatFontOfSize(16);
    alert.messageLabel!.textColor = UIColor.cloudsColor()
    alert.messageLabel!.font = UIFont.flatFontOfSize(12)
    alert.backgroundOverlay!.backgroundColor = UIColor.cloudsColor().colorWithAlphaComponent(0.8)
    alert.alertContainer!.backgroundColor = UIColor.midnightBlueColor()
    alert.defaultButtonColor = UIColor.cloudsColor()
    alert.defaultButtonShadowColor = UIColor.asbestosColor()
    alert.defaultButtonFont = UIFont.boldFlatFontOfSize(14)
    alert.defaultButtonTitleColor = UIColor.asbestosColor()
    
    alert.show()
  }
  
  // Execute block of code after checking Internet connection
  func checkReachabilityWithBlock(block: () -> ()) {
    if (!Reachability.isConnectedToNetwork()) {
      showAlertWithMessage("Please check your connection and try again", title: "No Internet Connection", button: "OK")
    } else {
      block()
    }
  }
}

extension Array {
  // Return index of element in array (if any)
  func find(includedElement: Element -> Bool) -> Int? {
    for (idx, element) in self.enumerate() {
      if includedElement(element) {
        return idx
      }
    }
    return nil
  }
  
  func lookup(index: Int) throws -> Element {
    if index >= count { throw
      NSError(domain: "com.actionman", code: 0,
        userInfo: [NSLocalizedFailureReasonErrorKey:
          "Array index out of bounds"])}
    return self[index]
  }
}

extension NSDate {
  func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
    var isGreater = false
    
    if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
      isGreater = true
    }
    
    return isGreater
  }
}
