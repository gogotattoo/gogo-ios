//
//  BaseNavigationController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 03/10/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController, UINavigationControllerDelegate {
  
  fileprivate var currrentViewController: UIViewController?
  
  func setCurrentViewController(viewController: UIViewController) {
    self.currrentViewController = viewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }
  
  func navigationController(_ navigationController: UINavigationController,
                            willShow viewController: UIViewController,
                            animated: Bool) {
    // edge swipe action, but NOT click back button action, processing data changes
//    if let coordinator = navigationController.topViewController?.transitionCoordinator {
//      coordinator.notifyWhenInteractionEnds({ (context) in
//        if !context.isCancelled {
//          guard let currrentViewController = self.currrentViewController else { return }
//
//          if currrentViewController is TeacherListViewController
//            && viewController is HomeViewController {
//            LogHandler.DebugLog(message: "Edge Swipe: TeacherListViewController -> HomeViewController")
//            MainManager.shared.exitSearchTeacherListPage()
//            self.currrentViewController = viewController
//          }
//
//          if currrentViewController is PackageViewController
//            && viewController is PackagesFilterViewController {
//            LogHandler.DebugLog(message: "Edge Swipe: PackageViewController -> PackagesFilterViewController")
//            MainManager.shared.exitPackageDetailPage()
//            self.currrentViewController = viewController
//          }
//
//          if currrentViewController is PackageLessonsModifyViewController
//            && viewController is PackageViewController {
//            LogHandler.DebugLog(message: "Edge Swipe: PackageLessonsModifyViewController -> PackageViewController")
//            MainManager.shared.exitPackageLessonsModifyStatus()
//            self.currrentViewController = viewController
//          }
//
//          if currrentViewController is PackagesFilterViewController
//            && viewController is DashboardViewController {
//            LogHandler.DebugLog(message: "Edge Swipe: PackagesFilterViewController -> DashboardViewController")
//            MainManager.shared.exitPackageListPage()
//            self.currrentViewController = viewController
//          }
//        }
//      })
//    }
  }
  
  func navigationController(_ navigationController: UINavigationController,
                            didShow viewController: UIViewController,
                            animated: Bool) {
  }
  
}
