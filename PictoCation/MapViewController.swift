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
  
  @IBAction func unwindToMapView(segue : UIStoryboardSegue) {
  }
}
 
extension MapViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    // Get current location and update map view
    let location = locations.first as! CLLocation
    let camera = GMSCameraPosition.cameraWithLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
    mainMapView.camera = camera
    mainMapView.myLocationEnabled = true
    mainMapView.settings.myLocationButton = true
    locationManager.stopUpdatingLocation()
    println("Latitude: \(location.coordinate.latitude). Longitude: \(location.coordinate.longitude).")
    
    // Get places near current location
    placesManager.updateLatLong(location.coordinate.latitude, longitude: location.coordinate.longitude) {
      error in

      if (error == nil) {
        self.placesTable.reloadData()
      } else {
        // TODO
      }
    }
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
  }
}
 
extension MapViewController: UITableViewDelegate {
  
}
 
extension MapViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    cell.textLabel!.text = placesManager.places[indexPath.row].name
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return placesManager.places.count
  }
}
