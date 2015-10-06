//
//  ContainerViewController.swift
//  PictoCation
//
//  Created by Akshay Bharath on 8/5/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
  case BothCollapsed
  case LeftPanelExpanded
}

class ContainerViewController: UIViewController {
  
  var centerNavigationController: UINavigationController!
  var centerViewController: MapViewController!
  var coreDataStack: CoreDataStack!
  var currentState: SlideOutState = .BothCollapsed {
    didSet {
      let shouldShowShadow = currentState != .BothCollapsed
      showShadowForCenterViewController(shouldShowShadow)
    }
  }
  
  var leftViewController: LeftViewController?
  
  let CenterPanelExpandedOffset: CGFloat = 220
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    centerViewController = UIStoryboard.centerViewController()
    centerViewController.delegate = self
    centerViewController.coreDataStack = coreDataStack
    
    // wrap the centerViewController in a navigation controller, so we can push views to it
    // and display bar button items in the navigation bar
    centerNavigationController = UINavigationController(rootViewController: centerViewController)
    view.addSubview(centerNavigationController.view)
    addChildViewController(centerNavigationController)
    centerNavigationController.didMoveToParentViewController(self)
  }
}

extension ContainerViewController: CenterViewControllerDelegate {
  func toggleLeftPanel(user: User!) {
    let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
    
    if notAlreadyExpanded {
      addLeftPanelViewController(user)
    }
    
    animateLeftPanel(shouldExpand: notAlreadyExpanded)
  }
  
  func collapseSidePanel() {
    toggleLeftPanel(nil)
  }
  
  func addLeftPanelViewController(user: User!) {
    if (leftViewController == nil) {
      leftViewController = UIStoryboard.leftViewController()
      leftViewController!.user = user
      
      if let controller = leftViewController {
        addChildSidePanelController(controller)
      }
    }
  }
  
  func addChildSidePanelController(sidePanelController: LeftViewController) {
    sidePanelController.delegate = centerViewController
    view.insertSubview(sidePanelController.view, atIndex: 0)
    addChildViewController(sidePanelController)
    sidePanelController.didMoveToParentViewController(self)
  }
  
  func animateLeftPanel(shouldExpand shouldExpand: Bool) {
    if (shouldExpand) {
      currentState = .LeftPanelExpanded
      animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - (centerNavigationController.view.frame.width - 150))
    } else {
      animateCenterPanelXPosition(targetPosition: 0) { finished in
        self.currentState = .BothCollapsed
        self.leftViewController!.view.removeFromSuperview()
        self.leftViewController = nil;
      }
    }
  }
  
  func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
      self.centerNavigationController.view.frame.origin.x = targetPosition
      }, completion: completion)
  }
  
  func showShadowForCenterViewController(shouldShowShadow: Bool) {
    if (shouldShowShadow) {
      centerNavigationController.view.layer.shadowOpacity = 0.8
      centerNavigationController.view.layer.shadowRadius = 3
    } else {
      centerNavigationController.view.layer.shadowOpacity = 0.0
      centerNavigationController.view.layer.shadowRadius = 0
    }
  }
}

private extension UIStoryboard {
  class func mainStoryboard() -> UIStoryboard {
    return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
  }
  
  class func leftViewController() -> LeftViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? LeftViewController
  }
  
  class func centerViewController() -> MapViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier("MapViewController") as? MapViewController
  }
  
}