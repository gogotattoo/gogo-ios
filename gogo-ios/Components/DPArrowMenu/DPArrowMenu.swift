//
//  DPArrowMenu.swift
//  DPArrowMenu
//
//  Created by Hongli Yu on 19/01/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

enum DPArrowMenuDirection {
    case up
    case down
}

let DPDefaultMargin : CGFloat = 4
let DPDefaultCellMargin : CGFloat = 6
let DPDefaultMenuIconSize : CGFloat = 24
let DPDefaultMenuCornerRadius : CGFloat = 4
let DPDefaultMenuArrowWidth : CGFloat = 8
let DPDefaultMenuArrowHeight : CGFloat = 10
let DPDefaultAnimationDuration : TimeInterval = 0.2
let DPDefaultBorderWidth : CGFloat = 0.2
let DPDefaultCornerRadius : CGFloat = 10
let DPDefaultMenuRowHeight : CGFloat = 40
let DPDefaultMenuWidth : CGFloat = 200
let DPDefaultTintColor : UIColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)

extension UIScreen {
    
    public static func screen_width() -> CGFloat {
        return self.main.bounds.size.width
    }
    
    public static func screen_height() -> CGFloat {
        return self.main.bounds.size.height
    }
    
}

public class DPConfiguration : NSObject {
    
    static let sharedInstance = DPConfiguration()
    
    public var menuRowHeight : CGFloat = DPDefaultMenuRowHeight
    public var menuWidth : CGFloat = DPDefaultMenuWidth
    
    public var textColor : UIColor = UIColor.black
    
    public var textFont : UIFont = UIFont.systemFont(ofSize: 14)
    public var borderColor : UIColor = DPDefaultTintColor
    
    public var borderWidth : CGFloat = DPDefaultBorderWidth
    
    public var backgoundTintColor : UIColor = UIColor.white
    
    public var cornerRadius : CGFloat = DPDefaultCornerRadius
    public var textAlignment : NSTextAlignment = NSTextAlignment.left
    public var ignoreImageOriginalColor : Bool = false
    public var menuSeparatorColor : UIColor = UIColor.lightGray
    public var menuSeparatorInset : UIEdgeInsets = UIEdgeInsetsMake(0, DPDefaultCellMargin,
                                                                    0, DPDefaultCellMargin)
    
}

extension UIControl {
    
    fileprivate func setAnchorPoint(anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x,
                               y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x,
                               y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position = self.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }
    
}

class DPArrowMenu: NSObject {
    
    static let sharedInstance = DPArrowMenu()
    fileprivate var configuration : DPConfiguration = DPConfiguration.sharedInstance
    
    var sender: UIView?
    var senderFrame: CGRect?
    var dataSource: [DPArrowMenuViewModel]?
    var done: ((_ selectedIndex : NSInteger)->())?
    var cancel: (()->())?
    
    fileprivate lazy var backgroundView : UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.clear
        view.addGestureRecognizer(self.tapGesture)
        return view
    }()
    
    fileprivate lazy var popOverMenu : DPArrowMenuView = {
        let menu = DPArrowMenuView(frame: CGRect.zero)
        menu.alpha = 1
        
        // shadow
        menu.layer.shadowOffset = CGSize.init(width: 2, height: 2)
        menu.layer.shadowColor = UIColor.black.cgColor
        menu.layer.shadowOpacity = 0.4
        menu.clipsToBounds = false
        
        self.backgroundView.addSubview(menu)
        return menu
    }()
    
    fileprivate var isOnScreen : Bool = false {
        didSet {
            if isOnScreen {
                self.addOrientationChangeNotification()
            } else {
                self.removeOrientationChangeNotification()
            }
        }
    }
    
    fileprivate lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(onBackgroudViewTapped(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    fileprivate func showForSender(sender: UIView?, or senderFrame: CGRect?,
                                   with dataSource: [DPArrowMenuViewModel]?,
                                   done: @escaping (NSInteger)->(),
                                   cancel:@escaping ()->()) {
        if sender == nil && senderFrame == nil {
            return
        }
        if self.dataSource?.count == 0 {
            return
        }
        
        self.sender = sender
        self.senderFrame = senderFrame
        self.dataSource = dataSource
        self.done = done
        self.cancel = cancel
        
        UIApplication.shared.keyWindow?.addSubview(self.backgroundView)
        
        self.adjustPostionForPopOverMenu()
    }
    
    fileprivate func adjustPostionForPopOverMenu() {
        self.backgroundView.frame = CGRect(x: 0, y: 0,
                                           width: UIScreen.screen_width(),
                                           height: UIScreen.screen_height())
        self.setupPopOverMenu()
        self.showIfNeeded()
    }
    
    fileprivate func setupPopOverMenu() {
        popOverMenu.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.configurePopMenuFrame()
        
        popOverMenu.showWithAnglePoint(point: menuArrowPoint,
                                       frame: popMenuFrame,
                                       dataSource: dataSource,
                                       arrowDirection: arrowDirection,
                                       done: { (selectedIndex: NSInteger) in
            self.isOnScreen = false
            self.doneActionWithSelectedIndex(selectedIndex: selectedIndex)
        })
        
        popOverMenu.setAnchorPoint(anchorPoint: self.getAnchorPointForPopMenu())
    }
    
    fileprivate func getAnchorPointForPopMenu() -> CGPoint {
        var anchorPoint = CGPoint(x: menuArrowPoint.x / popMenuFrame.size.width, y: 0)
        if arrowDirection == .down {
            anchorPoint = CGPoint(x: menuArrowPoint.x / popMenuFrame.size.width, y: 1)
        }
        return anchorPoint
    }
    
    fileprivate var senderRect : CGRect = CGRect.zero
    fileprivate var popMenuOriginX : CGFloat = 0
    fileprivate var popMenuFrame : CGRect = CGRect.zero
    fileprivate var menuArrowPoint : CGPoint = CGPoint.zero
    fileprivate var arrowDirection : DPArrowMenuDirection = .up
    fileprivate var popMenuHeight : CGFloat {
        return configuration.menuRowHeight * CGFloat(self.dataSource?.count ?? 0) + DPDefaultMenuArrowHeight
    }
    
    fileprivate func configureSenderRect() {
        if self.sender != nil {
            if sender?.superview != nil {
                senderRect = (sender?.superview?.convert((sender?.frame)!, to: backgroundView))!
            } else {
                senderRect = (sender?.frame)!
            }
        } else if senderFrame != nil {
            senderRect = senderFrame!
        }
        senderRect.origin.y = min(UIScreen.screen_height(), senderRect.origin.y)
        if senderRect.origin.y + senderRect.size.height / 2 < UIScreen.screen_height() / 2 {
            arrowDirection = .up
        } else {
            arrowDirection = .down
        }
    }
    
    fileprivate func configurePopMenuOriginX() {
        var senderXCenter : CGPoint = CGPoint(x: senderRect.origin.x + (senderRect.size.width) / 2, y: 0)
        let menuCenterX : CGFloat = configuration.menuWidth / 2 + DPDefaultMargin
        var menuX : CGFloat = 0
        if (senderXCenter.x + menuCenterX > UIScreen.screen_width()) {
            senderXCenter.x = min(senderXCenter.x - (UIScreen.screen_width() - configuration.menuWidth - DPDefaultMargin), configuration.menuWidth - DPDefaultMenuArrowWidth - DPDefaultMargin)
            menuX = UIScreen.screen_width() - configuration.menuWidth - DPDefaultMargin
        } else if (senderXCenter.x - menuCenterX < 0){
            senderXCenter.x = max(DPDefaultMenuCornerRadius + DPDefaultMenuArrowWidth,
                                  senderXCenter.x - DPDefaultMargin)
            menuX = DPDefaultMargin
        } else {
            senderXCenter.x = configuration.menuWidth / 2
            menuX = senderRect.origin.x + (senderRect.size.width) / 2 - configuration.menuWidth / 2
        }
        popMenuOriginX = menuX
    }
    
    fileprivate func configurePopMenuFrame() {
        self.configureSenderRect()
        self.configureMenuArrowPoint()
        self.configurePopMenuOriginX()
        
        if (arrowDirection == .up) {
            popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y + senderRect.size.height),
                                  width: configuration.menuWidth, height: popMenuHeight)
            if (popMenuFrame.origin.y + popMenuFrame.size.height > UIScreen.screen_height()) {
                popMenuFrame = CGRect(x: popMenuOriginX,
                                      y: (senderRect.origin.y + senderRect.size.height),
                                      width: configuration.menuWidth,
                                      height: UIScreen.screen_height() - popMenuFrame.origin.y - DPDefaultMargin)
            }
        } else {
            popMenuFrame = CGRect(x: popMenuOriginX,
                                  y: (senderRect.origin.y - popMenuHeight),
                                  width: configuration.menuWidth,
                                  height: popMenuHeight)
            if (popMenuFrame.origin.y  < 0) {
                popMenuFrame = CGRect(x: popMenuOriginX,
                                      y: DPDefaultMargin,
                                      width: configuration.menuWidth,
                                      height: senderRect.origin.y - DPDefaultMargin)
            }
        }
    }
    
    fileprivate func configureMenuArrowPoint() {
        var point : CGPoint = CGPoint(x: senderRect.origin.x + (senderRect.size.width)/2, y: 0)
        let menuCenterX : CGFloat = configuration.menuWidth/2 + DPDefaultMargin
        if senderRect.origin.y + senderRect.size.height/2 < UIScreen.screen_height()/2 {
            point.y = 0
        } else {
            point.y = popMenuHeight
        }
        if (point.x + menuCenterX > UIScreen.screen_width()) {
            point.x = min(point.x - (UIScreen.screen_width() - configuration.menuWidth - DPDefaultMargin), configuration.menuWidth - DPDefaultMenuArrowWidth - DPDefaultMargin)
        } else if (point.x - menuCenterX < 0){
            point.x = max(DPDefaultMenuCornerRadius + DPDefaultMenuArrowWidth, point.x - DPDefaultMargin)
        } else {
            point.x = configuration.menuWidth/2
        }
        menuArrowPoint = point
    }
    
    @objc fileprivate func onBackgroudViewTapped(gesture : UIGestureRecognizer) {
        self.dismiss()
    }
    
    fileprivate func showIfNeeded() {
        if self.isOnScreen == false {
            self.isOnScreen = true
            popOverMenu.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: DPDefaultAnimationDuration, animations: {
                self.popOverMenu.alpha = 1
                self.popOverMenu.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    fileprivate func dismiss() {
        self.isOnScreen = false
        self.doneActionWithSelectedIndex(selectedIndex: -1)
    }
    
    fileprivate func doneActionWithSelectedIndex(selectedIndex: NSInteger) {
        UIView.animate(withDuration: DPDefaultAnimationDuration,
                       animations: {
                        self.popOverMenu.alpha = 0
                        self.popOverMenu.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (isFinished) in
            if isFinished {
                self.backgroundView.removeFromSuperview()
                if selectedIndex < 0 {
                    self.cancel?()
                } else {
                    self.done?(selectedIndex)
                }
            }
        }
    }

}

extension DPArrowMenu { // entrance
    
    public static func showForSender(sender : UIView,
                                     with dataSource: [DPArrowMenuViewModel]?,
                                     done: @escaping (NSInteger)->(),
                                     cancel:@escaping ()->()) {
        self.sharedInstance.showForSender(sender: sender, or: nil,
                                          with: dataSource,
                                          done: done, cancel: cancel)
    }

    public static func dismiss() {
        self.sharedInstance.dismiss()
    }
    
}

extension DPArrowMenu { // notifications for orientation changed
    
    fileprivate func addOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
                                               object: nil)
        
    }
    
    fileprivate func removeOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification : Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.adjustPostionForPopOverMenu()
        })
    }
    
}

extension DPArrowMenu: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: backgroundView)
        let touchClass: String = NSStringFromClass((touch.view?.classForCoder)!) as String
        if touchClass == "UITableViewCellContentView" {
            return false
        } else if CGRect(x: 0, y: 0,
                         width: configuration.menuWidth,
                         height: configuration.menuRowHeight).contains(touchPoint) {
            // navgation bar button item
            self.doneActionWithSelectedIndex(selectedIndex: 0)
            return false
        }
        return true
    }
    
}

