//
//  CoreDataStack.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/16/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
  
  var context: NSManagedObjectContext
  var storeCoordinator: NSPersistentStoreCoordinator
  var model: NSManagedObjectModel
  var store: NSPersistentStore?
  
  init() {
    let bundle = NSBundle.mainBundle()
    let modelURL = bundle.URLForResource("PictoCation", withExtension: "momd")
    
    model = NSManagedObjectModel(contentsOfURL: modelURL!)!
    storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    context.persistentStoreCoordinator = storeCoordinator
    
    let documentsURL = applicationDocumentsDirectory()
    let storeURL = documentsURL.URLByAppendingPathComponent("PictoCation.sqlite")
    let options = [NSMigratePersistentStoresAutomaticallyOption: true]
    var error: NSError? = nil
    
    store = storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
      configuration: nil,
      URL: storeURL,
      options: options,
      error:&error)
    
    if store == nil {
      println("Error adding persistent store: \(error)")
      abort()
    }
  }
  
  func saveContext() {
    var error: NSError? = nil
    if context.hasChanges && !context.save(&error) {
      println("Could not save: \(error), \(error?.userInfo)")
    }
  }
  
  func applicationDocumentsDirectory() -> NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] as! NSURL
  }

}