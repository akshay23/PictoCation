//
//  PhotoViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/5/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import FlatUIKit
import FastImageCache
import QuartzCore
import MBProgressHUD

class PhotoViewController: UIViewController {
  
  @IBOutlet var mainPhotoView: UIImageView!

  var photoInfo: PhotoInfo?
  var hashtagTopic: String!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set bg color and title
    self.title = "#\(hashtagTopic)"
    view.backgroundColor = UIColor.wetAsphaltColor()
    
    // Add back nav button
    let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "goBack")
    backButton.configureFlatButtonWithColor(UIColor.turquoiseColor(), highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
    backButton.tintColor = UIColor.cloudsColor()
    navigationItem.leftBarButtonItem = backButton
    
    // Add refresh nav button
    let refreshButton = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "goRefresh")
    refreshButton.configureFlatButtonWithColor(UIColor.turquoiseColor(), highlightedColor: UIColor.greenSeaColor(), cornerRadius: 3)
    refreshButton.tintColor = UIColor.cloudsColor()
    navigationItem.rightBarButtonItem = refreshButton
    
    // Set up photo view shadow effect
    mainPhotoView.layer.shadowOpacity = 0.5
    mainPhotoView.layer.shadowRadius = 5
    mainPhotoView.layer.shadowOffset = CGSize(width: 10, height: 10)
    
    // Add double-tap recognzier to image view
    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
    doubleTapRecognizer.numberOfTapsRequired = 2
    doubleTapRecognizer.numberOfTouchesRequired = 1
    mainPhotoView.addGestureRecognizer(doubleTapRecognizer)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    goRefresh()
  }
  
  func refresh() {
    let sharedImageCache = FICImageCache.sharedImageCache()
    var photo: UIImage?
    let exists = sharedImageCache.retrieveImageForEntity(photoInfo, withFormatName: KMBigImageFormatName, completionBlock: {
      (photoInfo, _, image) -> Void in
      self.mainPhotoView.image = image
    })
  }
  
  func goBack() {
    view.resignFirstResponder()
    navigationController?.popViewControllerAnimated(true)
  }
  
  func goRefresh() {
    checkReachabilityWithBlock {
      self.refresh()
    }
  }
  
  // TODO: Like/Unlike photo
  func handleDoubleTap(recognizer: UITapGestureRecognizer!) {
    let alert = FUIAlertView()
    alert.title = "Double-tap"
    alert.message = "Eventually this image will be 'liked'"
    alert.delegate = nil
    alert.addButtonWithTitle("OK")
    alert.titleLabel.textColor = UIColor.cloudsColor()
    alert.titleLabel.font = UIFont.boldFlatFontOfSize(16);
    alert.messageLabel.textColor = UIColor.cloudsColor()
    alert.messageLabel.font = UIFont.flatFontOfSize(12)
    alert.backgroundOverlay.backgroundColor = UIColor.cloudsColor().colorWithAlphaComponent(0.8)
    alert.alertContainer.backgroundColor = UIColor.midnightBlueColor()
    alert.defaultButtonColor = UIColor.cloudsColor()
    alert.defaultButtonShadowColor = UIColor.asbestosColor()
    alert.defaultButtonFont = UIFont.boldFlatFontOfSize(14)
    alert.defaultButtonTitleColor = UIColor.asbestosColor()
    alert.show()
    alert.show()
  }
}
