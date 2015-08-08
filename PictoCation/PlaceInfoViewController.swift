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
  
  @IBOutlet var imgMap: UIImageView!
  
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
  
  func getDataFromUrl(urL: NSURL, completion: ((data: NSData?) -> Void)) {
    NSURLSession.sharedSession().dataTaskWithURL(urL) {
      (data, response, error) in
      completion(data: data)
      }.resume()
  }
  
  func downloadAndSetMapImage(url: NSURL){
    println("Started downloading \(url)")
    getDataFromUrl(url) { data in
      dispatch_async(dispatch_get_main_queue()) {
        println("Finished downloading \(url)")
        self.imgMap.image = UIImage(data: data!)
      }
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
        // Get and set static map image
        let size = "&size=\(Int(self.imgMap.frame.width))x\(Int(self.imgMap.frame.height))"
        let marker = "&markers=\(gmsPlace.coordinate.latitude),\(gmsPlace.coordinate.longitude)"
        let url = "https://maps.googleapis.com/maps/api/staticmap?zoom=15\(size)\(marker)"
        self.downloadAndSetMapImage(NSURL(string: url)!)
        
        // TODO: Populate labels
        // self.showAlertWithMessage(gmsPlace.formattedAddress, title: "Address", button: "OK")
      }
    })
  }
}
