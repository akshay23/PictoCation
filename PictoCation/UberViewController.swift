//
//  UberViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 9/4/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import FlatUIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class UberViewController: UIViewController {
  
  var user: User?
  var coreDataStack: CoreDataStack!
  var place: (id: String, name: String, latitude: Double, longitude: Double)!
  var currentLocation: CLLocation!
  var uberTypes = Dictionary<String, String>()
  var requestId: String?
  var currentUberType: (id: String, name: String)!

  @IBOutlet var pickUpMap: GMSMapView!
  @IBOutlet var dropOffMap: GMSMapView!
  @IBOutlet var changeTypeBtn: FUIButton!
  @IBOutlet var uberTypeText: UILabel!
  @IBOutlet var typeView: UIView!
  @IBOutlet var requestBtn: FUIButton!
  @IBOutlet var messageLabel: UILabel!

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
    
    // Add refresh nav button
    let refreshButton = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "refresh")
    refreshButton.configureFlatButtonWithColor(UIColor.turquoiseColor(), highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
    refreshButton.tintColor = UIColor.cloudsColor()
    navigationItem.rightBarButtonItem = refreshButton
    
    // UI touch ups
    uberTypeText.layer.borderWidth = 1
    typeView.backgroundColor = UIColor.cloudsColor()
    typeView.layer.cornerRadius = 3
    changeTypeBtn.shadowHeight = 3.0
    changeTypeBtn.buttonColor = UIColor.turquoiseColor()
    changeTypeBtn.shadowColor = UIColor.greenSeaColor()
    changeTypeBtn.setTitle("Change Type", forState: .Normal)
    changeTypeBtn.addTarget(self, action: "changeType", forControlEvents: .TouchUpInside)
    changeTypeBtn.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    changeTypeBtn.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
    requestBtn.shadowHeight = 3.0
    requestBtn.buttonColor = UIColor.turquoiseColor()
    requestBtn.shadowColor = UIColor.greenSeaColor()
    requestBtn.setTitle("Request Uber", forState: .Normal)
    //requestBtn.addTarget(self, action: "changeType", forControlEvents: .TouchUpInside)
    requestBtn.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    requestBtn.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
    messageLabel.textColor = UIColor.cloudsColor()
    
    // Map init
    pickUpMap.delegate = self
    dropOffMap.delegate = self
    pickUpMap.setMinZoom(15, maxZoom: 15)
    dropOffMap.setMinZoom(15, maxZoom: 15)
    pickUpMap.myLocationEnabled = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let user = user {
      if (user.uberAccessToken == "") {
        performSegueWithIdentifier("login", sender: self)
      } else {
        print("Uber access token: \(user.uberAccessToken)")
        print("Current location: \(currentLocation)")
        print("Destination location: \(place.name)")
        refresh()
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
  
  func refresh() {
    self.uberTypes = Dictionary<String, String>()
    self.uberTypeText.text = "---"
    self.requestBtn.enabled = false
    self.changeTypeBtn.enabled = false
    checkReachabilityWithBlock {
      if let navi = self.navigationController {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(navi.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
      }

      // Pick-up Map
      var camera = GMSCameraPosition.cameraWithLatitude(self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude, zoom: 15)
      self.pickUpMap.animateToCameraPosition(camera)
      
      // Drop-off Map
      let location = CLLocationCoordinate2DMake(self.place.latitude, self.place.longitude)
      camera = GMSCameraPosition.cameraWithLatitude(location.latitude, longitude: location.longitude, zoom: 15)
      self.dropOffMap.animateToCameraPosition(camera)
      let marker = GMSMarker(position: location)
      marker?.title = self.place.name
      marker?.map = self.dropOffMap
      self.dropOffMap.selectedMarker = marker
      
      // Populate Uber types
      self.getUberTypes()
      
      // Make sure user doesn't have any pending requests
      self.checkForActiveRequests()
    }
  }
  
  func goBack() {
    view.resignFirstResponder()
    navigationController?.popViewControllerAnimated(true)
  }
  
  func changeType() {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
      (action) in
      // Do Nothing
    }
    actionSheet.addAction(cancelAction)
    
    for type in uberTypes {
      let typeButton = UIAlertAction(title: type.1, style: UIAlertActionStyle.Default) {
        (action) in
        
        if let navi = self.navigationController {
          let loadingNotification = MBProgressHUD.showHUDAddedTo(navi.view, animated: true)
          loadingNotification.mode = MBProgressHUDMode.Indeterminate
        }
        
        print("Current Uber type is \(type.1) with id \(type.0)")
        self.uberTypeText.text = type.1
        self.currentUberType = (type.0, type.1)
        self.requestBtn.enabled = true

        // Get estimates
        let endLocation = CLLocation(latitude: self.place.latitude, longitude: self.place.longitude)
        let params = [
          "product_id": self.currentUberType.id,
          "start_latitude": self.currentLocation.coordinate.latitude,
          "start_longitude": self.currentLocation.coordinate.longitude,
          "end_latitude": endLocation.coordinate.latitude,
          "end_longitude": endLocation.coordinate.longitude
        ]
        let myRequest: URLRequestConvertible = Uber.Router.getEstimate(self.user!.uberAccessToken)
        Alamofire.request(.POST, myRequest.URLRequest, parameters: params as? [String : AnyObject], encoding: .JSON).responseJSON {
          (request, _, result) in

          if (result.isSuccess) {
            let json = JSON(result.value!)
            if let pickup = json["pickup_estimate"].int {
              self.messageLabel.text = "Closest driver is about \(pickup) minutes away"
            } else {
              self.messageLabel.text = "There are no drivers nearby"
              self.requestBtn.enabled = false
            }
          } else {
            self.messageLabel.text = "Could not get trip estimate!"
          }
          
          if let navi = self.navigationController {
            MBProgressHUD.hideAllHUDsForView(navi.view, animated: true)
          }
        }
      }
      actionSheet.addAction(typeButton)
    }
    
    self.presentViewController(actionSheet, animated: true, completion: nil)
  }
  
  func getUberTypes() {
    let urlString: URLRequestConvertible = Uber.Router.getUberTypes(user!.uberAccessToken, currentLocation)
    Alamofire.request(urlString).responseJSON() {
      (_ , _, result) in
      
      if (result.isSuccess) {
        let json = JSON(result.value!)
        if let products = json["products"].array {
          print("Number of Uber types is \(products.count)")
          for type in products {
            self.uberTypes[type["product_id"].stringValue] = type["display_name"].stringValue
          }
        }
        
        if (self.uberTypes.count > 0) {
          self.changeTypeBtn.enabled = true
          self.messageLabel.text = "Please choose an Uber type"
        } else {
          self.changeTypeBtn.enabled = false
          self.messageLabel.text = "No Ubers in current location"
        }
      } else {
        self.showAlertWithMessage("Click 'Refresh' to try again", title: "Couldn't Get Uber Types", button: "OK")
      }
      
      if let navi = self.navigationController {
        MBProgressHUD.hideAllHUDsForView(navi.view, animated: true)
      }
    }
  }
  
  func checkForActiveRequests() {
    if (user!.uberMostRecentRequestID != "") {
      //let urlString: URLRequestConvertible = Uber.Router.getUberTypes(user!.uberAccessToken, currentLocation)
    }
  }
}

extension UberViewController: GMSMapViewDelegate {
}

extension UberViewController: UIActionSheetDelegate {
}