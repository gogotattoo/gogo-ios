//
//  Constant.swift
//  gogo-ios
//
//  Created by Hongli Yu on 16/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation

let kNavgiationBackGroundHeightConstraintiPhoneX: CGFloat = 90.0
let kNavgiationBackGroundHeightConstraintNormal: CGFloat = 64.0

struct Constant {
  
  struct Network {
    enum MainHost: String {
      case Development = "http://api.gogo.tattoo:123456"
      case Production = "http://api.gogo.tattoo:12345"
      case ProductionIP = "http://66.172.12.143:12345"
    }
    #if DEBUG
    static let host = MainHost.ProductionIP
    #else
    static let host = MainHost.Production
    #endif
    static let imageHost = "https://gateway.ipfs.io/ipfs/"
  }
  
}
