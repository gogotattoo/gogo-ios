//
//  DPPopOverMenuCell.swift
//  DPArrowMenu
//
//  Created by Hongli Yu on 19/01/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class DPPopOverMenuCell: UITableViewCell {
    
    var arrowMenuViewModel: DPArrowMenuViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    fileprivate lazy var configuration : DPConfiguration = DPConfiguration.sharedInstance
    fileprivate lazy var iconImageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    fileprivate lazy var nameLabel : UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.backgroundColor = UIColor.clear
        self.contentView.addSubview(label)
        return label
    }()
    
    func bindData(arrowMenuViewModel: DPArrowMenuViewModel) {
        self.arrowMenuViewModel = arrowMenuViewModel
        self.backgroundColor = UIColor.clear
        
        var iconImage: UIImage?
        if arrowMenuViewModel.image != nil {
            iconImage = arrowMenuViewModel.image
        } else if arrowMenuViewModel.imageName != nil {
            iconImage = UIImage(named: arrowMenuViewModel.imageName ?? "")
        }
        
        if var iconImage = iconImage {
            if  configuration.ignoreImageOriginalColor {
                iconImage = iconImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            }
            iconImageView.tintColor = configuration.textColor
            iconImageView.frame =  CGRect(x: DPDefaultCellMargin, y: (configuration.menuRowHeight - DPDefaultMenuIconSize)/2,
                                          width: DPDefaultMenuIconSize, height: DPDefaultMenuIconSize)
            iconImageView.image = iconImage
            nameLabel.frame = CGRect(x: DPDefaultCellMargin*2 + DPDefaultMenuIconSize,
                                     y: (configuration.menuRowHeight - DPDefaultMenuIconSize)/2,
                                     width: (configuration.menuWidth - DPDefaultMenuIconSize - DPDefaultCellMargin*3),
                                     height: DPDefaultMenuIconSize)
        } else {
            nameLabel.frame = CGRect(x: DPDefaultCellMargin, y: 0,
                                     width: configuration.menuWidth - DPDefaultCellMargin*2,
                                     height: configuration.menuRowHeight)
        }
        
        nameLabel.font = configuration.textFont
        nameLabel.textColor = configuration.textColor
        nameLabel.textAlignment = configuration.textAlignment
        nameLabel.text = arrowMenuViewModel.title
    }
    
}
