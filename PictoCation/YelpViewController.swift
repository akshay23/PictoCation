//
//  YelpViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/27/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import FlatUIKit
import MBProgressHUD
import GoogleMaps
import MapKit

class YelpViewController: UIViewController {

  @IBOutlet var businessImage: UIImageView!
  @IBOutlet var businessName: UILabel!
  @IBOutlet var ratingsImage: UIImageView!
  @IBOutlet var reviewsCountLabel: UILabel!
  @IBOutlet var categoriesLabel: UILabel!
  @IBOutlet var hoursLabel: UILabel!
  @IBOutlet var addressView: UIView!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var mapView: GMSMapView!
  @IBOutlet var callButton: FUIButton!
  @IBOutlet var directionsButton: FUIButton!
  @IBOutlet var yelpButton: FUIButton!
  
  var businessPhoneNumber: String!
  var businessYelpPage: String!
  var place: (id: String, name: String, latitude: Double, longitude: Double)!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // BG color & title image
    view.backgroundColor = UIColor.wetAsphaltColor()
    let yelpIconView = UIImageView(image: UIImage(named: "YelpIcon"))
    yelpIconView.frame = CGRectMake(0, 0, 80, 35)
    navigationItem.titleView = yelpIconView
    
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
    
    // Map init
    mapView.delegate = self
    mapView.setMinZoom(15, maxZoom: 15)
    mapView.myLocationEnabled = true
    
    // Other UI stuff
    addressView.backgroundColor = UIColor.cloudsColor()
    addressView.layer.cornerRadius = 3
    callButton.shadowHeight = 3.0
    callButton.buttonColor = UIColor.turquoiseColor()
    callButton.shadowColor = UIColor.greenSeaColor()
    callButton.setTitle("Call Business", forState: .Normal)
    callButton.addTarget(self, action: "callBusiness", forControlEvents: .TouchUpInside)
    callButton.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    callButton.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
    
    directionsButton.shadowHeight = 3.0
    directionsButton.buttonColor = UIColor.turquoiseColor()
    directionsButton.shadowColor = UIColor.greenSeaColor()
    directionsButton.setTitle("Get Directions", forState: .Normal)
    directionsButton.addTarget(self, action: "getDirections", forControlEvents: .TouchUpInside)
    directionsButton.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    directionsButton.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
    
    yelpButton.shadowHeight = 3.0
    yelpButton.buttonColor = UIColor.turquoiseColor()
    yelpButton.shadowColor = UIColor.greenSeaColor()
    yelpButton.setTitle("View in Yelp", forState: .Normal)
    yelpButton.addTarget(self, action: "viewYelp", forControlEvents: .TouchUpInside)
    yelpButton.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    yelpButton.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    mapView.hidden = true
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
    // Loading
    if let navi = self.navigationController {
      let loadingNotification = MBProgressHUD.showHUDAddedTo(navi.view, animated: true)
      loadingNotification.mode = MBProgressHUDMode.Indeterminate
    }
    
    checkReachabilityWithBlock {
      let test = self.place
      var params = ["term": self.place.name, "ll": "\(self.place.latitude),\(self.place.longitude)"]
      Yelp.sharedInstance.searchWithParams(params, completion: {
        (businesses: [NSDictionary]?, error: NSError?) -> Void in
        
        // stop loading
        if let navi = self.navigationController {
          MBProgressHUD.hideAllHUDsForView(navi.view, animated: true)
        }
        
        if error == nil {
          if let dictionaries = businesses {
            let formattedPlace = self.place.name.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            for business in dictionaries {
              let name = business["name"] as! String
              println(name)
              let formattedBusiness = name.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
              if formattedBusiness.rangeOfString(formattedPlace) != nil {
                self.populateInfoForBusiness(business)
                return
              }
            }
            
            // If we get here, then there is no Yelp info for this place
            self.showAlertWithMessage("Please click 'Refresh' to try again or click 'Back' to pick another business", title: "Yelp Info Not Found", button: "OK")
          }
        } else {
          self.showAlertWithMessage("Click 'Refresh' to try again", title: "Couldn't Get Yelp Info", button: "OK")
        }
      })
    }
  }
  
  func callBusiness() {
    let url: NSURL = NSURL(string: "tel://\(businessPhoneNumber)")!
    UIApplication.sharedApplication().openURL(url);
  }
  
  func getDirections() {
    var coordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
    var options = [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ]
    var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
    var mapItem = MKMapItem(placemark: placemark)
    mapItem.name = place.name
    mapItem.openInMapsWithLaunchOptions(options)
  }
  
  func viewYelp() {
    let yelpURL: NSURL = NSURL(string: businessYelpPage)!
    UIApplication.sharedApplication().openURL(yelpURL);
  }
  
  // TODO
  func populateInfoForBusiness(business: NSDictionary) {
    // Image
    let imageURL = business["image_url"] as? String
    if let imageURL = imageURL {
      println("Yelp image url: \(imageURL)")
      let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
      dispatch_async(backgroundQueue) {
        let imageData = NSData(contentsOfURL: NSURL(string: imageURL)!)
        dispatch_async(dispatch_get_main_queue()) {
          if let imageData = imageData {
            self.businessImage.image = UIImage(data: imageData)
          }
        }
      }
    } else {
      println("No business image")
    }
    
    // Ratings Image
    let ratingsURL = business["rating_img_url"] as? String
    if let ratingsURL = ratingsURL {
      println("Yelp ratings image url: \(ratingsURL)")
      let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
      dispatch_async(backgroundQueue) {
        let imageData = NSData(contentsOfURL: NSURL(string: ratingsURL)!)
        dispatch_async(dispatch_get_main_queue()) {
          if let imageData = imageData {
            self.ratingsImage.image = UIImage(data: imageData)
          }
        }
      }
    } else {
      println("No ratings image")
    }
    
    // Basic info
    businessName.text = business["name"] as? String
    let reviewCount: Int = (business["review_count"] as? Int)!
    reviewsCountLabel.text = "\(reviewCount) Reviews"
    
    // Categories
    let categories = business["categories"] as! [AnyObject]
    var categoriesString = ""
    for category in categories {
      let cat = category as? [String]
      if (categoriesString == "") {
        categoriesString = cat![0]
      } else {
        categoriesString = categoriesString + ", \(cat![0])"
      }
    }
    categoriesLabel.text = categoriesString
    
    // Hours
    hoursLabel.text = "Hours Today: Unknown"
    
    // Address & telephone
    let locationInfo = business["location"] as! Dictionary<NSString, NSArray>
    let displayAddress: NSArray = locationInfo["display_address"]!
    var addressString = ""
    for locInfo in displayAddress {
      if addressString == "" {
        addressString = locInfo as! String
      } else {
        addressString = addressString + ", \(locInfo  as! String)"
      }
    }
    addressView.hidden = false
    addressLabel.text = addressString
    callButton.hidden = false
    directionsButton.hidden = false
    yelpButton.hidden = false
    
    // Check if phone number exists
    if let phone = business["phone"] as? String {
      callButton.enabled = true
      businessPhoneNumber = phone
    } else {
      callButton.enabled = false
    }
    
    // Map
    let location = CLLocationCoordinate2DMake(place.latitude, place.longitude)
    let camera = GMSCameraPosition.cameraWithLatitude(location.latitude, longitude: location.longitude, zoom: 15)
    mapView.animateToCameraPosition(camera)
    let marker = GMSMarker(position: location)
    marker?.map = mapView
    mapView.hidden = false
    
    // Yelp Page
    businessYelpPage = business["url"] as? String
  }
}

extension YelpViewController: GMSMapViewDelegate {
}
