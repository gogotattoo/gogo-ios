//
//  BaseViewController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 14/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BaseViewController: UIViewController, NVActivityIndicatorViewable {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.becomeTransparent(true, tintColor: UIColor.white,
                                                          titleColor: UIColor.white)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.becomeTransparent(false, tintColor: view.tintColor,
                                                          titleColor: UIColor.black)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
}
