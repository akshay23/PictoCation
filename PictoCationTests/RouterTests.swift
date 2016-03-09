//
//  RouterTests.swift
//  PictoCation
//
//  Created by Akshay Bharath on 10/7/15.
//  Copyright © 2015 Akshay Bharath. All rights reserved.
//

import XCTest
@testable import  PictoCation

class RouterTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testInstagramRouters() {
    let topic: String = "Spurs"
    let token: String = "token123ABC"
    let instagramId: String = "photo1234"
    let taggedPhotos = Instagram.Router.TaggedPhotos(topic, token)
    let photoComments = Instagram.Router.PhotoComments(instagramId, token)
    
    XCTAssertTrue(taggedPhotos.URLRequest.URLString.containsString("/v1/tags/\(topic)"), "Topic was not found in the URL Request")
    XCTAssertTrue(taggedPhotos.URLRequest.URLString.containsString("access_token=\(token)"), "Access token is incorrect")
    XCTAssertTrue(photoComments.URLRequest.URLString.containsString("/v1/media/\(instagramId)"), "Instagram ID is incorrect")
    XCTAssertTrue(photoComments.URLRequest.URLString.containsString("access_token=\(token)"), "Access token is incorrect")
  }
  
}
