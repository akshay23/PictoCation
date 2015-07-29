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

class PlacesManager {
  
  // Singleton
  class var sharedInstance: PlacesManager {
    struct Static {
      static let instance: PlacesManager = PlacesManager()
    }
    return Static.instance
  }

  private let apiKey: String = "AIzaSyDBVyaAIfNn1tcLuns6JMqGd5984ZPuomc"
  private var requestURL: String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
  private var latitude: Double!
  private var longitude: Double!
  private var radius: Int = 500
  
  // Read-only
  private(set) var places: [(name: String, latitude: Double, longitude: Double)] = []
  
  private init() {
  }
  
  func updateLatLong(latitude: Double, longitude: Double, handler: (error: NSError?) -> ()) {
    self.latitude = latitude
    self.longitude = longitude
    refreshPlaces(handler)
  }
  
  func refreshPlaces(handler: (error: NSError?) -> ()) {
    let location: String = "\(latitude),\(longitude)"
    let params = "location=\(location)&radius=\(radius)&key=\(apiKey)"
    let myRequest = requestURL + params
    self.places = []
    
    Alamofire.request(.GET, myRequest, parameters: nil).responseJSON {
      (_, _, data, error) in
      
      if (error == nil) {
        let json = JSON(data!)
        
        if let status = json["status"].string {
          if (status == "OK") {
            for place in json["results"].array! {
              let location = place["geometry"]["location"]
              if let lat = location["lat"].double, long = location["lng"].double {
                self.places.append(name: place["name"].string!, latitude: lat, longitude: long)
              }
            }
            println("Places count is \(self.places.count)")
          } else {
            println("Did not get OK status from results")
          }
        }
      } else {
        println(error!.localizedDescription)
      }
      
      handler(error: error)
    }
  }
}