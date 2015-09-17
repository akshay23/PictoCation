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

class UberViewController: UIViewController {
  
  var user: User?
  var coreDataStack: CoreDataStack!
  var place: (id: String, name: String, latitude: Double, longitude: Double)!
  var currentLocation: CLLocation!
  var uberTypes:[String] = []
  var requestId:String?

  @IBOutlet var pickUpMap: GMSMapView!
  @IBOutlet var dropOffMap: GMSMapView!
  @IBOutlet var changeTypeBtn: FUIButton!
  @IBOutlet var uberTypeText: UILabel!
  @IBOutlet var typeView: UIView!

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
        println("Uber access token: \(user.uberAccessToken)")
        println("Current location: \(currentLocation)")
        println("Destination location: \(place.name)")
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
    checkReachabilityWithBlock {
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
  
  func changeType() {
    
  }
  
  func getUberTypes() {
    let urlString: URLRequestConvertible = Uber.Router.getUberTypes(user!.accessToken)
    println("Request is: \(urlString.URLRequest.URLString)")
    Alamofire.request(urlString).responseJSON() {
      (_ , _, jsonObject, error) in
      
      if (error == nil) {
        let json = JSON(jsonObject!)
        if let products = json["products"].array {
          println("Number of Uber types is \(products.count)")
        }
      } else {
        self.showAlertWithMessage("Click 'Refresh' to try again", title: "Couldn't Get Uber Types", button: "OK")
      }
    }
  }
}

extension UberViewController: GMSMapViewDelegate {
}