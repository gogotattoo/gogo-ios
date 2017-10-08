//
//  DataManager.swift
//  gogo-ios
//
//  Created by Hongli Yu on 16/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import Alamofire

class DataManager {
  
  var dbRoot: DBRoot = DBRoot()
  var networkService: NetworkService = NetworkService()
  var dataQueue: DispatchQueue = DispatchQueue(label: "tattoo.gogo.datamanager",
                                               attributes: DispatchQueue.Attributes.concurrent)
  var artistViewModels: [ArtistViewModel]?
  var artWorkViewModels: [Any]?
  
  // MARK: Artist
  func requestArtistList(completion: @escaping (_ result: Array<ArtistViewModel>?, _ error: NSError?)->()?) {
    self.dataQueue.async {
      [weak self] in
      guard let strongSelf = self else { return }
      // db select
      strongSelf.dbRoot.selectArtists { [weak strongSelf] (result, error) -> Void in
        guard let strongSelf = strongSelf else { return }
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
    guard let artistViewModels = self.artistViewModels else { return }
    self.dbRoot.insertArtists(artistViewModels, completion: {
      (result, error) -> Void in
      if error != nil {
        debugPrint("\(error!.description)")
      }
      if result == true {
        debugPrint("insertArtists done!!!")
      }
      completion(result, error)
    })
  }
  
  // MARK: ArtWork
  func requestArtWorkList(_ artist: String, artType: ArtType, artistLink: String,
                          completion: @escaping (_ result: [Any]?, _ error: NSError?)->()?) {
    self.dataQueue.async {
      // db select
      self.dbRoot.selectArtWorks(artType: artType, artistLink: artistLink) { [weak self] (result, error) -> Void in
        guard let strongSelf = self else { return }
        if error != nil {
          strongSelf.dataQueue.async {
            completion(nil, error)
          }
          return
        }
        if result != nil {
          strongSelf.artWorkViewModels = result!
        }
        strongSelf.dataQueue.async {
          // net work
          completion(strongSelf.artWorkViewModels, nil)
          let path = "/\(artist)/\(artType.rawValue)"
          strongSelf.networkService.request(path, parameters: nil) {
            [weak strongSelf] (result, error) -> Void in
            guard let strongSelf = strongSelf else { return }
            strongSelf.dataQueue.async {
              if error != nil {
                completion(nil, error!)
                return
              }
              if result != nil {
                strongSelf.parseDataToArtworks(result, artType: artType)
                completion(strongSelf.artWorkViewModels, nil)
              }
            }
          }
        }
      }
    }
  }
  
  func parseDataToArtworks(_ result: AnyObject?, artType: ArtType) {
    let retArray = (result as? NSArray) as Array?
    if retArray == nil { return }
    if self.artWorkViewModels == nil {
      self.artWorkViewModels = []
    }
    
    switch artType {
    case .artwork:
      self.artWorkViewModels!.removeAll()
      var artWorkViewModels = self.artWorkViewModels as? Array<ArtWorkViewModel>
      if artWorkViewModels == nil { return }
      for jsonData in retArray! {
        let artWorkViewModel: ArtWorkViewModel = ArtWorkViewModel(json: jsonData)
        if !artWorkViewModels!.contains(artWorkViewModel) {
          artWorkViewModels!.append(artWorkViewModel)
        }
      }
      self.artWorkViewModels = artWorkViewModels!.sorted(by: { $0.date > $1.date })
      break
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
          self.artWorkViewModels![index] = tattooViewModel // TODO: fatal error: Index out of range
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
  
  func insertArtWorks(artType: ArtType, artistLink: String, artWorkViewModels: [Any],
                      completion: @escaping (_ result: Bool, _ error: NSError?)->()?) {
    self.dbRoot.insertArtWorks(artWorkViewModels, artType: artType,
                               artistLink: artistLink, completion: {
      (result, error) -> Void in
        if error != nil {
          debugPrint("\(error!.description)")
        }
        if result == true {
          debugPrint("insertArtWorks done!!!")
        }
        completion(result, error)
    })
  }
  
  func requestWipArtWorkList(_ artist: String, artType: ArtType,
                             completion: @escaping (_ result: [Any]?, _ error: NSError?)->()?) {
    self.dataQueue.async {
      [weak self] in
      guard let strongSelf = self else { return }
      let path = "/\(artist)/\(artType.rawValue)?status=wip"
      strongSelf.networkService.request(path, parameters: nil) {
        [weak strongSelf] (result, error) -> Void in
        guard let strongSelf = strongSelf else { return }
        strongSelf.dataQueue.async {
          if error != nil {
            completion(nil, error!)
            return
          }
          if result != nil {
            strongSelf.parseDataToArtworks(result, artType: ArtType.artwork)
            completion(self!.artWorkViewModels, nil)
          }
        }
      }
    }
  }
  
  func requestIfUploadImageSucceed(path: String, params: Parameters,
                                   completion: @escaping (_ result: AnyObject?, _ error: NSError?)->()?) {
    self.networkService.request(path, parameters: params as [String : AnyObject], method: .post) { (result, error) -> Void in
      if error != nil {
        completion(nil, error)
        return
      }
      if result != nil {
        completion(result, nil)
      }
    }
  }
  
}
