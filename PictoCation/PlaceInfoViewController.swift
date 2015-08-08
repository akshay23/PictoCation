//
//  PlaceInfoViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/7/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import FlatUIKit
import GoogleMaps
import MBProgressHUD

class PlaceInfoViewController: UIViewController {
  
  var placesClient: GMSPlacesClient?
  var place: (id: String, name: String, latitude: Double, longitude: Double)!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // BG color
    view.backgroundColor = UIColor.wetAsphaltColor()
    
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
    
    // Google Places client
    placesClient = GMSPlacesClient()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Set title
    title = place.name
    
    // Refresh info
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
      self.populateInfo()
    }
  }
  
  // TODO
  func populateInfo() {
    // Show loading HUD
    if let navi = self.navigationController {
      let loadingNotification = MBProgressHUD.showHUDAddedTo(navi.view, animated: true)
      loadingNotification.mode = MBProgressHUDMode.Indeterminate
    }
    
    placesClient!.lookUpPlaceID(place.id, callback: {
      (gmsPlace: GMSPlace?, error: NSError?) -> Void in
      
      // Stop the loading HUD
      if let navi = self.navigationController {
        MBProgressHUD.hideAllHUDsForView(navi.view, animated: true)
      }
      
      if let gmsPlace = gmsPlace {
        self.showAlertWithMessage(gmsPlace.formattedAddress, title: "Address", button: "OK")
      }
    })
  }
}
