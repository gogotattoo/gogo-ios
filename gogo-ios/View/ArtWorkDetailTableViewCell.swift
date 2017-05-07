//
//  ArtWorkDetailTableViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 26/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Nuke
import Toucan
import NukeToucanPlugin

class ArtWorkDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var artWorkImageView: UIImageView!
    var imageIPFS: String?
    var imageDownloadCompleteCallBack:(()->Void)?
    var imageDownloaded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindData(imageIPFS: String, index: Int) {
        let imageURLString = Constant.Network.imageHost + imageIPFS
        Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
            (result) in
            let image = result.value
            if image == nil { return }
            // resize image view, based on the coming image size, need optimize
            let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
            let proportion = image!.size.width / imageWidth
            let imageHeight = image!.size.height / proportion
            let resizedAndMaskedImage = Toucan(image: image!).resize(CGSize(width: imageWidth, height: imageHeight)).image
            if MainManager.sharedInstance.artWorkDetailCellHeightArray[index] != imageHeight {
                MainManager.sharedInstance.artWorkDetailCellHeightArray[index] = imageHeight
                self.imageDownloaded = false
            }
            self.artWorkImageView.image = resizedAndMaskedImage
            if !self.imageDownloaded {
                self.imageDownloaded = true
                self.imageDownloadCompleteCallBack?()
            }
        }
    }
    
}
