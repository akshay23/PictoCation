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

  var locationManager: CLLocationManager!
  var mapView: GMSMapView!
  var placesClient: GMSPlacesClient!
  var coreDataStack: CoreDataStack!
  var user: User?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    var error: NSError?
    if let fetchRequest = coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
      let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as! [User]
      user = results.first
    }
    
    mapView = GMSMapView(frame: mainMapView.bounds)
    mapView.myLocationEnabled = true
    mapView.settings.myLocationButton = true
    mainMapView = mapView
    //self.view = mapView
    placesClient = GMSPlacesClient()
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if (user == nil) {
      performSegueWithIdentifier("login", sender: self)
      mainMapView.hidden = true
      btnLogout.enabled = false
    } else {
      println("Logged in!")
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
    let location = locations[0] as! CLLocation
    let camera = GMSCameraPosition.cameraWithLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 16)
    mapView.animateToCameraPosition(camera)
    println("Latitude: \(location.coordinate.latitude). Longitude: \(location.coordinate.longitude).")
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
  }
}
