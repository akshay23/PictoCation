//
//  MapViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/15/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
  
  @IBOutlet var lblLoginMsg: UILabel!
  
  var shouldLogin = true
  var user: User? {
    didSet {
      if user != nil {
        shouldLogin = false
      } else {
        shouldLogin = true
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if shouldLogin {
      performSegueWithIdentifier("login", sender: self)
      shouldLogin = false
    } else {
      self.lblLoginMsg.text = "Congratulations. Login was successful!"
    }
  }
  
  @IBAction func unwindToMapView(segue : UIStoryboardSegue) {
  }
}
