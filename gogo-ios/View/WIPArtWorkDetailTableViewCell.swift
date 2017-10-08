//
//  WIPArtWorkDetailTableViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 11/05/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Nuke

class WIPArtWorkDetailTableViewCell: UITableViewCell {
  
  @IBOutlet weak var artWorkImageView: UIImageView!
  fileprivate var imageIPFS: String?
  var imageDownloadCompleteCallBack:(()->Void)?
  
  func bindData(imageIPFS: String) {
    self.imageIPFS = imageIPFS
    let imageURLString = Constant.Network.imageHost + imageIPFS
    Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
      (result) in
      guard let image = result.value else { return }
      // resize image view, based on the coming image size, need optimize
      let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
      let proportion = image.size.width / imageWidth
      let imageHeight = image.size.height / proportion
      let retSize = CGSize(width: imageWidth, height: imageHeight)
      let resizedAndMaskedImage = image.scaleImageToFitSize(size: retSize)
      self.artWorkImageView.image = resizedAndMaskedImage
      self.imageDownloadCompleteCallBack?()
    }
  }
  
}
