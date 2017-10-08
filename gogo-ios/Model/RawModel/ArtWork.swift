//
//  ArtWork.swift
//  gogo-ios
//
//  Created by Hongli Yu on 26/03/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import RealmSwift

class RealmString: Object, NSCopying {
  
  @objc dynamic var stringValue = ""
  internal func copy(with zone: NSZone?) -> Any {
    let value = RealmString()
    value.stringValue = self.stringValue
    return value
  }
  
}

class ArtWork: Object, NSCopying {
  
  @objc dynamic var identifier: String = ""
  @objc dynamic var link: String = ""
  @objc dynamic var title: String = ""
  @objc dynamic var madeDate: String = ""
  @objc dynamic var date: String = ""
  @objc dynamic var imageIPFS: String = ""
  @objc dynamic var madeAtCountry: String = ""
  @objc dynamic var madeAtCity: String = ""
  @objc dynamic var madeAtShop: String = ""
  @objc dynamic var durationMin: Int = 0
  @objc dynamic var gender: String = ""
  @objc dynamic var extra: String = ""
  @objc dynamic var blockChain: BlockChain?

  let tags: List<RealmString> = List<RealmString>()
  let bodypart: List<RealmString> = List<RealmString>()
  let imagesIPFS: List<RealmString> = List<RealmString>()
  let videosIPFS: List<RealmString> = List<RealmString>()

  // custom properties
  @objc dynamic var artType: String = ""
  @objc dynamic var artistLink: String = ""
  @objc dynamic var cellHeight: Float = 0
  
  func mappingJSONData(_ json: Any?) {
    if let jsonDic = json as? Dictionary<String, Any> {
      self.identifier = (jsonDic["id"] as? String) ?? ""
      self.link = (jsonDic["link"] as? String) ?? ""
      self.title = (jsonDic["title"] as? String) ?? ""
      self.madeDate = (jsonDic["made_date"] as? String) ?? ""
      self.date = (jsonDic["date"] as? String) ?? ""
      self.imageIPFS = (jsonDic["image_ipfs"] as? String) ?? ""
      self.tags.append(objectsIn: ((jsonDic["tags"] as? [String]) ?? []).map({ RealmString(value: [$0]) }))
      self.bodypart.append(objectsIn: ((jsonDic["bodypart"] as? [String]) ?? []).map({ RealmString(value: [$0]) }))
      self.imagesIPFS.append(objectsIn: ((jsonDic["images_ipfs"] as? [String]) ?? []).map({ RealmString(value: [$0]) }))
      self.videosIPFS.append(objectsIn: ((jsonDic["videos_ipfs"] as? [String]) ?? []).map({ RealmString(value: [$0]) }))
      self.madeAtCountry = (jsonDic["made_at_country"] as? String) ?? ""
      self.madeAtCity = (jsonDic["made_at_city"] as? String) ?? ""
      self.madeAtShop = (jsonDic["made_at_shop"] as? String) ?? ""
      self.durationMin = (jsonDic["duration_min"] as? Int) ?? 0
      self.gender = (jsonDic["gender"] as? String) ?? ""
      self.extra = (jsonDic["extra"] as? String) ?? ""
      if let jsonDic = jsonDic["blockchain"] as? Dictionary<String, Any> {
        self.blockChain = BlockChain()
        self.blockChain?.mappingJSONData(jsonDic)
      }
    }
  }
  
  override static func primaryKey() -> String? {
    return "identifier"
  }
  
  override static func indexedProperties() -> [String] {
    return ["identifier"]
  }
  
  internal func copy(with zone: NSZone?) -> Any {
    let value = ArtWork()
    value.identifier = self.identifier
    value.link = self.link
    value.title = self.title
    value.madeDate = self.madeDate
    value.date = self.date
    value.imageIPFS = self.imageIPFS
    value.madeAtCountry = self.madeAtCountry
    value.madeAtCity = self.madeAtCity
    value.madeAtShop = self.madeAtShop
    value.durationMin = self.durationMin
    value.gender = self.gender
    value.extra = self.extra
    if let blockChain = self.blockChain?.copy() as? BlockChain {
      self.blockChain = blockChain
    }
    for tag in self.tags {
      let realmString = RealmString()
      realmString.stringValue = tag.stringValue
      value.tags.append(realmString)
    }
//    value.tags.append(objectsIn: (self.tags.copy()).map({ RealmString(value: [$0]) }))
//    value.bodypart.append(objectsIn: (self.bodypart).map({ RealmString(value: [$0]).copy() }))
//    value.imagesIPFS.append(objectsIn: (self.imagesIPFS).map({ RealmString(value: [$0]).copy() }))
//    value.videosIPFS.append(objectsIn: (self.videosIPFS).map({ RealmString(value: [$0]).copy() }))
    return value
  }

}
