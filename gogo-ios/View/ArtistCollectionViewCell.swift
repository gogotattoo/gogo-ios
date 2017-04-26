//
//  ArtistCollectionViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 19/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class ArtistCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImageView.layoutIfNeeded()
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.width / 2
        self.avatarImageView.layer.masksToBounds = true
    }
    
}
