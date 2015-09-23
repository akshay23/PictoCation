//
//  Utils.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/8/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import FlatUIKit

enum CryptoAlgorithm {
  case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
  
  var HMACAlgorithm: CCHmacAlgorithm {
    var result: Int = 0
    switch self {
    case .MD5:      result = kCCHmacAlgMD5
    case .SHA1:     result = kCCHmacAlgSHA1
    case .SHA224:   result = kCCHmacAlgSHA224
    case .SHA256:   result = kCCHmacAlgSHA256
    case .SHA384:   result = kCCHmacAlgSHA384
    case .SHA512:   result = kCCHmacAlgSHA512
    }
    return CCHmacAlgorithm(result)
  }
  
  var digestLength: Int {
    var result: Int32 = 0
    switch self {
    case .MD5:      result = CC_MD5_DIGEST_LENGTH
    case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
    case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
    case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
    case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
    case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
    }
    return Int(result)
  }
}

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
}

extension Dictionary {
  func append<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }
  
  func toURLString() -> String {
    var urlString = ""
    
    for (paramNameObject, paramValueObject) in self {
      let paramNameEncoded = (paramNameObject as! String).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLUserAllowedCharacterSet())
      let paramValueEncoded = (paramValueObject as! String).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLUserAllowedCharacterSet())
      let oneUrlPiece = paramNameEncoded! + "=" + paramValueEncoded!
      urlString = urlString + (urlString == "" ? "" : "&") + oneUrlPiece
    }
    
    return urlString
  }
}

extension String {
  func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
    let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
    let strLen = Int(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let digestLen = algorithm.digestLength
    let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
    let keyStr = key.cStringUsingEncoding(NSUTF8StringEncoding)
    let keyLen = Int(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    
    CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
    
    let digest = stringFromResult(result, length: digestLen)
    
    result.dealloc(digestLen)
    
    return digest
  }
  
  private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
    let hash = NSMutableString()
    for i in 0..<length {
      hash.appendFormat("%02x", result[i])
    }
    return String(hash)
  }
}
