//
//  WIPArtWorkDetailTableViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 11/05/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Nuke
import Toucan
import NukeToucanPlugin

class WIPArtWorkDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artWorkImageView: UIImageView!
    fileprivate var imageIPFS: String?
    var imageDownloadCompleteCallBack:(()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(imageIPFS: String) {
        self.imageIPFS = imageIPFS
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
            self.artWorkImageView.image = resizedAndMaskedImage
            self.imageDownloadCompleteCallBack?()
        }
    }
    
}
