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
  @IBOutlet var commentsTable: UITableView!

  var user: User!
  var photoInfo: PhotoInfo?
  var hashtagTopic: String!
  var comments: [(user: String, comment: String)] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set bg color
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
    
    // Set up the appearances
    commentsTable.layer.cornerRadius = 4
    commentsTable.backgroundColor = UIColor.wetAsphaltColor()
    commentsTable.tableFooterView = UIView(frame: CGRectZero)
    commentsTable.rowHeight = UITableViewAutomaticDimension
    commentsTable.estimatedRowHeight = 160.0
    
    // Add double-tap recognzier to image view
    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
    doubleTapRecognizer.numberOfTapsRequired = 2
    doubleTapRecognizer.numberOfTouchesRequired = 1
    mainPhotoView.addGestureRecognizer(doubleTapRecognizer)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.title = "#\(hashtagTopic)"
    goRefresh()
  }
  
  func refresh() {
    // Get image
    let sharedImageCache = FICImageCache.sharedImageCache()
    sharedImageCache.retrieveImageForEntity(photoInfo, withFormatName: KMBigImageFormatName, completionBlock: {
      (photoInfo, _, image) -> Void in
      self.mainPhotoView.image = image
    })
    
    // Get comments
    let urlString = Instagram.Router.PhotoComments(photoInfo!.instagramID, user!.accessToken)
    comments = []
    populateComments(urlString)
  }
  
  func populateComments(request: URLRequestConvertible) {
    Alamofire.request(request)
      .validate()
      .responseJSON() {
      (result) in
      
      if (result.result.isSuccess) {
        let json = JSON(result.result.value!)
        if (json["meta"]["code"].intValue  == 200) {
          if let caption = json["data"]["caption"]["text"].string {
            let comment = ("@" + json["data"]["caption"]["from"]["username"].stringValue, caption)
            self.comments.append(comment)
          }
          
          if (json["data"]["comments"]["count"].intValue == 0 && self.comments.count == 0) {
            let comment = ("", "No Comments for this Photo")
            self.comments.append(comment)
          } else {
            for comment in json["data"]["comments"]["data"].arrayValue {
              let comment = ("@" + comment["from"]["username"].stringValue, comment["text"].stringValue)
              self.comments.append(comment)
            }
          }
          self.photoInfo!.isLiked = json["data"]["user_has_liked"].boolValue

          self.commentsTable.reloadData()
        }
      } else {
        self.showAlertWithMessage("Click 'Refresh' to try again", title: "Couldn't Get Comments", button: "OK")
      }
    }
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
}

extension PhotoViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
    let comment = comments[indexPath.row]
    cell.textLabel!.text = comment.comment
    cell.detailTextLabel!.text = comment.user
    cell.backgroundColor = UIColor.cloudsColor()
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
}

extension PhotoViewController: UITableViewDelegate {}
