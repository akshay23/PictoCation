//
//  GalleryViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/30/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import FastImageCache
import SwiftyJSON
import FlatUIKit
import MBProgressHUD

class GalleryViewController: UICollectionViewController {

  @IBOutlet var mainCollectionView: UICollectionView!

  var photos = [PhotoInfo]()
  var populatingPhotos = false
  var nextURLRequest: NSURLRequest?
  var user: User?
  var hashtagTopic: String!
  var shouldRefresh: Bool = false

  let formatName = KMSmallImageFormatName
  let PhotoBrowserCellIdentifier = "PhotoBrowserCell"
  let PhotoBrowserFooterViewIdentifier = "PhotoBrowserFooterView"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // BG color
    mainCollectionView.backgroundColor = UIColor.wetAsphaltColor()
    
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
    
    // Add text field to nav bar
    let textfield = UITextField(frame: CGRectMake(0.0, 0.0, CGFloat(count(hashtagTopic) + 3),
      navigationController!.navigationBar.frame.size.height))
    textfield.text = "#\(hashtagTopic)"
    textfield.backgroundColor = UIColor.clearColor()
    textfield.layer.borderWidth = 0
    textfield.font = UIFont.systemFontOfSize(20)
    textfield.autocorrectionType = .No
    textfield.textAlignment = .Center
    textfield.returnKeyType = .Done
    textfield.addTarget(self, action: Selector("goRefresh"), forControlEvents: .EditingDidEndOnExit)
    navigationItem.titleView = textfield
    
    // Set up collection
    setupView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if (photos.count == 0 || shouldRefresh) {
      shouldRefresh = false
      goRefresh()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "show photo" && segue.destinationViewController.isKindOfClass(PhotoViewController.classForCoder()) {
      let photoViewController = segue.destinationViewController as! PhotoViewController
      photoViewController.photoInfo = sender?.valueForKey("photoInfo") as? PhotoInfo
      photoViewController.hashtagTopic = hashtagTopic
      photoViewController.user = user
    }
  }
  
  func goBack() {
    view.resignFirstResponder()
    navigationController?.popViewControllerAnimated(true)
  }
  
  func goRefresh() {
    let titleView = navigationItem.titleView as? UITextField
    titleView!.resignFirstResponder()
    let chars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
    hashtagTopic = stripOutUnwantedCharactersFromText(titleView!.text, characterSet: chars)

    checkReachabilityWithBlock {
      self.refresh()
    }
  }
  
  func populatePhotos(request:URLRequestConvertible) {
    if populatingPhotos {
      return
    }
    
    populatingPhotos = true
    Alamofire.request(request).responseJSON() {
      (_ , _, jsonObject, error) in
      
      if (error == nil) {
        let json = JSON(jsonObject!)
        if (json["meta"]["code"].intValue  == 200) {
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            if let urlString = json["pagination"]["next_url"].URL {
              self.nextURLRequest = NSURLRequest(URL: urlString)
            } else {
              self.nextURLRequest = nil
            }
            let photoInfos = json["data"].arrayValue
              
              .filter {
                $0["type"].stringValue == "image"
              }.map({
                PhotoInfo(instaID: $0["id"].stringValue,
                  sourceImageURL: $0["images"]["standard_resolution"]["url"].URL!,
                  isLiked: $0["user_has_liked"].boolValue)
              })
            
            let lastItem = self.photos.count
            self.photos.extend(photoInfos)
            
            let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
            
            dispatch_async(dispatch_get_main_queue()) {
              self.collectionView!.insertItemsAtIndexPaths(indexPaths)

              if let navi = self.navigationController {
                MBProgressHUD.hideAllHUDsForView(navi.view, animated: true)
              }

              if (self.photos.count == 0) {
                self.showAlertWithMessage("There are no photos for #\(self.hashtagTopic)", title: "No Photos", button: "OK")
              }
            }
          }
        }
      } else {
        self.showAlertWithMessage("Click 'Refresh' to try again", title: "Couldn't Get Photos", button: "OK")
      }
      self.populatingPhotos = false
    }
  }
  
  func refresh() {
    nextURLRequest = nil
    
    if let navi = self.navigationController {
      let loadingNotification = MBProgressHUD.showHUDAddedTo(navi.view, animated: true)
      loadingNotification.mode = MBProgressHUDMode.Indeterminate
    }

    self.photos.removeAll(keepCapacity: false)
    self.collectionView!.reloadData()
    
    if user != nil {
      let urlString = Instagram.Router.TaggedPhotos(hashtagTopic, user!.accessToken)
      populatePhotos(urlString)
    }
  }
  
  func setupView() {
    let layout = UICollectionViewFlowLayout()
    let itemWidth = (view.bounds.size.width - 2) / 3
    layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
    layout.minimumInteritemSpacing = 1.0
    layout.minimumLineSpacing = 1.0
    layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 100.0)
    collectionView!.collectionViewLayout = layout
    collectionView!.registerClass(PhotoBrowserCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoBrowserCellIdentifier)
    collectionView!.registerClass(PhotoBrowserLoadingCollectionView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoBrowserFooterViewIdentifier)
  }
  
  func stripOutUnwantedCharactersFromText(text: String, characterSet: Set<Character>) -> String {
    return String(filter(text) { characterSet.contains($0) })
  }
}

class PhotoBrowserCollectionViewCell: UICollectionViewCell {
  let imageView = UIImageView()
  var photoInfo: PhotoInfo?
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.midnightBlueColor()
    imageView.frame = bounds
    addSubview(imageView)
  }
}

class PhotoBrowserLoadingCollectionView: UICollectionReusableView {
  let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    spinner.startAnimating()
    spinner.center = self.center
    addSubview(spinner)
  }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoBrowserCellIdentifier, forIndexPath: indexPath) as! PhotoBrowserCollectionViewCell
    let sharedImageCache = FICImageCache.sharedImageCache()
    cell.imageView.image = nil
    
    let photo = photos[indexPath.row] as PhotoInfo
    if (cell.photoInfo != photo) {
      sharedImageCache.cancelImageRetrievalForEntity(cell.photoInfo, withFormatName: formatName)
      cell.photoInfo = photo
    }
    
    sharedImageCache.retrieveImageForEntity(photo, withFormatName: formatName, completionBlock: {
      (photoInfo, _, image) -> Void in
      if (photoInfo as! PhotoInfo) == cell.photoInfo {
        let p = photoInfo as! PhotoInfo
        cell.imageView.image = image
      }
    })
    
    return cell  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoBrowserFooterViewIdentifier, forIndexPath: indexPath) as! PhotoBrowserLoadingCollectionView
    if nextURLRequest == nil {
      footerView.spinner.stopAnimating()
    } else {
      footerView.spinner.startAnimating()
    }
    return footerView
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let photoInfo = photos[indexPath.row]
    performSegueWithIdentifier("show photo", sender: ["photoInfo": photoInfo])
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    if (self.nextURLRequest != nil && scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8) {
      populatePhotos(self.nextURLRequest!)
    }
  }
}
