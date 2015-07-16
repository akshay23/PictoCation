 //
//  MapViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/15/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import CoreData

class MapViewController: UIViewController {
  
  @IBOutlet var lblLoginMsg: UILabel!
  @IBOutlet var btnLogout: UIBarButtonItem!

  var coreDataStack: CoreDataStack!
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

    var error: NSError?
    if let fetchRequest = coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
      let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as! [User]
      user = results.first
    }

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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "login" && segue.destinationViewController.isKindOfClass(UINavigationController.classForCoder()) {
      let navigationController = segue.destinationViewController as! UINavigationController
      if let loginViewController = navigationController.topViewController as? LoginViewController {
        loginViewController.coreDataStack = coreDataStack
      }
      
      // Delete existing user data
      if self.user != nil {
        coreDataStack.context.deleteObject(user!)
        coreDataStack.saveContext()
      }

    }
  }
  
  @IBAction func unwindToMapView(segue : UIStoryboardSegue) {
  }
}
