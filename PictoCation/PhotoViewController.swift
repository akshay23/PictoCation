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
  @IBOutlet var buttonsView: UIView!
  @IBOutlet var commentsTable: UITableView!
  @IBOutlet var lineView: UIView!
  @IBOutlet var likeBtn: UIButton!
  @IBOutlet var commentBtn: UIButton!

  var user: User?
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
    buttonsView.layer.cornerRadius = 4
    buttonsView.backgroundColor = UIColor.cloudsColor()
    commentsTable.layer.cornerRadius = 4
    commentsTable.backgroundColor = UIColor.wetAsphaltColor()
    commentsTable.tableFooterView = UIView(frame: CGRectZero)
    commentsTable.rowHeight = UITableViewAutomaticDimension
    commentsTable.estimatedRowHeight = 160.0
    lineView.backgroundColor = UIColor.silverColor()
    
    // Set like button icon
    updateLikeButton()
    
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
    var photo: UIImage?
    let exists = sharedImageCache.retrieveImageForEntity(photoInfo, withFormatName: KMBigImageFormatName, completionBlock: {
      (photoInfo, _, image) -> Void in
      self.mainPhotoView.image = image
    })
    
    // Get comments
    let urlString = Instagram.Router.PhotoComments(photoInfo!.instagramID, user!.accessToken)
    comments = []
    populateComments(urlString)
  }
  
  func populateComments(request: URLRequestConvertible) {
    Alamofire.request(request).responseJSON() {
      (_ , _, jsonObject, error) in
      
      if (error == nil) {
        let json = JSON(jsonObject!)
        if (json["meta"]["code"].intValue  == 200) {
          if let caption = json["data"]["caption"]["text"].string {
            self.comments.append(user: "@" + json["data"]["caption"]["from"]["username"].stringValue, comment: caption)
          }
          
          if (json["data"]["comments"]["count"].intValue == 0 && self.comments.count == 0) {
            self.comments.append(user: "", comment: "No Comments for this Photo")
          } else {
            for comment in json["data"]["comments"]["data"].arrayValue {
              self.comments.append(user: "@" + comment["from"]["username"].stringValue, comment: comment["text"].stringValue)
            }
          }
          self.photoInfo!.isLiked = json["data"]["user_has_liked"].boolValue

          self.commentsTable.reloadData()
          self.updateLikeButton()
        }
      } else {
        self.showAlertWithMessage("Click 'Refresh' to try again", title: "Couldn't Get Comments", button: "OK")
      }
    }
  }
  
  func updateLikeButton() {
    if (photoInfo!.isLiked) {
      likeBtn.setImage(UIImage(named: "Heart-red"), forState: .Normal)
    } else {
      likeBtn.setImage(UIImage(named: "Heart-white"), forState: .Normal)
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
  
  @IBAction func comment(sender: AnyObject) {
  }
  
  @IBAction func like(sender: AnyObject) {
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

extension PhotoViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
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

extension PhotoViewController: UITableViewDelegate {
}
