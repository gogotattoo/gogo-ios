//
//  ArtistCollectionViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 19/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Nuke

class ArtistCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    fileprivate var artistViewModel: ArtistViewModel?
    var longPressActionCallBack:(()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImageView.layoutIfNeeded()
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.width / 2
        self.avatarImageView.layer.masksToBounds = true
        let longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                                                    action: #selector(self.handleLongPress(sender:)))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc fileprivate func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            if self.artistViewModel != nil {
                self.artistViewModel!.setSelectedArtist(selectedArtist: true)
                MainManager.sharedInstance.uploadArtistName = self.artistViewModel!.link
            }
            self.updateUI()
            self.longPressActionCallBack?()
        }
    }
    
    func bindData(artistViewModel: ArtistViewModel) {
        self.artistViewModel = artistViewModel
        if artistViewModel.avatarIPFS == "" {
            self.avatarImageView.image = UIImage(named: "DemoPic")
        } else {
            let imageURLString = Constant.Network.imageHost + artistViewModel.avatarIPFS
            Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
                (result) in
                let image = result.value
                self.avatarImageView.image = image
            }
        }
        self.updateUI()
    }
    
    func updateUI() {
        if self.artistViewModel == nil { return }
        if self.artistViewModel!.selectedArtist {
            self.avatarImageView.layer.borderWidth = 2
            self.avatarImageView.layer.borderColor = Palette.persianGreen.cgColor
        } else {
            self.avatarImageView.layer.borderWidth = 0
            self.avatarImageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
}
