//
//  QRCodeTableViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 27/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import QRCode

class QRCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var QRImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindData(urlString: String, index: Int) {
        
        self.urlLabel.text = urlString
        let qrCode = QRCode(urlString)
        self.QRImageView.image = qrCode?.image
        MainManager.sharedInstance.artWorkDetailCellHeightArray[index] = 380
        
    }
    
}
