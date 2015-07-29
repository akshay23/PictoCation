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
    refreshPlaces(handler)
  }
  
  func refreshPlaces(handler: (error: NSError?) -> ()) {
    let location: String = "\(latitude),\(longitude)"
    let params = "location=\(location)&radius=\(radius)&key=\(apiKey)"
    let myRequest = requestURL + params
    var nextPageToken: String?
    
    // First page of results
    Alamofire.request(.GET, myRequest, parameters: nil).responseJSON {
      (_, _, data, error) in
      
      if (error == nil) {
        let json = JSON(data!)
        if let status = json["status"].string {
          if (status == "OK") {
            self.firstSetofPlaces = []
            nextPageToken = json["next_page_token"].string
            for place in json["results"].array! {
              let location = place["geometry"]["location"]
              if let lat = location["lat"].double, long = location["lng"].double {
                self.firstSetofPlaces.append(name: place["name"].string!, latitude: lat, longitude: long)
              }
            }
            println("First places count is \(self.firstSetofPlaces.count)")
          } else {
            println("Got \(status) status from results")
          }
        }
      } else {
        println(error!.localizedDescription)
      }
      
      if nextPageToken == nil {
        self.places = self.firstSetofPlaces
        println("Full places count is \(self.places.count)")
        handler(error: error)
      } else {
        // Second page of results
        sleep(1)  // Bug with Alamofire
        let myRequest2 = self.requestURL + params + "&pagetoken=\(nextPageToken!)"
        Alamofire.request(.GET, myRequest2, parameters: nil).responseJSON {
          (request, response, data, error) in
          
          nextPageToken = nil
          
          if (error == nil) {
            let json = JSON(data!)
            if let status = json["status"].string {
              if (status == "OK") {
                self.secondSetofPlaces = []
                nextPageToken = json["next_page_token"].string
                for place in json["results"].array! {
                  let location = place["geometry"]["location"]
                  if let lat = location["lat"].double, long = location["lng"].double {
                    self.secondSetofPlaces.append(name: place["name"].string!, latitude: lat, longitude: long)
                  }
                }
                println("Second places count is \(self.secondSetofPlaces.count)")
              } else {
                println("Got \(status) status from results")
              }
            }
          } else {
            println(error!.localizedDescription)
          }
          
          if nextPageToken == nil {
            self.places = self.firstSetofPlaces + self.secondSetofPlaces
            println("Full places count is \(self.places.count)")
            handler(error: error)
          } else {
            // Third page of results
            sleep(2)  // Bug with Alamofire
            let myRequest2 = myRequest + "&pagetoken=\(nextPageToken!)"
            Alamofire.request(.GET, myRequest2, parameters: nil).responseJSON {
              (_, _, data, error) in
              
              if (error == nil) {
                let json = JSON(data!)
                if let status = json["status"].string {
                  if (status == "OK") {
                    self.thirdSetofPlaces = []
                    nextPageToken = json["next_page_token"].string
                    for place in json["results"].array! {
                      let location = place["geometry"]["location"]
                      if let lat = location["lat"].double, long = location["lng"].double {
                        self.thirdSetofPlaces.append(name: place["name"].string!, latitude: lat, longitude: long)
                      }
                    }
                    println("Third places count is \(self.secondSetofPlaces.count)")
                  } else {
                    println("Got \(status) status from results")
                  }
                }
              } else {
                println(error!.localizedDescription)
              }
              
              self.places = self.firstSetofPlaces + self.secondSetofPlaces + self.thirdSetofPlaces
              println("Full places count is \(self.places.count)")
              handler(error: error)
            }
          }
        }
      }
    }
  }
}
