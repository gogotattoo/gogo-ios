//
//  Artist.swift
//  gogo-ios
//
//  Created by Hongli Yu on 19/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import RealmSwift

class Artist: Object, NSCopying {
  
  @objc dynamic var link: String = ""
  @objc dynamic var name: String = ""
  @objc dynamic var avatarIPFS: String = ""
  @objc dynamic var joinDate: String = ""
  @objc dynamic var birthDate: String = ""
  @objc dynamic var experience: String = ""
  @objc dynamic var about: String = ""
  @objc dynamic var origin: String = ""
  @objc dynamic var locationNow: String = ""
  @objc dynamic var currentStudio: String = ""
  
  let services: List<RealmString> = List<RealmString>()
  
  func mappingJSONData(_ json: Any?) {
    if let jsonDic = json as? Dictionary<String, Any> {
      self.link = (jsonDic["link"] as? String) ?? ""
      self.name = (jsonDic["name"] as? String) ?? ""
      self.avatarIPFS = (jsonDic["avatar_ipfs"] as? String) ?? ""
      self.joinDate = (jsonDic["join_date"] as? String) ?? ""
      self.birthDate = (jsonDic["birth_date"] as? String) ?? ""
      self.experience = (jsonDic["experience"] as? String) ?? ""
      self.about = (jsonDic["about"] as? String) ?? ""
      self.origin = (jsonDic["origin"] as? String) ?? ""
      self.locationNow = (jsonDic["location_now"] as? String) ?? ""
      self.currentStudio = (jsonDic["current_studio"] as? String) ?? ""
      self.services.append(objectsIn: ((jsonDic["services"] as? [String]) ?? []).map({ RealmString(value: [$0]) }))
    }
  }
  
  override static func primaryKey() -> String? {
    return "link"
  }
  
  override static func indexedProperties() -> [String] {
    return ["link"]
  }
  
  internal func copy(with zone: NSZone?) -> Any {
    let value = Artist()
    value.link = self.link
    value.name = self.name
    value.avatarIPFS = self.avatarIPFS
    value.joinDate = self.joinDate
    value.birthDate = self.birthDate
    value.experience = self.experience
    value.about = self.about
    value.origin = self.origin
    value.locationNow = self.locationNow
    value.currentStudio = self.currentStudio
    for service in self.services {
      value.services.append(service)
    }
    return value
  }
  
}
