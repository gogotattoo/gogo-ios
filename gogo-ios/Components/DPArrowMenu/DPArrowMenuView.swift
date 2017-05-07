//
//  DPArrowMenuView.swift
//  DPArrowMenu
//
//  Created by Hongli Yu on 19/01/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

fileprivate let DPPopOverMenuTableViewCellIndentifier = "DPPopOverMenuTableViewCellIndentifier"

class DPArrowMenuView: UIControl {
    
    fileprivate var dataSource: [DPArrowMenuViewModel]?
    fileprivate var arrowDirection: DPArrowMenuDirection = .up
    fileprivate var done: ((NSInteger)->())?
    
    fileprivate lazy var configuration: DPConfiguration = DPConfiguration.sharedInstance
    
    lazy var menuTableView : UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = DPConfiguration.sharedInstance.menuSeparatorColor
        tableView.layer.cornerRadius = DPConfiguration.sharedInstance.cornerRadius
        tableView.clipsToBounds = true
        return tableView
    }()
    
    func showWithAnglePoint(point: CGPoint,
                            frame: CGRect,
                            dataSource: [DPArrowMenuViewModel]?,
                            arrowDirection: DPArrowMenuDirection,
                            done: @escaping ((NSInteger)->())) {
        self.frame = frame
        self.dataSource = dataSource
        self.arrowDirection = arrowDirection
        self.done = done
        
        self.repositionMenuTableView()
        self.drawBackgroundLayerWithArrowPoint(arrowPoint: point)
    }
    
    fileprivate func repositionMenuTableView() {
        var menuRect : CGRect = CGRect(x: 0, y: DPDefaultMenuArrowHeight,
                                       width: self.frame.size.width,
                                       height: self.frame.size.height - DPDefaultMenuArrowHeight)
        if (arrowDirection == .down) {
            menuRect = CGRect(x: 0, y: 0,
                              width: self.frame.size.width,
                              height: self.frame.size.height - DPDefaultMenuArrowHeight)
        }
        self.menuTableView.frame = menuRect
        self.menuTableView.reloadData()
        if menuTableView.frame.height < configuration.menuRowHeight * CGFloat(dataSource?.count ?? 0) {
            self.menuTableView.isScrollEnabled = true
        } else {
            self.menuTableView.isScrollEnabled = false
        }
        self.addSubview(self.menuTableView)
    }
    
    fileprivate lazy var backgroundLayer : CAShapeLayer = {
        let layer : CAShapeLayer = CAShapeLayer()
        return layer
    }()
    
    fileprivate func drawBackgroundLayerWithArrowPoint(arrowPoint : CGPoint) {
        if self.backgroundLayer.superlayer != nil {
            self.backgroundLayer.removeFromSuperlayer()
        }
        backgroundLayer.path = self.getBackgroundPath(arrowPoint: arrowPoint).cgPath
        backgroundLayer.fillColor = configuration.backgoundTintColor.cgColor
        backgroundLayer.strokeColor = configuration.borderColor.cgColor
        backgroundLayer.lineWidth = configuration.borderWidth
        self.layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    func getBackgroundPath(arrowPoint : CGPoint) -> UIBezierPath {
        let radius : CGFloat = configuration.cornerRadius / 2
        
        let path : UIBezierPath = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        if (arrowDirection == .up) {
            path.move(to: CGPoint(x: arrowPoint.x - DPDefaultMenuArrowWidth,
                                  y: DPDefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
            path.addLine(to: CGPoint(x: arrowPoint.x + DPDefaultMenuArrowWidth,
                                     y: DPDefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: self.bounds.size.width - radius,
                                     y: DPDefaultMenuArrowHeight))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius,
                                            y: DPDefaultMenuArrowHeight + radius),
                        radius: radius,
                        startAngle: CGFloat((Double.pi / 2)*3),
                        endAngle: 0,
                        clockwise: true)
            path.addLine(to: CGPoint(x: self.bounds.size.width,
                                     y: self.bounds.size.height - radius))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius,
                                            y: self.bounds.size.height - radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: CGFloat((Double.pi / 2)),
                        clockwise: true)
            path.addLine(to: CGPoint(x: radius, y: self.bounds.size.height))
            path.addArc(withCenter: CGPoint(x: radius, y: self.bounds.size.height - radius),
                        radius: radius,
                        startAngle: CGFloat((Double.pi / 2)),
                        endAngle: CGFloat(Double.pi),
                        clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: DPDefaultMenuArrowHeight + radius))
            path.addArc(withCenter: CGPoint(x: radius, y: DPDefaultMenuArrowHeight + radius),
                        radius: radius,
                        startAngle: CGFloat(Double.pi),
                        endAngle: CGFloat((Double.pi / 2)*3),
                        clockwise: true)
            path.close()
        } else {
            path.move(to: CGPoint(x: arrowPoint.x - DPDefaultMenuArrowWidth,
                                  y: self.bounds.size.height - DPDefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: self.bounds.size.height))
            path.addLine(to: CGPoint(x: arrowPoint.x + DPDefaultMenuArrowWidth,
                                     y: self.bounds.size.height - DPDefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: self.bounds.size.width - radius,
                                     y: self.bounds.size.height - DPDefaultMenuArrowHeight))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius,
                                            y: self.bounds.size.height - DPDefaultMenuArrowHeight - radius),
                        radius: radius,
                        startAngle: CGFloat((Double.pi / 2)),
                        endAngle: 0,
                        clockwise: false)
            path.addLine(to: CGPoint(x: self.bounds.size.width, y: radius))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius, y: radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: CGFloat((Double.pi / 2)*3),
                        clockwise: false)
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addArc(withCenter: CGPoint(x: radius, y: radius),
                        radius: radius,
                        startAngle: CGFloat((Double.pi / 2)*3),
                        endAngle: CGFloat(Double.pi),
                        clockwise: false)
            path.addLine(to: CGPoint(x: 0,
                                     y: self.bounds.size.height - DPDefaultMenuArrowHeight - radius))
            path.addArc(withCenter: CGPoint(x: radius,
                                            y: self.bounds.size.height - DPDefaultMenuArrowHeight - radius),
                        radius: radius,
                        startAngle: CGFloat(Double.pi),
                        endAngle: CGFloat((Double.pi / 2)),
                        clockwise: false)
            path.close()
        }
        return path
    }
    
}

extension DPArrowMenuView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configuration.menuRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.done?(indexPath.row)
    }
    
}

extension DPArrowMenuView : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : DPPopOverMenuCell = DPPopOverMenuCell(style: .default,
                                                         reuseIdentifier: DPPopOverMenuTableViewCellIndentifier)
        if let arrowMenuViewModel: DPArrowMenuViewModel = self.dataSource?[indexPath.row] {
            cell.bindData(arrowMenuViewModel: arrowMenuViewModel)
        }
        if (indexPath.row == (dataSource?.count ?? 0) - 1) {
            cell.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0)
        } else {
            cell.separatorInset = configuration.menuSeparatorInset
        }
        return cell
    }
    
}
