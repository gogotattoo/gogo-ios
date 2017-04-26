//
//  ArtWork.swift
//  gogo-ios
//
//  Created by Hongli Yu on 26/03/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import RealmSwift

class RealmString: Object {
    dynamic var stringValue = ""
}

class ArtWork: Object {
    
    dynamic var identifier: String = ""
    dynamic var link: String = ""
    dynamic var title: String = " sun"
    dynamic var madeDate: String = ""
    dynamic var date: String = ""
    let tags: List<RealmString> = List<RealmString>()
    let bodypart: List<RealmString> = List<RealmString>()
    dynamic var imageIPFS: String = ""
    let imagesIPFS: List<RealmString> = List<RealmString>()
    dynamic var madeAtCountry: String = "China"
    dynamic var madeAtCity: String = "Shanghai"
    dynamic var madeAtShop: String = "chushangfeng"
    dynamic var durationMin: Int = 120
    dynamic var gender: String = "female"
    dynamic var extra: String = ""
    
    // custom properties
    dynamic var artistType: String = ""
    dynamic var artistLink: String = ""
    dynamic var cellHeight: Float = 0
    
    func mappingJSONData(_ json: AnyObject?) {
        if let jsonDic = json as? Dictionary<String, AnyObject> {
            self.identifier = (jsonDic["id"] as? String) ?? ""
            self.link = (jsonDic["link"] as? String) ?? ""
            self.title = (jsonDic["title"] as? String) ?? ""
            self.madeDate = (jsonDic["made_date"] as? String) ?? ""
            self.date = (jsonDic["date"] as? String) ?? ""
            self.tags.append(objectsIn: ((jsonDic["tags"] as? [String]) ?? []).map({ RealmString(value: [$0]) }))
            self.bodypart.append(objectsIn: ((jsonDic["bodypart"] as? [String]) ?? []).map({ RealmString(value: [$0]) }))
            self.imageIPFS = (jsonDic["image_ipfs"] as? String) ?? ""
            self.imagesIPFS.append(objectsIn: ((jsonDic["images_ipfs"] as? [String]) ?? []).map({ RealmString(value: [$0]) }))
            self.madeAtCountry = (jsonDic["made_at_country"] as? String) ?? ""
            self.madeAtCity = (jsonDic["made_at_city"] as? String) ?? ""
            self.madeAtShop = (jsonDic["made_at_shop"] as? String) ?? ""
            self.durationMin = (jsonDic["duration_min"] as? Int) ?? 0
            self.gender = (jsonDic["gender"] as? String) ?? ""
            self.extra = (jsonDic["extra"] as? String) ?? ""
        }
    }
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    override static func indexedProperties() -> [String] {
        return ["identifier"]
    }
    
}
