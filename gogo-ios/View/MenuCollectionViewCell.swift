//
//  MenuCollectionViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 04/10/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

let kMenuCollectionViewCellReuseID = "MenuCollectionViewCell"

class MenuCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  // MARK: Life Cycle
  override func awakeFromNib() {
    super.awakeFromNib()
    self.basicUI()
  }
  
  // MARK: UI
  func basicUI() {
    self.backgroundColor = UIColor.clear
  }
  
  // MARK: React
  func bindData(index: Int, text: String) {
    self.titleLabel.text = text
//    if index == MainManager.sharedInstance.selectedIndex {
//      self.titleLabel.textColor = UIColor.white
//    } else {
//      self.titleLabel.textColor = UIColor.lightGray
//    }
  }
  
}

