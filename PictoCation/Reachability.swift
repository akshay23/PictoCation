//
//  Reachability.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/30/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//
// From: http://stackoverflow.com/questions/25398664/check-for-internet-connection-availability-in-swift
//

import Foundation
import SystemConfiguration

public class Reachability {
  
  class func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
      SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
      return false
    }
    
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    
    return isReachable && !needsConnection
  }
  
}
