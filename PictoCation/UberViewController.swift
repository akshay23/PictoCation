//
//  UberViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 9/4/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import CoreLocation

class UberViewController: UIViewController {
  
  var user: User?
  var coreDataStack: CoreDataStack!
  var place: (id: String, name: String, latitude: Double, longitude: Double)!
  var currentLocation: CLLocation!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // BG color & title image
    view.backgroundColor = UIColor.wetAsphaltColor()
    let uberIconView = UIImageView(image: UIImage(named: "UberIcon"))
    uberIconView.frame = CGRectMake(0, 0, 70, 20)
    navigationItem.titleView = uberIconView
    
    // Add back nav button
    let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "goBack")
    backButton.configureFlatButtonWithColor(UIColor.turquoiseColor(), highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
    backButton.tintColor = UIColor.cloudsColor()
    navigationItem.leftBarButtonItem = backButton
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let user = user {
      if (user.uberAccessToken == "") {
        performSegueWithIdentifier("login", sender: self)
      } else {
        println("Uber access token: \(user.uberAccessToken)")
        println("Current location: \(currentLocation)")
        println("Destination location: \(place.name)")
      }
    } else {
      // Should never get here!
      goBack()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "login" && segue.destinationViewController.isKindOfClass(UINavigationController.classForCoder()) {
      let navigationController = segue.destinationViewController as! UINavigationController
      if let loginViewController = navigationController.topViewController as? LoginViewController {
        loginViewController.loginType = .Uber
        loginViewController.coreDataStack = coreDataStack
      }
    }
  }
  
  @IBAction func unwindToUberView(segue : UIStoryboardSegue) {}
  
  func goBack() {
    view.resignFirstResponder()
    navigationController?.popViewControllerAnimated(true)
  }
}
