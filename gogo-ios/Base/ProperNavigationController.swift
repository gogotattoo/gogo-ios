//
//  ProperNavigationController.swift
//  italki
//
//  Created by Hongli Yu on 10/04/2017.
//  Copyright © 2017 italki. All rights reserved.
//

import UIKit

class ProperNavigationController: UINavigationController, UINavigationControllerDelegate {
    
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
//        if let coordinator = navigationController.topViewController?.transitionCoordinator {
//            coordinator.notifyWhenInteractionEnds({ (context) in
//                if !context.isCancelled {
//                    guard let currrentViewController = self.currrentViewController else { return }
//                    
//                    if currrentViewController is PackageViewController
//                        && viewController is PackagesFilterViewController {
//                        #if DEBUG
//                            print("Edge Swipe: PackageViewController -> PackagesFilterViewController")
//                        #endif
//                        PackageManager.sharedInstance.exitPackageDetailPage()
//                        self.currrentViewController = viewController
//                    }
//                    
//                    if currrentViewController is PackageLessonsModifyViewController
//                        && viewController is PackageViewController {
//                        #if DEBUG
//                            print("Edge Swipe: PackageLessonsModifyViewController -> PackageViewController")
//                        #endif
//                        PackageManager.sharedInstance.exitPackageLessonsModifyStatus()
//                        self.currrentViewController = viewController
//                    }
//                    
//                    if currrentViewController is PackagesFilterViewController
//                        && viewController is DashboardViewController {
//                        #if DEBUG
//                            print("Edge Swipe: PackagesFilterViewController -> DashboardViewController")
//                        #endif
//                        PackageManager.sharedInstance.exitPackageListPage()
//                        self.currrentViewController = viewController
//                    }
//                }
//            })
//        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
