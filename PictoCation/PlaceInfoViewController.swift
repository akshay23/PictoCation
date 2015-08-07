//
//  PlaceInfoViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/7/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import FlatUIKit
import Alamofire
import SwiftyJSON

class PlaceInfoViewController: UIViewController {
  
  var place: (id: String, name: String, latitude: Double, longitude: Double)!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Title and bg color
    title = place.name
    view.backgroundColor = UIColor.wetAsphaltColor()
    
    // Add back nav button
    let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "goBack")
    backButton.configureFlatButtonWithColor(UIColor.turquoiseColor(), highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
    backButton.tintColor = UIColor.cloudsColor()
    navigationItem.leftBarButtonItem = backButton
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func goBack() {
    navigationController?.popViewControllerAnimated(true)
  }
}
