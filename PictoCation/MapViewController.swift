 //
//  MapViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/15/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import GoogleMaps
import MBProgressHUD
import FlatUIKit

class MapViewController: UIViewController {

  @IBOutlet var mainMapView: GMSMapView!
  @IBOutlet var btnLogout: UIBarButtonItem!
  @IBOutlet var placesTable: UITableView!
  @IBOutlet var btnRefresh: FUIButton!

  var locationManager: CLLocationManager!
  var coreDataStack: CoreDataStack!
  var user: User?
  var placesManager: PlacesManager!
  var currentLocation: CLLocation!
  var placeMarker: GMSMarker!
  var bgOverlay: UIView!
  var isUpdating: Bool = false

  override func viewDidLoad() {
    super.viewDidLoad()
    
    var error: NSError?
    if let fetchRequest = coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
      let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as! [User]
      user = results.first
    }

    // Initialize all the location stuff
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    
    // Get PlacesManager instance
    placesManager = PlacesManager.sharedInstance
    
    // Update the look of components
    btnRefresh.shadowHeight = 4.0
    btnRefresh.buttonColor = UIColor.turquoiseColor()
    btnRefresh.shadowColor = UIColor.greenSeaColor()
    btnRefresh.titleLabel?.font = UIFont.boldFlatFontOfSize(20)
    btnRefresh.setTitleColor(UIColor.cloudsColor(), forState: UIControlState.Normal)
    btnRefresh.setTitleColor(UIColor.cloudsColor(), forState: UIControlState.Highlighted)
    placesTable.backgroundColor = UIColor.wetAsphaltColor()
    btnLogout.configureFlatButtonWithColor(UIColor.turquoiseColor(), highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
    btnLogout.tintColor = UIColor.cloudsColor()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if (user == nil) {
      performSegueWithIdentifier("login", sender: self)
      locationManager.stopUpdatingLocation()
      mainMapView.hidden = true
      btnLogout.enabled = false
      btnRefresh.hidden = true
      placesTable.hidden = true
      isUpdating = true
    } else {
      println("Logged in")
      locationManager.startUpdatingLocation()
      mainMapView.hidden = false
      placesTable.hidden = false
      isUpdating = false
      mainMapView.setMinZoom(14, maxZoom: 14)
      btnLogout.enabled = true
      btnRefresh.hidden = false
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "login" && segue.destinationViewController.isKindOfClass(UINavigationController.classForCoder()) {
      let navigationController = segue.destinationViewController as! UINavigationController
      if let loginViewController = navigationController.topViewController as? LoginViewController {
        loginViewController.coreDataStack = coreDataStack
        locationManager.stopUpdatingLocation()
      }
      
      // Delete existing user data
      if user != nil {
        coreDataStack.context.deleteObject(user!)
        coreDataStack.saveContext()
      }

    }
  }
  
  @IBAction func unwindToMapView(segue : UIStoryboardSegue) {}

  @IBAction func refreshPlaces(sender: AnyObject) {
    if (!Reachability.isConnectedToNetwork()) {
      self.showAlertWithMessage("Please check your connection and try again", title: "No Internet Connection", buttons: ["OK"])
    } else {
      btnRefresh.enabled = false
      locationManager.startUpdatingLocation()
    }
  }
  
  private func showAlertWithMessage(message: String, title: String, buttons: [String]) {
    let alert = FUIAlertView()
    alert.title = title
    alert.message = message
    alert.delegate = nil
    
    for button in buttons {
      alert.addButtonWithTitle(button)
    }
    
    alert.titleLabel.textColor = UIColor.cloudsColor()
    alert.titleLabel.font = UIFont.boldFlatFontOfSize(16);
    alert.messageLabel.textColor = UIColor.cloudsColor()
    alert.messageLabel.font = UIFont.flatFontOfSize(12)
    alert.backgroundOverlay.backgroundColor = UIColor.cloudsColor().colorWithAlphaComponent(0.8)
    alert.alertContainer.backgroundColor = UIColor.midnightBlueColor()
    alert.defaultButtonColor = UIColor.cloudsColor()
    alert.defaultButtonShadowColor = UIColor.asbestosColor()
    alert.defaultButtonFont = UIFont.boldFlatFontOfSize(14)
    alert.defaultButtonTitleColor = UIColor.asbestosColor()
    alert.show()
  }
  
  @objc private func instaButtonTapped(sender: UIButton, event: AnyObject) {
    let touches = event.allTouches()
    let firstTouch = touches?.first as? UITouch
    let currentTouchPosition = firstTouch?.locationInView(self.placesTable)
    let indexPath = self.placesTable.indexPathForRowAtPoint(currentTouchPosition!)
    
    if (indexPath != nil) {
      // TODO
      println("Clicked button in row \(indexPath!.row)")
    }
  }
}
 
extension MapViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    locationManager.stopUpdatingLocation()
    
    if (!isUpdating) {
      isUpdating = true
    } else {
      return
    }
    
    // Show progress HUD in table view
    bgOverlay = UIView(frame: self.view.bounds)
    bgOverlay.backgroundColor = UIColor.whiteColor()
    bgOverlay.alpha = 0.7
    self.view.addSubview(bgOverlay)
    let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadingNotification.mode = MBProgressHUDMode.Indeterminate
    loadingNotification.labelText = "Loading places..."

    currentLocation = locations.first as! CLLocation
    let camera = GMSCameraPosition.cameraWithLatitude(currentLocation.coordinate.latitude,
      longitude: currentLocation.coordinate.longitude, zoom: 14)
    mainMapView.camera = camera
    mainMapView.myLocationEnabled = true
    mainMapView.settings.myLocationButton = true
    
    // Get places near current location
    placesManager.updateLatLong(currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude) {
      error in

      if (error == nil) {
        self.placesTable.reloadData()
      } else {
        self.showAlertWithMessage("Click 'Refresh Places' to try again", title: "Could Not Fetch Places", buttons: ["OK"])
      }
      
      // Stop the loading spinner
      MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
      self.btnRefresh.enabled = true
      self.isUpdating = false
      if (self.bgOverlay != nil) {
        self.bgOverlay.removeFromSuperview()
        self.bgOverlay = nil
      }
    }
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {}
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println("LocationManager failed with error: \(error.localizedDescription)!")
  }
}
 
extension MapViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if (placeMarker != nil) {
      placeMarker.map = nil
    }
    
    let location = CLLocationCoordinate2DMake(placesManager.places[indexPath.row].latitude,
      placesManager.places[indexPath.row].longitude)
    placeMarker = GMSMarker(position: location)
    placeMarker.title = placesManager.places[indexPath.row].name
    placeMarker.map = mainMapView
    mainMapView.selectedMarker = placeMarker
    
    var locationCam = GMSCameraUpdate.setTarget(location)
    mainMapView.animateWithCameraUpdate(locationCam)
  }
}
 
extension MapViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    
    // Configure the look
    cell.configureFlatCellWithColor(UIColor.wetAsphaltColor(), selectedColor: UIColor.cloudsColor())
    cell.separatorHeight = 2.0
    cell.textLabel!.font = UIFont.boldFlatFontOfSize(16)
    
    // Add custom accessory view
    let icon = UIImage(named: "InstagramIcon")
    let accBtn = UIButton(frame: CGRectMake(0.0, 0.0, icon!.size.width, icon!.size.width))
    accBtn.setBackgroundImage(icon, forState: .Normal)
    accBtn.addTarget(self, action: Selector("instaButtonTapped:event:"), forControlEvents: UIControlEvents.TouchUpInside)
    cell.accessoryView = accBtn
    
    // Add the info
    let location = CLLocation(latitude: placesManager.places[indexPath.row].latitude, longitude: placesManager.places[indexPath.row].longitude)
    let distance = round(100 * (currentLocation.distanceFromLocation(location) * 0.000621371))/100  // Meters to Miles, then round to 2 decimal places
    cell.textLabel!.text = placesManager.places[indexPath.row].name
    cell.detailTextLabel!.text = "\(distance) miles away"

    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return placesManager.places.count
  }
}
