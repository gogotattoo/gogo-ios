//
//  DataManager.swift
//  gogo-ios
//
//  Created by Hongli Yu on 16/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation

class DataManager {
    
    var dbRoot: DBRoot = DBRoot()
    var networkService: NetworkService = NetworkService()
    var dataQueue: DispatchQueue = DispatchQueue(label: "tattoo.gogo.datamanager",
                                                 attributes: DispatchQueue.Attributes.concurrent)
    var artistViewModels: Array<ArtistViewModel>?
    var artWorkViewModels: Array<AnyObject>?
    
    // MARK: Artist
    func requestArtistList(completion: @escaping (_ result: Array<ArtistViewModel>?, _ error: NSError?)->()?) {
        self.dataQueue.async {
            // db select
            self.dbRoot.selectArtists { [weak self] (result, error) -> Void in
                guard let strongSelf = self else { return }
                if error != nil {
                    strongSelf.dataQueue.async {
                        completion(nil, error)
                    }
                    return
                }
                if result != nil {
                    strongSelf.artistViewModels = result!
                }
                strongSelf.dataQueue.async {
                    // net work
                    completion(strongSelf.artistViewModels, nil)
                    let path = "/artists"
                    strongSelf.networkService.request(path, parameters: nil) {
                        [weak strongSelf] (result, error) -> Void in
                        guard let strongSelf = strongSelf else { return }
                        strongSelf.dataQueue.async {
                            if error != nil {
                                completion(nil, error!)
                                return
                            }
                            if result != nil {
                                strongSelf.parseDataToArtists(result)
                            }
                            // db insert
                            strongSelf.insertArtists({
                                [weak strongSelf] (result, error) -> Void in
                                guard let strongSelf = strongSelf else { return }
                                strongSelf.dataQueue.async {
                                    // data from server, call back after operation, do not care about success
                                    completion(strongSelf.artistViewModels, nil)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func parseDataToArtists(_ result: AnyObject?) {
        let retArray = (result as? NSArray) as Array?
        if retArray == nil { return }
        self.artistViewModels = []
        for jsonData in retArray! {
            let artistViewModel: ArtistViewModel = ArtistViewModel(json: jsonData)
            if !self.artistViewModels!.contains(artistViewModel) {
                self.artistViewModels!.append(artistViewModel)
            } else {
                let index: Int = self.artistViewModels!.index(of: artistViewModel)! // force to update
                self.artistViewModels![index] = artistViewModel
            }
        }
        self.artistViewModels!.sort(by: { $0.link > $1.link })
    }
    
    func insertArtists(_ completion: @escaping (_ result: Bool, _ error: NSError?)->()?) {
        self.dbRoot.insertArtists(self.artistViewModels, completion: {
            (result, error) -> Void in
            if error != nil {
                #if DEBUG
//                    print("insertArtists failed!!!")
                #endif
            }
            if result == true {
                #if DEBUG
//                     print("insertArtists done!!!")
                #endif
            }
            completion(result, error)
        })
    }
    
    // MARK: ArtWork
    func requestArtWorkList(_ artist: String, artistType: ArtistType, artistLink: String,
                            completion: @escaping (_ result: Array<AnyObject>?, _ error: NSError?)->()?) {
        self.dataQueue.async {
            // db select
            self.dbRoot.selectArtWorks(artistType: artistType,
                                       artistLink: artistLink) { [weak self] (result, error) -> Void in
                guard let strongSelf = self else { return }
                if error != nil {
                    strongSelf.dataQueue.async {
                        completion(nil, error)
                    }
                    return
                }
                if result != nil {
                    strongSelf.artWorkViewModels = result!
                } else {
                    strongSelf.artWorkViewModels = nil
                }
                strongSelf.dataQueue.async {
                    // net work
                    completion(strongSelf.artWorkViewModels, nil)
                    let path = "/\(artist)/\(artistType.rawValue)"
                    strongSelf.networkService.request(path, parameters: nil) {
                        [weak strongSelf] (result, error) -> Void in
                        guard let strongSelf = strongSelf else { return }
                        strongSelf.dataQueue.async {
                            if error != nil {
                                completion(nil, error!)
                                return
                            }
                            if result != nil {
                                strongSelf.parseDataToArtworks(result, artistType: artistType)
                                completion(strongSelf.artWorkViewModels, nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func parseDataToArtworks(_ result: AnyObject?, artistType: ArtistType) {
        let retArray = (result as? NSArray) as Array?
        if retArray == nil { return }
        if self.artWorkViewModels == nil {
            self.artWorkViewModels = []
        }
        
        switch artistType {
        case .tattoo:
            var artWorkViewModels = self.artWorkViewModels as? Array<TattooViewModel>
            if artWorkViewModels == nil { return }
            for jsonData in retArray! {
                let tattooViewModel: TattooViewModel = TattooViewModel(json: jsonData)
                if !artWorkViewModels!.contains(tattooViewModel) {
                    artWorkViewModels!.append(tattooViewModel)
                } else {
                    let index: Int = artWorkViewModels!.index(of: tattooViewModel)! // force to update
                    tattooViewModel.setCellHeight(cellHeight: artWorkViewModels![index].cellHeight)
                    self.artWorkViewModels![index] = tattooViewModel
                }
            }
            self.artWorkViewModels = artWorkViewModels!.sorted(by: { $0.date > $1.date })
            break
        case .henna:
            var artWorkViewModels = self.artWorkViewModels as? Array<HennaViewModel>
            if artWorkViewModels == nil { return }
            for jsonData in retArray! {
                let hennaViewModel: HennaViewModel = HennaViewModel(json: jsonData)
                if !artWorkViewModels!.contains(hennaViewModel) {
                    artWorkViewModels!.append(hennaViewModel)
                } else {
                    let index: Int = artWorkViewModels!.index(of: hennaViewModel)! // force to update
                    hennaViewModel.setCellHeight(cellHeight: artWorkViewModels![index].cellHeight)
                    self.artWorkViewModels![index] = hennaViewModel
                }
            }
            self.artWorkViewModels = artWorkViewModels!.sorted(by: { $0.date > $1.date })
            break
        case .piercing:
            var artWorkViewModels = self.artWorkViewModels as? Array<PiercingViewModel>
            if artWorkViewModels == nil { return }
            for jsonData in retArray! {
                let piercingViewModel: PiercingViewModel = PiercingViewModel(json: jsonData)
                if !artWorkViewModels!.contains(piercingViewModel) {
                    artWorkViewModels!.append(piercingViewModel)
                } else {
                    let index: Int = artWorkViewModels!.index(of: piercingViewModel)! // force to update
                    piercingViewModel.setCellHeight(cellHeight: artWorkViewModels![index].cellHeight)
                    self.artWorkViewModels![index] = piercingViewModel
                }
            }
            self.artWorkViewModels = artWorkViewModels!.sorted(by: { $0.date > $1.date })
            break
        case .design:
            var artWorkViewModels = self.artWorkViewModels as? Array<DesignViewModel>
            if artWorkViewModels == nil { return }
            for jsonData in retArray! {
                let designViewModel: DesignViewModel = DesignViewModel(json: jsonData)
                if !artWorkViewModels!.contains(designViewModel) {
                    artWorkViewModels!.append(designViewModel)
                } else {
                    let index: Int = artWorkViewModels!.index(of: designViewModel)! // force to update
                    designViewModel.setCellHeight(cellHeight: artWorkViewModels![index].cellHeight)
                    self.artWorkViewModels![index] = designViewModel
                }
            }
            self.artWorkViewModels = artWorkViewModels!.sorted(by: { $0.date > $1.date })
            break
        case .dreadlocks:
            var artWorkViewModels = self.artWorkViewModels as? Array<DreadlocksViewModel>
            if artWorkViewModels == nil { return }
            for jsonData in retArray! {
                let dreadlocksViewModel: DreadlocksViewModel = DreadlocksViewModel(json: jsonData)
                if !artWorkViewModels!.contains(dreadlocksViewModel) {
                    artWorkViewModels!.append(dreadlocksViewModel)
                } else {
                    let index: Int = artWorkViewModels!.index(of: dreadlocksViewModel)! // force to update
                    dreadlocksViewModel.setCellHeight(cellHeight: artWorkViewModels![index].cellHeight)
                    self.artWorkViewModels![index] = dreadlocksViewModel
                }
            }
            self.artWorkViewModels = artWorkViewModels!.sorted(by: { $0.date > $1.date })
            break
        }
    }
    
    func insertArtWorks(artistType: ArtistType,
                        artistLink: String,
                        artWorkViewModels: Array<AnyObject>,
                        completion: @escaping (_ result: Bool, _ error: NSError?)->()?) {
        self.dbRoot.insertArtWorks(artWorkViewModels,
                                   artistType: artistType,
                                   artistLink: artistLink, completion: {
            (result, error) -> Void in
            if error != nil {
                #if DEBUG
                    print("insertArtWorks failed!!!")
                #endif
            }
            if result == true {
                #if DEBUG
                    print("insertArtWorks done!!!")
                #endif
            }
            completion(result, error)
        })
    }
    
}
