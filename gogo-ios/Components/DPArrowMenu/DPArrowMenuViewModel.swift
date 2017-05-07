//
//  DPArrowMenuViewModel.swift
//  DPArrowMenu
//
//  Created by Hongli Yu on 19/01/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation

class DPArrowMenuViewModel {
    
    var title: String?
    var imageName: String?
    var image: UIImage?

    init(title: String, imageName: String?, image: UIImage?) {
        self.title = title
        self.imageName = imageName
        self.image = image
    }
    
}
