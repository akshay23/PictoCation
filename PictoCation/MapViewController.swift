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
  
  @IBOutlet var lblLoginMsg: UILabel!
  @IBOutlet var btnLogout: UIBarButtonItem!

  var locationManager: CLLocationManager!
  var mapView: GMSMapView!
  var coreDataStack: CoreDataStack!
  var user: User?

  override func viewDidLoad() {
    super.viewDidLoad()
    mapView = GMSMapView(frame: CGRectZero)
    locationManager = CLLocationManager()
    locationManager.delegate = self
    self.view = mapView
    
    var error: NSError?
    if let fetchRequest = coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
      let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as! [User]
      user = results.first
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if user == nil {
      performSegueWithIdentifier("login", sender: self)
      mapView.hidden = true
    } else {
      println("Login was successful!")
      locationManager.requestWhenInUseAuthorization()
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
      mapView.hidden = false
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
    mapView.camera = camera
    mapView.myLocationEnabled = true
    mapView.userInteractionEnabled = false
    println("Latitude: \(location.coordinate.latitude). Longitude: \(location.coordinate.longitude).")
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
  }
}
