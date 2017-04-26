//
//  BaseView.swift
//  gogo-ios
//
//  Created by Hongli Yu on 14/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class BaseView: UIView {
    
    // MARK: Response chain
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let currentResponderView = super.hitTest(point, with: event)
        if currentResponderView == nil {
            
        }
        return currentResponderView
    }

}
