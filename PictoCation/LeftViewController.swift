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

  override func viewDidLoad() {
    super.viewDidLoad()
    
    types.append("ALL")
    types.append("atm")
    types.append("bar")
    types.append("cafe")
    types.append("establishment")
    types.append("restaurant")
    
    let table = self.view as! UITableView
    table.separatorColor = UIColor.clearColor()
    table.backgroundColor = UIColor.concreteColor()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return types.count
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    delegate?.typeSelected(types[indexPath.row])
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    cell.textLabel?.text = types[indexPath.row]
    cell.configureFlatCellWithColor(UIColor.concreteColor(), selectedColor: UIColor.cloudsColor())
    return cell
  }
}
