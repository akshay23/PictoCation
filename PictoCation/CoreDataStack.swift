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
    
    do {
      store = try storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
        configuration: nil,
        URL: storeURL,
        options: options)
    } catch let error1 as NSError {
      error = error1
      store = nil
    }
    
    if store == nil {
      print("Error adding persistent store: \(error)")
    }
  }
  
  func saveContext() {
    var error: NSError? = nil
    if context.hasChanges {
      do {
        try context.save()
      } catch let error1 as NSError {
        error = error1
        print("Could not save: \(error), \(error?.userInfo)")
      }
    }
  }
  
  func applicationDocumentsDirectory() -> NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] 
  }

}