//
//  AppDelegate.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/15/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import FastImageCache
import GoogleMaps
import Fabric
import Crashlytics
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    // Instantiate fastimagecache
    FastImageCacheHelper.setUp(self)

    // Instantiate core data stack
    let containerViewController = ContainerViewController()
    window!.rootViewController = containerViewController
    
    // Google Maps auth
    GMSServices.provideAPIKey("AIzaSyC1ZOBSUT8Z5Xl7tzGZ6KnL9on5LoFsHWs")
    
    // Hide status bar
    application.statusBarHidden = true
    
    // Initialize Crashlytics
    Fabric.with([Crashlytics.self()])
    
    // Setup iRate
    iRate.sharedInstance().onlyPromptIfLatestVersion = true
    iRate.sharedInstance().daysUntilPrompt = 5
    iRate.sharedInstance().remindPeriod = 3
    iRate.sharedInstance().message = "Please rate PictoCation in the app store."
    iRate.sharedInstance().cancelButtonLabel = "No Thanks"
    iRate.sharedInstance().rateButtonLabel = "Rate Now"
    
    // Initialize Parse.
    Parse.setApplicationId("elNhCUZJesysEPkQjetYsEGR6MIxVbRNtJ6wYb9k",
      clientKey: "NQyU93M3jeSjDfj7Xf3hSj3kKnwT2r4467Wjm8Sr")
    
    // [Optional] Track statistics around application opens.
    PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)

    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    CoreDataStack.sharedInstance.saveContext()
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    CoreDataStack.sharedInstance.saveContext()
  }

  // MARK: - Core Data stack
  
  lazy var applicationDocumentsDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] 
    }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = NSBundle.mainBundle().URLForResource("PictoCation", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("PictoCation.sqlite")
    var error: NSError? = nil
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch var error1 as NSError {
      error = error1
      coordinator = nil
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      dict[NSUnderlyingErrorKey] = error
      error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      NSLog("Unresolved error \(error), \(error!.userInfo)")
    } catch {
      fatalError()
    }
    
    return coordinator
    }()
  
  lazy var managedObjectContext: NSManagedObjectContext? = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
    }()
}

extension AppDelegate: FICImageCacheDelegate {
  func imageCache(imageCache: FICImageCache!, wantsSourceImageForEntity entity: FICEntity!, withFormatName formatName: String!, completionBlock: FICImageRequestCompletionBlock!) {
    if let entity = entity as? PhotoInfo {
      let imageURL = entity.sourceImageURLWithFormatName(formatName)
      let request = NSURLRequest(URL: imageURL)
      
      entity.request = Alamofire.request(request).validate(contentType: ["image/*"]).responseImage() {
        (_, _, image, error) in
        if (error == nil) {
          completionBlock(image)
        }
      }
    }
  }
  
  func imageCache(imageCache: FICImageCache!, cancelImageLoadingForEntity entity: FICEntity!, withFormatName formatName: String!) {
    if let entity = entity as? PhotoInfo, request = entity.request {
      request.cancel()
      entity.request = nil
    }
  }
  
  func imageCache(imageCache: FICImageCache!, shouldProcessAllFormatsInFamily formatFamily: String!, forEntity entity: FICEntity!) -> Bool {
    return true
  }
  
  func imageCache(imageCache: FICImageCache!, errorDidOccurWithMessage errorMessage: String!) {
    print("errorMessage" + errorMessage)
  }

}

