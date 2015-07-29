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

class MapViewController: UIViewController {

  @IBOutlet var mainMapView: GMSMapView!
  @IBOutlet var btnLogout: UIBarButtonItem!
  @IBOutlet var placesTable: UITableView!

  var locationManager: CLLocationManager!
  var coreDataStack: CoreDataStack!
  var user: User?
  var placesManager: PlacesManager!
  var currentLocation: CLLocation!
  var placeMarker: GMSMarker!

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
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if (user == nil) {
      performSegueWithIdentifier("login", sender: self)
      mainMapView.hidden = true
      btnLogout.enabled = false
    } else {
      println("Logged in")
      mainMapView.hidden = false
      mainMapView.setMinZoom(14, maxZoom: 14)
      btnLogout.enabled = true
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
}
 
extension MapViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    currentLocation = locations.first as! CLLocation
    let camera = GMSCameraPosition.cameraWithLatitude(currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 14)
    mainMapView.camera = camera
    mainMapView.myLocationEnabled = true
    mainMapView.settings.myLocationButton = true
    locationManager.stopUpdatingLocation()
    
    // Get places near current location
    placesManager.updateLatLong(currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude) {
      error in

      if (error == nil) {
        self.placesTable.reloadData()
      } else {
        // TODO
      }
    }
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {}
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
