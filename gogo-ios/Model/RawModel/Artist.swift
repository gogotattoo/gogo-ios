//
//  Artist.swift
//  gogo-ios
//
//  Created by Hongli Yu on 19/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import RealmSwift

class Artist: Object {
    
    dynamic var link: String = ""
    dynamic var name: String = ""
    dynamic var avatarIPFS: String = ""
    dynamic var joinDate: String = ""
    dynamic var birthDate: String = ""
    dynamic var experience: String = ""
    dynamic var about: String = ""
    dynamic var origin: String = ""
    dynamic var locationNow: String = ""
    let services: List<RealmString> = List<RealmString>()
    
    func mappingJSONData(_ json: AnyObject?) {
        if let jsonDic = json as? Dictionary<String, AnyObject> {
            self.link = (jsonDic["link"] as? String) ?? ""
            self.name = (jsonDic["name"] as? String) ?? ""
            self.avatarIPFS = (jsonDic["avatar_ipfs"] as? String) ?? ""
            self.joinDate = (jsonDic["join_date"] as? String) ?? ""
            self.birthDate = (jsonDic["birth_date"] as? String) ?? ""
            self.experience = (jsonDic["experience"] as? String) ?? ""
            self.about = (jsonDic["about"] as? String) ?? ""
            self.origin = (jsonDic["origin"] as? String) ?? ""
            self.locationNow = (jsonDic["location_now"] as? String) ?? ""
            self.services.append(objectsIn: ((jsonDic["services"] as? [String]) ?? []).map({ RealmString(value: [$0]) }))
        }
    }
    
    override static func primaryKey() -> String? {
        return "link"
    }
    
    override static func indexedProperties() -> [String] {
        return ["link"]
    }

}
