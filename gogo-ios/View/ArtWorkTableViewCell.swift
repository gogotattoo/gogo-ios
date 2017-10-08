//
//  ArtWorkTableViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 20/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Nuke

let kArtWorkTableViewCellReuseID = "ArtWorkTableViewCell"

class ArtWorkTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var artWorkImageView: UIImageView!
  
  var currentArtWorkViewModel: Any?
  var imageDownloadCompleteCallBack:(()->Void)?
  var imageDownloaded: Bool = false
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func bindData(artWorkViewModel: Any) {
    // TODO: optimiaze the logic
    switch MainManager.sharedInstance.currentArtType {
    case .artwork:
      break
    case .tattoo:
      if !(artWorkViewModel is TattooViewModel) { return }
      self.currentArtWorkViewModel = artWorkViewModel
      self.imageDownloaded = false
      if (self.currentArtWorkViewModel as! TattooViewModel).cellHeight != 0 {
        self.imageDownloaded = true
      } else {
        self.artWorkImageView.image = nil
      }
      self.titleLabel.text = (artWorkViewModel as! TattooViewModel).title
      let imageURLString = Constant.Network.imageHost + (artWorkViewModel as! TattooViewModel).imageIPFS
      Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
        (result) in
        guard let image = result.value else { return }
        // resize image view, based on the coming image size, need optimize
        let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
        let proportion = image.size.width / imageWidth
        let imageHeight = image.size.height / proportion
        if !(self.currentArtWorkViewModel is TattooViewModel) { return }
        if (self.currentArtWorkViewModel as! TattooViewModel).cellHeight == 0
          || (self.currentArtWorkViewModel as! TattooViewModel).cellHeight != (imageHeight + 48) {
          (self.currentArtWorkViewModel as! TattooViewModel).setCellHeight(cellHeight: imageHeight + 48)
          self.imageDownloaded = false
        }
        let retSize = CGSize(width: imageWidth, height: imageHeight)
        let retImage = image.scaleImageToFitSize(size: retSize)
        self.artWorkImageView.image = retImage
        if !self.imageDownloaded {
          self.imageDownloaded = true
          self.imageDownloadCompleteCallBack?()
        }
      }
      break
    case .henna:
      if !(artWorkViewModel is HennaViewModel) { return }
      self.currentArtWorkViewModel = artWorkViewModel
      self.imageDownloaded = false
      if (self.currentArtWorkViewModel as! HennaViewModel).cellHeight != 0 {
        self.imageDownloaded = true
      } else {
        self.artWorkImageView.image = nil
      }
      self.titleLabel.text = (artWorkViewModel as! HennaViewModel).title
      let imageURLString = Constant.Network.imageHost + (artWorkViewModel as! HennaViewModel).imageIPFS
      Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
        (result) in
        guard let image = result.value else { return }
        // resize image view, based on the coming image size, need optimize
        let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
        let proportion = image.size.width / imageWidth
        let imageHeight = image.size.height / proportion
        if !(self.currentArtWorkViewModel is HennaViewModel) { return }
        if (self.currentArtWorkViewModel as! HennaViewModel).cellHeight == 0
          || (self.currentArtWorkViewModel as! HennaViewModel).cellHeight != (imageHeight + 48) {
          (self.currentArtWorkViewModel as! HennaViewModel).setCellHeight(cellHeight: imageHeight + 48)
          self.imageDownloaded = false
        }
        let retSize = CGSize(width: imageWidth, height: imageHeight)
        let retImage = image.scaleImageToFitSize(size: retSize)
        self.artWorkImageView.image = retImage
        if !self.imageDownloaded {
          self.imageDownloaded = true
          self.imageDownloadCompleteCallBack?()
        }
      }
      break
    case .piercing:
      if !(artWorkViewModel is PiercingViewModel) { return }
      self.currentArtWorkViewModel = artWorkViewModel
      self.imageDownloaded = false
      if (self.currentArtWorkViewModel as! PiercingViewModel).cellHeight != 0 {
        self.imageDownloaded = true
      } else {
        self.artWorkImageView.image = nil
      }
      self.titleLabel.text = (artWorkViewModel as! PiercingViewModel).title
      let imageURLString = Constant.Network.imageHost + (artWorkViewModel as! PiercingViewModel).imageIPFS
      Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
        (result) in
        guard let image = result.value else { return }
        // resize image view, based on the coming image size, need optimize
        let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
        let proportion = image.size.width / imageWidth
        let imageHeight = image.size.height / proportion
        if !(self.currentArtWorkViewModel is PiercingViewModel) { return }
        if (self.currentArtWorkViewModel as! PiercingViewModel).cellHeight == 0
          || (self.currentArtWorkViewModel as! PiercingViewModel).cellHeight != (imageHeight + 48) {
          (self.currentArtWorkViewModel as! PiercingViewModel).setCellHeight(cellHeight: imageHeight + 48)
          self.imageDownloaded = false
        }
        let retSize = CGSize(width: imageWidth, height: imageHeight)
        let retImage = image.scaleImageToFitSize(size: retSize)
        self.artWorkImageView.image = retImage
        if !self.imageDownloaded {
          self.imageDownloaded = true
          self.imageDownloadCompleteCallBack?()
        }
      }
      break
    case .design:
      if !(artWorkViewModel is DesignViewModel) { return }
      self.currentArtWorkViewModel = artWorkViewModel
      self.imageDownloaded = false
      if (self.currentArtWorkViewModel as! DesignViewModel).cellHeight != 0 {
        self.imageDownloaded = true
      } else {
        self.artWorkImageView.image = nil
      }
      self.titleLabel.text = (artWorkViewModel as! DesignViewModel).title
      let imageURLString = Constant.Network.imageHost + (artWorkViewModel as! DesignViewModel).imageIPFS
      Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
        (result) in
        guard let image = result.value else { return }
        // resize image view, based on the coming image size, need optimize
        let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
        let proportion = image.size.width / imageWidth
        let imageHeight = image.size.height / proportion
        if !(self.currentArtWorkViewModel is DesignViewModel) { return }
        if (self.currentArtWorkViewModel as! DesignViewModel).cellHeight == 0
          || (self.currentArtWorkViewModel as! DesignViewModel).cellHeight != (imageHeight + 48) {
          (self.currentArtWorkViewModel as! DesignViewModel).setCellHeight(cellHeight: imageHeight + 48)
          self.imageDownloaded = false
        }
        let retSize = CGSize(width: imageWidth, height: imageHeight)
        let retImage = image.scaleImageToFitSize(size: retSize)
        self.artWorkImageView.image = retImage
        if !self.imageDownloaded {
          self.imageDownloaded = true
          self.imageDownloadCompleteCallBack?()
        }
      }
      break
    case .dreadlocks:
      if !(artWorkViewModel is DreadlocksViewModel) { return }
      self.currentArtWorkViewModel = artWorkViewModel
      self.imageDownloaded = false
      if (self.currentArtWorkViewModel as! DreadlocksViewModel).cellHeight != 0 {
        self.imageDownloaded = true
      } else {
        self.artWorkImageView.image = nil
      }
      self.artWorkImageView.image = nil
      
      self.titleLabel.text = (artWorkViewModel as! DreadlocksViewModel).title
      let imageURLString = Constant.Network.imageHost + (artWorkViewModel as! DreadlocksViewModel).imageIPFS
      Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
        (result) in
        guard let image = result.value else { return }
        // resize image view, based on the coming image size, need optimize
        let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
        let proportion = image.size.width / imageWidth
        let imageHeight = image.size.height / proportion
        if !(self.currentArtWorkViewModel is DreadlocksViewModel) { return }
        if (self.currentArtWorkViewModel as! DreadlocksViewModel).cellHeight == 0
          || (self.currentArtWorkViewModel as! DreadlocksViewModel).cellHeight != (imageHeight + 48) {
          (self.currentArtWorkViewModel as! DreadlocksViewModel).setCellHeight(cellHeight: imageHeight + 48)
          self.imageDownloaded = false
        }
        let retSize = CGSize(width: imageWidth, height: imageHeight)
        let retImage = image.scaleImageToFitSize(size: retSize)
        self.artWorkImageView.image = retImage
        if !self.imageDownloaded {
          self.imageDownloaded = true
          self.imageDownloadCompleteCallBack?()
        }
      }
      break
    }
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func resize(image: UIImage, toSize size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size,false,1.0)
    image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    if let resizedImage = UIGraphicsGetImageFromCurrentImageContext() {
      UIGraphicsEndImageContext()
      return resizedImage
    }
    UIGraphicsEndImageContext()
    return image
  }
  
}
