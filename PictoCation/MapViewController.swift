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
 
@objc
protocol CenterViewControllerDelegate {
  optional func toggleLeftPanel(user: User!)
  optional func collapseSidePanel()
}

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
  var selectedPlace: (id: String, name: String, latitude: Double, longitude: Double)!
  var placeMarker: GMSMarker?
  var bgOverlay: UIView!
  var isUpdating: Bool = false
  var isFirstLogin: Bool = false
  var isLeftPanelOpen: Bool = false
  var selectedHastagTopic: String?
  var delegate: CenterViewControllerDelegate?
  var optionsView: OptionsView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize all the location stuff
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    mainMapView.delegate = self
    isFirstLogin = true
    
    // Get PlacesManager instance
    placesManager = PlacesManager.sharedInstance
    
    // Setup overlay
    bgOverlay = UIView(frame: self.view.bounds)
    bgOverlay.backgroundColor = UIColor.whiteColor()
    bgOverlay.alpha = 0.0
    
    // Setup options view
    let optionsWidth: CGFloat = (view.frame.size.width / 2) + 30
    let optionsHeight: CGFloat = 230
    let centerX = (view.frame.size.width / 2) - (optionsWidth / 2)
    let bottomOfFrame = view.frame.maxY - 10
    optionsView = OptionsView(frame: CGRectMake(centerX, bottomOfFrame, optionsWidth, optionsHeight), delegate: self)
    
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
    
    // Add change type button to left of navi
    let typeButton = UIBarButtonItem(title: "Change Type", style: .Plain, target: self, action: Selector("changeType"))
    typeButton.configureFlatButtonWithColor(UIColor.turquoiseColor(), highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
    typeButton.tintColor = UIColor.cloudsColor()
    navigationItem.leftBarButtonItem = typeButton
    
    // Hide any empty cells
    placesTable.tableFooterView = UIView(frame: CGRectZero)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    var error: NSError?
    if let fetchRequest = coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
      let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as! [User]
      user = results.first
    }
    
    // First time login
    if (isFirstLogin) {
      isUpdating = true
      locationManager.startUpdatingLocation()
      isFirstLogin = false
    }
    
    // Not logged in
    if (user == nil) {
      btnLogout.enabled = false
    } else {
      btnLogout.enabled = false
    }
    
    mainMapView.hidden = false
    placesTable.hidden = false
    isUpdating = false
    mainMapView.setMinZoom(14, maxZoom: 14)
    btnLogout.enabled = true
    btnRefresh.hidden = false
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
    } else if segue.identifier == "show gallery" && segue.destinationViewController.isKindOfClass(UICollectionViewController.classForCoder()) {
      if let galleryViewController = segue.destinationViewController as? GalleryViewController {
        galleryViewController.user = user
        let chars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        galleryViewController.hashtagTopic = stripOutUnwantedCharactersFromText(selectedHastagTopic!, characterSet: chars)
        galleryViewController.shouldRefresh = true
      }
    } else if segue.identifier == "show info" && segue.destinationViewController.isKindOfClass(UIViewController.classForCoder()) {
      if let infoViewController = segue.destinationViewController as? PlaceInfoViewController {
        infoViewController.place = selectedPlace
      }
    }
  }
  
  @IBAction func unwindToMapView(segue : UIStoryboardSegue) {}

  @IBAction func refreshPlaces(sender: AnyObject) {
    closeLeftPanelOpenIfOpen()
    doRefresh()
  }
  
  func doRefresh() {
    checkReachabilityWithBlock {
      self.btnRefresh.enabled = false
      self.locationManager.startUpdatingLocation()
    }
  }

  func stripOutUnwantedCharactersFromText(text: String, characterSet: Set<Character>) -> String {
    return String(filter(text) { characterSet.contains($0) })
  }
  
  func closeLeftPanelOpenIfOpen() {
    if (isLeftPanelOpen) {
      delegate?.toggleLeftPanel?(user)
      isLeftPanelOpen = false
    }
  }
  
  @objc func elipsesTapped(sender: UIButton, event: AnyObject) {
    let touches = event.allTouches()
    let firstTouch = touches?.first as? UITouch
    let currentTouchPosition = firstTouch?.locationInView(self.placesTable)
    let indexPath = self.placesTable.indexPathForRowAtPoint(currentTouchPosition!)
    
    if (indexPath != nil) {
      let place = placesManager.places[indexPath!.row].name
      selectedHastagTopic = place.stringByReplacingOccurrencesOfString(" ", withString: "")
      navigationController!.view.addSubview(bgOverlay)
      navigationController!.view.addSubview(optionsView)
      UIView.animateWithDuration(0.4) {
        self.bgOverlay.alpha = 0.9
        var optionsFrame = self.optionsView.frame
        optionsFrame.origin.y = (self.bgOverlay.frame.size.height / 2) - (optionsFrame.size.height / 2)
        self.optionsView!.frame = optionsFrame
      }
    }
  }
  
  @objc func changeType() {
    isLeftPanelOpen = !isLeftPanelOpen
    delegate?.toggleLeftPanel?(user)
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

    // Fade in the overlay and HUD
    navigationController!.view.addSubview(bgOverlay)
    UIView.animateWithDuration(0.5, animations: {
      self.bgOverlay.alpha = 0.8
      let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
      loadingNotification.mode = MBProgressHUDMode.Indeterminate
      loadingNotification.labelText = "Loading places..."
    })

    currentLocation = locations.first as! CLLocation
    let camera = GMSCameraPosition.cameraWithLatitude(currentLocation.coordinate.latitude,
      longitude: currentLocation.coordinate.longitude, zoom: 14)
    mainMapView.animateToCameraPosition(camera)
    mainMapView.myLocationEnabled = true
    mainMapView.settings.myLocationButton = true
    
    // Get places near current location
    placesManager.user = user
    placesManager.updateLatLong(currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude) {
      error in

      if (error == nil && self.placesManager.places.count != 0) {
        self.placesTable.reloadData()
        self.placesTable.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0),
          atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        self.placeMarker?.map = nil
      } else {
        self.showAlertWithMessage("Click 'Refresh Places' to try again", title: "Couldn't Get Any Places", button: "OK")
      }
      
      self.btnRefresh.enabled = true
      self.isUpdating = false
      
      // Stop the loading spinner (fade out)
      MBProgressHUD.hideAllHUDsForView(self.navigationController!.view, animated: true)
      self.bgOverlay.removeFromSuperview()
    }
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {}
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println("LocationManager failed with error: \(error.localizedDescription)!")
    self.showAlertWithMessage("Click 'Refresh Places' to try again", title: "Could Not Get Location", button: "OK")
  }
}

extension MapViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    placeMarker?.map = nil
    closeLeftPanelOpenIfOpen()
    
    let location = CLLocationCoordinate2DMake(placesManager.places[indexPath.row].latitude,
      placesManager.places[indexPath.row].longitude)
    placeMarker = GMSMarker(position: location)
    placeMarker?.title = placesManager.places[indexPath.row].name
    placeMarker?.map = mainMapView
    mainMapView.selectedMarker = placeMarker
    selectedPlace = placesManager.places[indexPath.row]
    
    var locationCam = GMSCameraUpdate.setTarget(location)
    mainMapView.animateWithCameraUpdate(locationCam)
  }
}
 
extension MapViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    
    // Configure the look
    cell.configureFlatCellWithColor(UIColor.wetAsphaltColor(), selectedColor: UIColor.cloudsColor())
    cell.textLabel!.font = UIFont.boldFlatFontOfSize(16)
    
    // Add custom accessory view
    let icon = UIImage(named: "InstagramIcon")
    let accBtn = UIButton(frame: CGRectMake(0.0, 0.0, icon!.size.width, icon!.size.width))
    accBtn.setBackgroundImage(icon, forState: .Normal)
    accBtn.addTarget(self, action: Selector("elipsesTapped:event:"), forControlEvents: UIControlEvents.TouchUpInside)
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
 
extension MapViewController: GMSMapViewDelegate {
  func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    closeLeftPanelOpenIfOpen()
  }
  
  func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
    closeLeftPanelOpenIfOpen()
  }
  
  func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
    closeLeftPanelOpenIfOpen()
    mainMapView.selectedMarker = marker
    return true
  }
  
  func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
    closeLeftPanelOpenIfOpen()
    performSegueWithIdentifier("show info", sender: self)
  }
}
 
extension MapViewController: LeftViewControllerDelegate {
  func typeSelected(type: String) {
    isLeftPanelOpen = false
    delegate?.collapseSidePanel?()

    // Save to CoreData
    // then refresh places
    var error: NSError?
    if let fetchRequest = coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
      let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as! [User]
      user = results.first
      user?.placesType = type
      coreDataStack.saveContext()
      doRefresh()
    }
  }
}
 
extension MapViewController: OptionsDelegate {
  func cancel() {
    UIView.animateWithDuration(0.2, animations: {
      var optionsFrame = self.optionsView.frame
      optionsFrame.origin.y = self.view.frame.maxY
      self.optionsView.frame = optionsFrame
      self.bgOverlay.alpha = 0.0
    }) {
        (value: Bool) in
        self.bgOverlay.removeFromSuperview()
        self.optionsView.removeFromSuperview()
    }
  }

  func instagram() {
    UIView.animateWithDuration(0.2, animations: {
      var optionsFrame = self.optionsView.frame
      optionsFrame.origin.y = self.view.frame.maxY
      self.optionsView.frame = optionsFrame
      self.bgOverlay.alpha = 0.0
      }) {
        (value: Bool) in
        self.bgOverlay.removeFromSuperview()
        self.optionsView.removeFromSuperview()
        
        if (self.user == nil) {
          self.performSegueWithIdentifier("login", sender: self)
        } else {
          self.performSegueWithIdentifier("show gallery", sender: self)
        }
    }
  }
  
  // TODO
  func yelp() {
    cancel()
  }
  
  // TODO
  func reserve() {
    cancel()
  }
  
  // TODO
  func uber() {
    UIView.animateWithDuration(0.2, animations: {
      var optionsFrame = self.optionsView.frame
      optionsFrame.origin.y = self.view.frame.maxY
      self.optionsView.frame = optionsFrame
      self.bgOverlay.alpha = 0.0
      }) {
        (value: Bool) in
        self.bgOverlay.removeFromSuperview()
        self.optionsView.removeFromSuperview()
        self.performSegueWithIdentifier("show uber", sender: self)
    }

  }
}
