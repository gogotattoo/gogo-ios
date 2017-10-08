//
//  MainManager.swift
//  gogo-ios
//
//  Created by Hongli Yu on 15/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftDate
import Nuke

final class MainManager {
  
  static let sharedInstance = MainManager()
  fileprivate var dataManager: DataManager = DataManager()
  
  fileprivate(set) var artistViewModels: [ArtistViewModel]?
  fileprivate(set) var currentArtistViewModel: ArtistViewModel?
  fileprivate(set) var currentArtType: ArtType = .tattoo // default value is tattoo
  
  fileprivate(set) var artWorkViewModels: [Any]? // raw data
  fileprivate(set) var artWorkSectionViewModels: [ArtWorkSectionViewModel]? // current tableview datasource
  fileprivate(set) var artWorkMatrixViewModels: [ArtWorkMatrixViewModel]? // all data source for this page
  
  fileprivate(set) var selectedArtWork: Any?
  
  // upload
  var uploadArtistName: String = ""
  var uploadArtType: ArtType = ArtType.tattoo
  var uploadArtWorkViewModel: ArtWorkViewModel?
  
  // MARK: Setter
  func setCurrentArtType(artType: ArtType) {
    self.currentArtType = artType
  }
  
  // MARK: Computed Properties
  var selectedArtTypeIndex: Int {
    guard let currentArtistViewModel = self.currentArtistViewModel else { return 0 }
    if let index = currentArtistViewModel.services.index(of: self.currentArtType.rawValue) {
      return index
    }
    return 0
  }
  
  // MARK: Artist
  func requestArtistList(completion: @escaping (_ result: Array<ArtistViewModel>?, _ error: NSError?)->()?) {
    self.dataManager.requestArtistList() {
      (result, error) -> Void in
      if error != nil {
        completion(nil, error)
        return
      }
      if result != nil {
        self.artistViewModels = result!
        completion(result, nil)
      }
    }
  }
  
  // MARK: ArtWorkList
  func requestArtWorkList(_ artist: String, completion: @escaping (_ result: [ArtWorkMatrixViewModel]?, _ error: NSError?)->()?) {
    guard let currentArtistViewModel = self.currentArtistViewModel else { return }
    self.dataManager.requestArtWorkList(artist, artType: self.currentArtType, artistLink: currentArtistViewModel.link) {
      (result, error) -> Void in
      if error != nil {
        completion(nil, error)
        return
      }
      if result != nil {
        self.dataManager.dataQueue.async(flags: .barrier, execute: {
          self.artWorkViewModels = result!

          // TODO: optimize
          switch self.currentArtType {
          case .artwork:
            break
          case .tattoo:
            var artWorkViewModels = self.artWorkViewModels as! [TattooViewModel]
            self.artWorkSectionViewModels = []
            
            while artWorkViewModels.count > 0 {
              let sectionTitle = artWorkViewModels.first!.date.string(format: DateFormat.custom("yyyy-MM"))
              let filteredArtWorkViewModels = artWorkViewModels.filter {
                $0.date.string(format: DateFormat.custom("yyyy-MM")) == sectionTitle
              }
              let artWorkSectionViewModel: ArtWorkSectionViewModel = ArtWorkSectionViewModel(title: sectionTitle, height: 44,
                                                                                             artWorkViewModels: filteredArtWorkViewModels)
              if !self.artWorkSectionViewModels!.contains(artWorkSectionViewModel) {
                self.artWorkSectionViewModels!.append(artWorkSectionViewModel)
              }
              artWorkViewModels = artWorkViewModels.filter { !filteredArtWorkViewModels.contains($0) }
            }
            let artWorkMatrixViewModel: ArtWorkMatrixViewModel = ArtWorkMatrixViewModel(artType: self.currentArtType,
                                                                                        artWorkFilteredViewModels: self.artWorkSectionViewModels!)
            guard var artWorkMatrixViewModels = self.artWorkMatrixViewModels else { return }
            if artWorkMatrixViewModels.contains(artWorkMatrixViewModel) {
              let index: Int = artWorkMatrixViewModels.index(of: artWorkMatrixViewModel)! // force to update
              artWorkMatrixViewModels[index] = artWorkMatrixViewModel
            } else {
              artWorkMatrixViewModels.append(artWorkMatrixViewModel)
            }
            self.artWorkMatrixViewModels = artWorkMatrixViewModels
            completion(self.artWorkMatrixViewModels, nil)
            break
          case .henna:
            break
          case .piercing:
            break
          case .design:
            break
          case .dreadlocks:
            break
          }
        })
      }
    }
  }
  
  func insertArtWorks(artType: ArtType, artistLink: String,
                      completion: @escaping (_ result: Bool, _ error: NSError?)->()?) {
    self.dataManager.dataQueue.async {
      var artWorkSectionViewModels: [ArtWorkSectionViewModel] = []
      var artWorkViewModels: [Any] = []
      guard let artWorkMatrixViewModels = self.artWorkMatrixViewModels else { return }
      for artWorkMatrixViewModel in artWorkMatrixViewModels {
        if artWorkMatrixViewModel.artType == self.currentArtType {
          artWorkSectionViewModels = artWorkMatrixViewModel.artWorkFilteredViewModels
          for artWorkSectionViewModel in artWorkSectionViewModels {
            artWorkViewModels = artWorkViewModels + artWorkSectionViewModel.artWorkViewModels
          }
        }
      }
      self.dataManager.insertArtWorks(artType: artType, artistLink: artistLink,
                                      artWorkViewModels: artWorkViewModels) {
        (result, error) -> Void in
        if error != nil {
          completion(false, error)
          return
        }
        if result {
          completion(true, nil)
        }
      }
    }
  }
  
  func requestInReviewArtWorks(_ artist: String, artType: ArtType, completion:
    @escaping (_ result: [Any]?, _ error: NSError?)->()?) {
    self.dataManager.requestWipArtWorkList(artist, artType: artType) {
      (result, error) -> Void in
      if error != nil {
        completion(nil, error)
        return
      }
      if result != nil {
        self.artWorkViewModels = result
        completion(result, nil)
      }
    }
  }
  
  func requestIfUploadImageSucceed(path: String, params: Parameters,
                                   completion: @escaping (_ result: AnyObject?, _ error: NSError?)->()?) {
    self.dataManager.requestIfUploadImageSucceed(path: path, params: params) {
      (result, error) -> Void in
      if error != nil {
        completion(nil, error)
      }
      if result != nil {
        completion(result, nil)
      }
    }
  }
  
  // MARK: Life Cycle
  func enterArtWorks(artistViewModelIndex: Int) {
    self.artWorkSectionViewModels = []
    self.artWorkMatrixViewModels = []
    self.artWorkViewModels = []
    self.dataManager.artWorkViewModels = []
    
    self.currentArtistViewModel = self.artistViewModels?[artistViewModelIndex]
    // TODO: mutil thread
    if let currentArtistViewModel = self.currentArtistViewModel {
      for service in currentArtistViewModel.services {
        let artWorkMatrixViewModel: ArtWorkMatrixViewModel = ArtWorkMatrixViewModel(artType: ArtType(rawValue: service)!,
                                                                                    artWorkFilteredViewModels: [ArtWorkSectionViewModel]())
        guard var artWorkMatrixViewModels = self.artWorkMatrixViewModels else { return }
        artWorkMatrixViewModels.append(artWorkMatrixViewModel)
      }
    }
  }
  
  func exitArtWorks() {
    // TODO: finish it
    self.insertArtWorks(artType: self.currentArtType, artistLink: self.currentArtistViewModel!.link,
                        completion: { (result, error) -> Void in
                          if error != nil {
                            
                          }
                          if result {
                            
                          }
    })
  }
  
  func enterArtWorkDetail(selectedArtWork: Any) {
    self.selectedArtWork = selectedArtWork
  }
  
  func exitArtWorkDetail() {
    
  }
  
  func cacheImage(url: URL, image: UIImage) {
    //        Cache.shared.costLimit = 1024 * 1024 * 100
    //        Cache.shared.countLimit = 100
    let request = Request(url: url)
    Cache.shared[request] = image
  }
  
  func loadCacheImage(url: URL) -> UIImage? {
    let request = Request(url: url)
    let image = Cache.shared[request]
    return image
  }
  
  
}
