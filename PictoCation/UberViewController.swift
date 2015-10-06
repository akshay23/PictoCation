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
import Hokusai

class UberViewController: UIViewController {
  
  var user: User!
  var coreDataStack: CoreDataStack!
  var place: (id: String, name: String, latitude: Double, longitude: Double)!
  var currentLocation: CLLocation!
  var uberTypes = Dictionary<String, String>()
  var requestId: String?
  var currentUberType: (id: String, name: String)!
  var activeRequestExists: Bool = false

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
    requestBtn.addTarget(self, action: "requestUber", forControlEvents: .TouchUpInside)
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
    
    if (user.uberAccessToken == "" || (user.uberAccessToken != "" && (NSDate().isGreaterThanDate(user.uberAccessTokenExpiryDate) || NSDate().isEqualToDate(user.uberAccessTokenExpiryDate)))) {
      performSegueWithIdentifier("login", sender: self)
    } else {
      print("Uber access token is \(user.uberAccessToken)")
      print("Uber access token expires \(user.uberAccessTokenExpiryDate)")
      print("Current location is \(currentLocation)")
      print("Destination location is \(place.name)")
      refresh()
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
    }
  }
  
  func goBack() {
    view.resignFirstResponder()
    navigationController?.popViewControllerAnimated(true)
  }
  
  func requestUber() {
    if let navi = self.navigationController {
      let loadingNotification = MBProgressHUD.showHUDAddedTo(navi.view, animated: true)
      loadingNotification.mode = MBProgressHUDMode.Indeterminate
    }

    let endLocation = CLLocation(latitude: self.place.latitude, longitude: self.place.longitude)
    let params = [
      "product_id": self.currentUberType.id,
      "start_latitude": self.currentLocation.coordinate.latitude,
      "start_longitude": self.currentLocation.coordinate.longitude,
      "end_latitude": endLocation.coordinate.latitude,
      "end_longitude": endLocation.coordinate.longitude
    ]
    let myRequest: URLRequestConvertible = Uber.Router.requestSandboxRide(self.user.uberAccessToken)
    print(myRequest.URLRequest.URLString)
    Alamofire.request(.POST, myRequest.URLRequest, parameters: params as? [String : AnyObject], encoding: .JSON)
      .validate()
      .responseJSON {
      (_, _, result) in
      
        if (result.isSuccess) {
          let json = JSON(result.value!)
          if let status = json["status"].string {
            if (status == "processing" || status == "accepted") {
              if let fetchRequest = self.coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
                do {
                  let results = try self.coreDataStack.context.executeFetchRequest(fetchRequest) as! [User]
                  let user = results.first!
                  user.uberMostRecentRequestID = json["request_id"].stringValue
                  self.coreDataStack.saveContext()
                  self.user = user
                } catch {
                  self.showAlertWithMessage("Please try again!", title: "Couln't Fetch User", button: "Ok")
                  print("Couldn't fetch user")
                }
              }
              self.checkForActiveRequests()
            }
          }
        } else {
          self.showAlertWithMessage("Please try again after a few seconds.", title: "Couldn't Request an Uber", button: "OK")
        }
        
        if let navi = self.navigationController {
          MBProgressHUD.hideAllHUDsForView(navi.view, animated: true)
        }
    }
  }
  
  func changeType() {
    let hokusai = Hokusai()
    
    for type in uberTypes {
      hokusai.addButton(type.1) {
        if let navi = self.navigationController {
          let loadingNotification = MBProgressHUD.showHUDAddedTo(navi.view, animated: true)
          loadingNotification.mode = MBProgressHUDMode.Indeterminate
        }
        
        print("Current Uber type is \(type.1) with id \(type.0)")
        self.uberTypeText.text = type.1
        self.currentUberType = (type.0, type.1)
        
        if (!self.activeRequestExists) {
          self.requestBtn.enabled = true
        }
        
        // Get estimates
        let endLocation = CLLocation(latitude: self.place.latitude, longitude: self.place.longitude)
        let params = [
          "product_id": self.currentUberType.id,
          "start_latitude": self.currentLocation.coordinate.latitude,
          "start_longitude": self.currentLocation.coordinate.longitude,
          "end_latitude": endLocation.coordinate.latitude,
          "end_longitude": endLocation.coordinate.longitude
        ]
        let myRequest: URLRequestConvertible = Uber.Router.getEstimate(self.user.uberAccessToken)
        Alamofire.request(.POST, myRequest.URLRequest, parameters: params as? [String : AnyObject], encoding: .JSON)
          .validate()
          .responseJSON {
            (_, _, result) in
            
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
    }

    hokusai.colorScheme = HOKColorScheme.Asagi
    hokusai.show()
  }
  
  func getUberTypes() {
    let urlString: URLRequestConvertible = Uber.Router.getUberTypes(user.uberAccessToken, currentLocation)
    Alamofire.request(urlString)
      .validate()
      .responseJSON() {
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
        
        // Make sure user doesn't have any pending requests
        self.checkForActiveRequests()
    }
  }
  
  func checkForActiveRequests() {
    if (user.uberMostRecentRequestID != "") {
      print("Mose recent request_id is \(user!.uberMostRecentRequestID)")
      if let navi = self.navigationController {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(navi.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
      }

      let myRequest: URLRequestConvertible = Uber.Router.getSandboxRequestInfo(user.uberAccessToken, user.uberMostRecentRequestID)
      print(myRequest.URLRequest.URLString)
      Alamofire.request(myRequest)
        .validate()
        .responseJSON() {
        (_ , _, result) in
        
          if (result.isSuccess) {
            let json = JSON(result.value!)
            if let status = json["status"].string {
              if (status == "processing") {
                let eta = json["eta"].stringValue
                self.requestBtn.enabled = false
                self.changeTypeBtn.enabled = false
                self.activeRequestExists = true
                self.showAlertWithMessage("Uber request has been sent. Please wait for driver.", title: "Request Sent", button: "OK")
                self.messageLabel.text = "Driver will arrive in about \(eta) mins"
                
//                self.activeRequestExists = false
//                self.changeTypeBtn.enabled = true
//                if let fetchRequest = self.coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
//                  do {
//                    let results = try self.coreDataStack.context.executeFetchRequest(fetchRequest) as! [User]
//                    let user = results.first!
//                    user.uberMostRecentRequestID = ""
//                    self.coreDataStack.saveContext()
//                    self.user = user
//                  } catch {
//                    self.showAlertWithMessage("Please try again!", title: "Couln't Fetch User", button: "Ok")
//                    print("Couldn't fetch user")
//                  }
//                }
              } else if (status == "accepted" || status == "arriving") {
                let licensePlate = json["vehicle"]["license_plate"].stringValue
                self.requestBtn.enabled = false
                self.changeTypeBtn.enabled = false
                self.activeRequestExists = true
                self.showAlertWithMessage("You currently have an active request. Driver will arrive soon.", title: "Active Request", button: "OK")
                self.messageLabel.text = "Look for license plate \(licensePlate)"
              } else {
                self.activeRequestExists = false
                self.changeTypeBtn.enabled = true
                if let fetchRequest = self.coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
                  do {
                    let results = try self.coreDataStack.context.executeFetchRequest(fetchRequest) as! [User]
                    let user = results.first!
                    user.uberMostRecentRequestID = ""
                    self.coreDataStack.saveContext()
                    self.user = user
                  } catch {
                    self.showAlertWithMessage("Please try again!", title: "Couln't Fetch User", button: "Ok")
                    print("Couldn't fetch user")
                  }
                }
              }
            }
          }
          
          if let navi = self.navigationController {
            MBProgressHUD.hideAllHUDsForView(navi.view, animated: true)
          }
      }
    }
  }
}

extension UberViewController: GMSMapViewDelegate {}

extension UberViewController: UIActionSheetDelegate {}