//
//  ArtistViewModel.swift
//  gogo-ios
//
//  Created by Hongli Yu on 16/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import SwiftDate

class ArtistViewModel {
    
    fileprivate var artist: Artist = Artist()

    fileprivate(set) var link: String = ""
    fileprivate(set) var name: String = ""
    fileprivate(set) var avatarIPFS: String = ""
    fileprivate(set) var joinDate: Date = Date()
    fileprivate(set) var birthDate: Date = Date()
    fileprivate(set) var experience: String = ""
    fileprivate(set) var about: String = ""
    fileprivate(set) var origin: String = ""
    fileprivate(set) var locationNow: String = ""
    fileprivate(set) var services: [String] = []
    
    // MARK: Properties Setter
    
    // MARK: Life Cycle
    required init() {
        
    }
    
    init(json: AnyObject?) {
        self.artist = Artist()
        self.artist.mappingJSONData(json)
        self.syncModelToViewModel()
    }
    
    init(artist: Artist?) {
        if artist != nil {
            self.artist = artist!
            self.syncModelToViewModel()
        }
    }
    
    func mappingJSONData(_ json: AnyObject?) {
        self.artist.mappingJSONData(json)
    }
    
    func fetchArtist() -> Artist {
        self.syncViewModelToModel()
        return self.artist
    }

}
// MARK: - CustomStringConvertible
extension ArtistViewModel: CustomStringConvertible {
    
    public var description : String {
        return "link: \(self.link), title: \(name) \n"
    }
    
}

// MARK: - Hashable
extension ArtistViewModel: Hashable {
    
    var hashValue : Int {
        get {
            return (self.link.hashValue)
        }
    }
    
}

// MARK: - Copyable
extension ArtistViewModel: Copyable {
    
    func copy() -> Self {
        let result = type(of: self).init()
        result.artist = self.artist
        
        result.link = self.link
        result.name = self.name
        result.avatarIPFS = self.avatarIPFS
        result.joinDate = self.joinDate
        result.birthDate = self.birthDate
        result.experience = self.experience
        result.about = self.about
        result.origin = self.origin
        result.locationNow = self.locationNow
        result.services = self.services
        return result
    }
    
}

// MARK: - Realmable
extension ArtistViewModel: Realmable {
    
    func syncViewModelToModel() {
        self.artist = Artist()
        
        self.artist.link = self.link
        self.artist.name = self.name
        self.artist.avatarIPFS = self.avatarIPFS
        self.artist.joinDate = self.joinDate.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.artist.birthDate = self.birthDate.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        self.artist.experience = self.experience
        self.artist.about = self.about
        self.artist.origin = self.origin
        self.artist.locationNow = self.locationNow
        self.artist.services.append(objectsIn: (self.services).map({ RealmString(value: [$0]) }))
    }
    
    func syncModelToViewModel() {
        self.link = self.artist.link
        self.name = self.artist.name
        self.avatarIPFS = self.artist.avatarIPFS
        if let date = self.artist.joinDate.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.joinDate = date
        }
        if let date = self.artist.birthDate.date(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))?.absoluteDate {
            self.birthDate = date
        }
        self.experience = self.artist.experience
        self.about = self.artist.about
        self.origin = self.artist.origin
        self.locationNow = self.artist.locationNow
        for service: RealmString in self.artist.services {
            self.services.append(service.stringValue)
        }
    }
    
}

extension ArtistViewModel: Equatable {
    
    static func ==(lhs: ArtistViewModel, rhs: ArtistViewModel) -> Bool {
        return lhs.link == rhs.link
    }

}
