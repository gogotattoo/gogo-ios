//
//  ArtistCollectionViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 19/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Nuke

let kArtistCollectionViewCellReuseID = "ArtistCollectionViewCell"

class ArtistCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var avatarImageView: UIImageView!
  fileprivate var artistViewModel: ArtistViewModel?
  
  // MARK: Life Cycle
  override func awakeFromNib() {
    super.awakeFromNib()
    self.basicUI()
  }
  
  // MARK: UI
  func basicUI() {
    self.avatarImageView.layoutIfNeeded()
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.width / 2.0
    self.avatarImageView.layer.masksToBounds = true
    self.avatarImageView.image = UIImage(named: "place_holder")
  }
  
  func updateUI() {
    guard let artistViewModel = self.artistViewModel else { return }
    if artistViewModel.selectedArtist {
      self.avatarImageView.layer.borderWidth = 2
      self.avatarImageView.layer.borderColor = Palette.persianGreen.cgColor
    } else {
      self.avatarImageView.layer.borderWidth = 0
      self.avatarImageView.layer.borderColor = UIColor.clear.cgColor
    }
  }
  
  // MARK: React
  func bindData(_ artistViewModel: ArtistViewModel) {
    self.artistViewModel = artistViewModel
    let imageURLString = Constant.Network.imageHost + artistViewModel.avatarIPFS
    if let url = URL(string: imageURLString) {
      Manager.shared.loadImage(with: Request(url: url)) {
        (result) in
        if let image = result.value {
          self.avatarImageView.image = image
        } else {
          self.avatarImageView.image = UIImage(named: "place_holder")
        }
      }
      self.updateUI()
    }
  }
  
}
