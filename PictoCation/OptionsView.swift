//
//  OptionsView.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/17/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import FlatUIKit

class OptionsView: UIView {
  
  var delegate: OptionsDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    delegate = nil
  }
  
  init(frame: CGRect, delegate: OptionsDelegate) {
    super.init(frame: frame)
    self.delegate = delegate
    setupView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    backgroundColor = UIColor.silverColor()
    layer.borderWidth = 2

    let instaButton = FUIButton(frame: CGRectMake(8, 5, frame.size.width - 15, 40))
    instaButton.shadowHeight = 3.0
    instaButton.buttonColor = UIColor.turquoiseColor()
    instaButton.shadowColor = UIColor.greenSeaColor()
    instaButton.setTitle("Instagram Photos", forState: .Normal)
    instaButton.titleLabel?.font = UIFont.boldFlatFontOfSize(20)
    instaButton.addTarget(self, action: "instagram", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(instaButton)
    
    let yelpButton = FUIButton(frame: CGRectMake(8, instaButton.frame.origin.y + 45, frame.size.width - 15, 40))
    yelpButton.shadowHeight = 3.0
    yelpButton.buttonColor = UIColor.turquoiseColor()
    yelpButton.shadowColor = UIColor.greenSeaColor()
    yelpButton.setTitle("Yelp Reviews", forState: .Normal)
    yelpButton.titleLabel?.font = UIFont.boldFlatFontOfSize(20)
    yelpButton.addTarget(self, action: "yelp", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(yelpButton)
    
    let reserveButton = FUIButton(frame: CGRectMake(8, yelpButton.frame.origin.y + 45, frame.size.width - 15, 40))
    reserveButton.shadowHeight = 3.0
    reserveButton.buttonColor = UIColor.turquoiseColor()
    reserveButton.shadowColor = UIColor.greenSeaColor()
    reserveButton.setTitle("Make Reservation", forState: .Normal)
    reserveButton.titleLabel?.font = UIFont.boldFlatFontOfSize(40)
    reserveButton.addTarget(self, action: "reserve", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(reserveButton)
    
    let uberButton = FUIButton(frame: CGRectMake(8, reserveButton.frame.origin.y + 45, frame.size.width - 15, 40))
    uberButton.shadowHeight = 3.0
    uberButton.buttonColor = UIColor.turquoiseColor()
    uberButton.shadowColor = UIColor.greenSeaColor()
    uberButton.setTitle("Book an Uber", forState: .Normal)
    uberButton.titleLabel?.font = UIFont.boldFlatFontOfSize(40)
    uberButton.addTarget(self, action: "uber", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(uberButton)
    
    let cancelButton = FUIButton(frame: CGRectMake(8, uberButton.frame.origin.y + 45, frame.size.width - 15, 40))
    cancelButton.shadowHeight = 3.0
    cancelButton.buttonColor = UIColor.turquoiseColor()
    cancelButton.shadowColor = UIColor.greenSeaColor()
    cancelButton.setTitle("Cancel", forState: .Normal)
    cancelButton.titleLabel?.font = UIFont.boldFlatFontOfSize(20)
    cancelButton.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(cancelButton)
  }
  
  func cancel() {
    if let delegate = delegate {
      delegate.cancel()
    }
  }
  
  func instagram() {
    if let delegate = delegate {
      delegate.instagram()
    }
  }
  
  func yelp() {
    if let delegate = delegate {
      delegate.yelp()
    }
  }
  
  func reserve() {
    if let delegate = delegate {
      delegate.reserve()
    }
  }
  
  func uber() {
    if let delegate = delegate {
      delegate.uber()
    }
  }
}
