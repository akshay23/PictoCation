//
//  User.swift
//  PictoCation
//
//  Created by Akshay Bharath on 7/15/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {
  @NSManaged var userID: String
  @NSManaged var accessToken: String
  @NSManaged var placesType: String?
}