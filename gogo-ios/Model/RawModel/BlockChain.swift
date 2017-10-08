//
//  BlockChain.swift
//  gogo-ios
//
//  Created by Hongli Yu on 07/10/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import RealmSwift

class BlockChain: Object, NSCopying {
  
  @objc dynamic var steem: String = ""
  @objc dynamic var golos: String = ""
  
  func mappingJSONData(_ json: Any?) {
    if let jsonDic = json as? Dictionary<String, Any> {
      self.steem = (jsonDic["steem"] as? String) ?? ""
      self.golos = (jsonDic["golos"] as? String) ?? ""
    }
  }
  
  override static func primaryKey() -> String? {
    return "steem"
  }
  
  override static func indexedProperties() -> [String] {
    return ["steem"]
  }
  
  internal func copy(with zone: NSZone?) -> Any {
    let value = BlockChain()
    value.steem = self.steem
    value.golos = self.golos
    return value
  }

}
