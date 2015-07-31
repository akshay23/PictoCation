//
//  GalleryViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/30/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Alamofire
import FastImageCache
import SwiftyJSON

class GalleryViewController: UICollectionViewController {
  
  var photos = [PhotoInfo]()
  var populatingPhotos = false
  var nextURLRequest: NSURLRequest?
  var user: User?
  var hashtagTopic: String!
  
  let PhotoBrowserCellIdentifier = "PhotoBrowserCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Update the look of components
    let back = navigationItem.backBarButtonItem!
    navigationItem.backBarButtonItem?.tintColor = UIColor.turquoiseColor()
//    
//    let backItem = UIBarButtonItem(title: "BLAH", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
//    navigationController!.navigationBar.backItem?.backBarButtonItem?.configureFlatButtonWithColor(UIColor.turquoiseColor(),
//      highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
//    navigationController!.navigationBar.tintColor = UIColor.turquoiseColor()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.title = hashtagTopic
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
  
}
