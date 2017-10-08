//
//  BaseNavigationBar.swift
//  gogo-ios
//
//  Created by Hongli Yu on 03/10/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class BaseNavigationBar: UINavigationBar {
  
  /// Hack in respond chain, disable navigation bar respond
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let currentResponderView = super.hitTest(point, with: event)
    //    if let topController = MainManager.shared.visiableViewController {
    //      if topController is HomeViewController {
    //        if currentResponderView is BaseNavigationBar {
    //          return nil
    //        }
    //      }
    //      if topController is LoginViewController {
    //        if currentResponderView is BaseNavigationBar {
    //          return nil
    //        }
    //      }
    //    }
    return currentResponderView
  }
  
}
