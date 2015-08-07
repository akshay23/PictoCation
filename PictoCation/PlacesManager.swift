//
//  PlacesManager.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/17/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Darwin

class PlacesManager {
  
  // Singleton
  class var sharedInstance: PlacesManager {
    struct Static {
      static let instance: PlacesManager = PlacesManager()
    }
    return Static.instance
  }
  
  var user: User?

  private let apiKey: String = "AIzaSyDBVyaAIfNn1tcLuns6JMqGd5984ZPuomc"
  private var requestURL: String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
  private var latitude: Double!
  private var longitude: Double!
  private var radius: Int = 500
  
  // Temp arrays
  private var firstSetofPlaces: [(name: String, latitude: Double, longitude: Double)] = []
  private var secondSetofPlaces: [(name: String, latitude: Double, longitude: Double)] = []
  private var thirdSetofPlaces: [(name: String, latitude: Double, longitude: Double)] = []
  
  // Read-only
  private(set) var places: [(name: String, latitude: Double, longitude: Double)] = []
  
  private init() {}
  
  func updateLatLong(latitude: Double, longitude: Double, handler: (error: NSError?) -> ()) {
    self.latitude = latitude
    self.longitude = longitude
    refreshPlaces(true, nextPageToken: nil, handler: handler)
  }
  
  func refreshPlaces(isFirstRequest: Bool, nextPageToken: String?, handler: (error: NSError?) -> ()) {
    let location: String = "\(latitude),\(longitude)"
    let params = "location=\(location)&radius=\(radius)&key=\(apiKey)"
    var myRequest = requestURL + params
    
    if let user = user {
      if (user.placesType != nil && user.placesType != "ALL") {
        let formattedString = user.placesType!.stringByReplacingOccurrencesOfString(" ", withString: "_")
        myRequest = myRequest + "&types=\(formattedString.lowercaseString)"
      }
    }
    
    if let token = nextPageToken {
      myRequest = myRequest + "&pagetoken=\(token)"
    }
    
    if (isFirstRequest) {
      places = []
    }

    Alamofire.request(.GET, myRequest, parameters: nil).responseJSON {
      (_, _, data, error) in
      
      var token: String?
      if (error == nil) {
        let json = JSON(data!)
        if let status = json["status"].string {
          if (status == "OK") {
            token = json["next_page_token"].string
            for place in json["results"].array! {
              let location = place["geometry"]["location"]
              if let lat = location["lat"].double, long = location["lng"].double {
                self.places.append(name: place["name"].string!, latitude: lat, longitude: long)
              }
            }
          } else {
            println("Got \(status) status from results")
          }
        }
      } else {
        println(error!.localizedDescription)
      }
      
      if let tok = token {
        println("Getting more results")
        sleep(2)
        self.refreshPlaces(false, nextPageToken: tok, handler: handler)
      } else {
        println("Full places count is \(self.places.count)")
        self.places.sort({ $0.name < $1.name })
        handler(error: error)
      }
    }
  }
}
