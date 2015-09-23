//
//  LeftViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/5/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import FlatUIKit

@objc
protocol LeftViewControllerDelegate {
  func typeSelected(type: String)
}

class LeftViewController: UITableViewController {
  
  var delegate: LeftViewControllerDelegate?
  var types: Array<String> = []
  var user: User!
  var selectedIndex: Int!
  var selectedCell: UITableViewCell!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize types
    types.append("Art Gallery")
    types.append("Bakery")
    types.append("Bar")
    types.append("Cafe")
    types.append("Clothing Store")
    types.append("Establishment")
    types.append("Gym")
    types.append("Library")
    types.append("Lodging")
    types.append("Museum")
    types.append("Night Club")
    types.append("Park")
    types.append("Restaurant")
    types.append("School")
    types.append("Spa")
    types.append("Stadium")
    types.append("Store")
    types.append("Train Station")
    types.append("Zoo")
    
    // Remove separator line and set bg color of table
    let table = self.view as! UITableView
    table.separatorStyle = .None
    table.backgroundColor = UIColor.concreteColor()
    
    // Get selected type index
    var selectedType: String = "Establishment"
    if let user = user {
      selectedType = user.placesType
    }
    selectedIndex = types.find { $0 == selectedType }
    print("Selected type is \(selectedType) and index is \(selectedIndex)")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0), atScrollPosition: .None, animated: true)
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return types.count
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if (selectedCell != nil) {
      selectedCell.configureFlatCellWithColor(UIColor.concreteColor(), selectedColor: UIColor.cloudsColor())
    }

    delegate?.typeSelected(types[indexPath.row])
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
    
    cell.textLabel?.text = types[indexPath.row]
    cell.textLabel?.font = UIFont.systemFontOfSize(15)
    
    if (indexPath.row == selectedIndex) {
      cell.configureFlatCellWithColor(UIColor.cloudsColor(), selectedColor: UIColor.concreteColor())
      selectedCell = cell
    } else {
      cell.configureFlatCellWithColor(UIColor.concreteColor(), selectedColor: UIColor.cloudsColor())
    }
    
    return cell
  }
}
