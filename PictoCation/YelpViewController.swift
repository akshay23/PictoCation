//
//  YelpViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/27/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import FlatUIKit
import MBProgressHUD

class YelpViewController: UIViewController {

  @IBOutlet var businessImage: UIImageView!
  
  var place: (id: String, name: String, latitude: Double, longitude: Double)!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // BG color & title
    view.backgroundColor = UIColor.wetAsphaltColor()
    title = "Yelp Info & Reviews"
    
    // Add back nav button
    let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "goBack")
    backButton.configureFlatButtonWithColor(UIColor.turquoiseColor(), highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
    backButton.tintColor = UIColor.cloudsColor()
    navigationItem.leftBarButtonItem = backButton
    
    // Add refresh nav button
    let refreshButton = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "refresh")
    refreshButton.configureFlatButtonWithColor(UIColor.turquoiseColor(), highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
    refreshButton.tintColor = UIColor.cloudsColor()
    navigationItem.rightBarButtonItem = refreshButton
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    refresh()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func goBack() {
    navigationController?.popViewControllerAnimated(true)
  }
  
  func refresh() {
    checkReachabilityWithBlock {
      let test = self.place
      var params = ["term": self.place.name, "ll": "\(self.place.latitude),\(self.place.longitude)"]
      Yelp.sharedInstance.searchWithParams(params, completion: {
        (businesses: [NSDictionary]?, error: NSError?) -> Void in
        if error == nil {
          if let dictionaries = businesses {
            let formattedPlace = self.place.name.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            for business in dictionaries {
              let name = business["name"] as! String
              let formattedBusiness = name.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
              if formattedBusiness.rangeOfString(formattedPlace) != nil {
                self.populateInfoForBusiness(business)
                return
              }
            }
            
            // If we get here, then there is no Yelp info for this place
            self.showAlertWithMessage("Please click 'Refresh' to try again or click 'Back' to pick another business", title: "Yelp Info Not Found", button: "OK")
          }
        }
      })
    }
  }
  
  // TODO
  func populateInfoForBusiness(business: NSDictionary) {
    // Image
    let imageURL = business["image_url"] as? String
    if let imageURL = imageURL {
      println("Yelp image url: \(imageURL)")
      let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
      dispatch_async(backgroundQueue) {
        let imageData = NSData(contentsOfURL: NSURL(string: imageURL)!)
        dispatch_async(dispatch_get_main_queue()) {
          if let imageData = imageData {
            self.businessImage.image = UIImage(data: imageData)
          }
        }
      }
    } else {
      println("No business image")
    }
    
    // Basic info
    
    // Reviews
  }
}
