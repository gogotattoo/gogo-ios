//
//  MainManager.swift
//  gogo-ios
//
//  Created by Hongli Yu on 15/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
import AlamofireImage

public enum ArtistType: String {
    
    case tattoo = "tattoo"
    case henna = "henna"
    case piercing = "piercing"
    case design = "design"
    case dreadlocks = "dreadlocks"

}

final class MainManager {
    
    static let sharedInstance = MainManager()
    fileprivate var dataManager: DataManager = DataManager()
    
    fileprivate(set) var artistViewModels: Array<ArtistViewModel>?
    fileprivate(set) var currentArtistViewModel: ArtistViewModel?
    fileprivate(set) var currentArtistType: ArtistType = .tattoo // default value is tattoo
    
    // current tableview data source: tattoo, design, henna, piercing, dreadlocks, for the last request API
    fileprivate(set) var artWorkViewModels: Array<AnyObject>?
    // current tableview data source: tattoo, design, henna, piercing, dreadlocks, and sectionTitle
    fileprivate(set) var currentArtWorkFilteredViewModels: Array<ArtWorkFilteredViewModel>?
    // collect all data from all (tattoo, design, henna, piercing, dreadlocks) API from Srever
    // each ArtWorkFilteredListViewModel element refer to service item in artistViewModel
    fileprivate(set) var allArtWorkFilteredListViewModels: Array<ArtWorkFilteredListViewModel> = []
    
    fileprivate(set) var selectedArtWork: AnyObject?
    var artWorkDetailCellHeightArray: [CGFloat] = []
    // TODO: need realm image object, with image hash & computed present height

    /// Computed Properties
    var currentArtWorkFilteredListViewModel: ArtWorkFilteredListViewModel {
        for artWorkFilteredListViewModel: ArtWorkFilteredListViewModel in self.allArtWorkFilteredListViewModels {
            if artWorkFilteredListViewModel.artistType == getCurrentArtistType() {
                return artWorkFilteredListViewModel
            }
        }
        return ArtWorkFilteredListViewModel()
    }

    var selectedIndex: Int {
        if self.currentArtistViewModel == nil {
            return 0
        }
        if let index = self.currentArtistViewModel!.services.index(of: getCurrentArtistType().rawValue) {
            return index
        }
        return 0
    }
    
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
    
    func requestArtWorkList(_ artist: String,
                             completion: @escaping (_ result: Array<ArtWorkFilteredListViewModel>?, _ error: NSError?)->()?) {
        self.dataManager.requestArtWorkList(artist, artistType: self.currentArtistType,
                                            artistLink: self.currentArtistViewModel!.link) {
            (result, error) -> Void in
            if error != nil {
                completion(nil, error)
                return
            }
            if result != nil {
                self.dataManager.dataQueue.async(flags: .barrier, execute: {
                    self.artWorkViewModels = result!
                    
                    // TODO: optimize, ugly
                    switch self.currentArtistType {
                    case .tattoo:
                        var artWorkViewModels = self.artWorkViewModels as! Array<TattooViewModel>
                        // generate FilteredViewModels in art work
                        self.currentArtWorkFilteredViewModels = []
                        
                        while artWorkViewModels.count > 0 {
                            let filteredSectionTitle = artWorkViewModels.first!.date.string(format: DateFormat.custom("yyyy-MM"))
                            let filteredArtWorkViewModels = artWorkViewModels.filter {
                                $0.date.string(format: DateFormat.custom("yyyy-MM")) == filteredSectionTitle
                            }
                            let artWorkFilteredViewModel: ArtWorkFilteredViewModel = ArtWorkFilteredViewModel(sectionTitle: filteredSectionTitle,
                                                                                                              artWorkViewModels: filteredArtWorkViewModels)
                            if !self.currentArtWorkFilteredViewModels!.contains(artWorkFilteredViewModel) {
                                self.currentArtWorkFilteredViewModels!.append(artWorkFilteredViewModel)
                            }
                            artWorkViewModels = artWorkViewModels.filter { !filteredArtWorkViewModels.contains($0) }
                        }
                        let artWorkFilteredListViewModel: ArtWorkFilteredListViewModel = ArtWorkFilteredListViewModel(artistType: self.currentArtistType,
                                                                                                                      artWorkFilteredViewModels: self.currentArtWorkFilteredViewModels!)
                        if self.allArtWorkFilteredListViewModels.contains(artWorkFilteredListViewModel) {
                            let index: Int = self.allArtWorkFilteredListViewModels.index(of: artWorkFilteredListViewModel)! // force to update
                            self.allArtWorkFilteredListViewModels[index] = artWorkFilteredListViewModel
                        }
                        completion(self.allArtWorkFilteredListViewModels, nil)
                        break
                    case .henna:
                        var artWorkViewModels = self.artWorkViewModels as! Array<HennaViewModel>
                        // generate FilteredViewModels in art work
                        self.currentArtWorkFilteredViewModels = []
                        
                        while artWorkViewModels.count > 0 {
                            let filteredSectionTitle = artWorkViewModels.first!.date.string(format: DateFormat.custom("yyyy-MM"))
                            let filteredArtWorkViewModels = artWorkViewModels.filter {
                                $0.date.string(format: DateFormat.custom("yyyy-MM")) == filteredSectionTitle
                            }
                            let artWorkFilteredViewModel: ArtWorkFilteredViewModel = ArtWorkFilteredViewModel(sectionTitle: filteredSectionTitle,
                                                                                                              artWorkViewModels: filteredArtWorkViewModels)
                            if !self.currentArtWorkFilteredViewModels!.contains(artWorkFilteredViewModel) {
                                self.currentArtWorkFilteredViewModels!.append(artWorkFilteredViewModel)
                            }
                            artWorkViewModels = artWorkViewModels.filter { !filteredArtWorkViewModels.contains($0) }
                        }
                        let artWorkFilteredListViewModel: ArtWorkFilteredListViewModel = ArtWorkFilteredListViewModel(artistType: self.currentArtistType,
                                                                                                                      artWorkFilteredViewModels: self.currentArtWorkFilteredViewModels!)
                        if self.allArtWorkFilteredListViewModels.contains(artWorkFilteredListViewModel) {
                            let index: Int = self.allArtWorkFilteredListViewModels.index(of: artWorkFilteredListViewModel)! // force to update
                            self.allArtWorkFilteredListViewModels[index] = artWorkFilteredListViewModel
                        }
                        completion(self.allArtWorkFilteredListViewModels, nil)
                        break
                    case .piercing:
                        var artWorkViewModels = self.artWorkViewModels as! Array<PiercingViewModel>
                        // generate FilteredViewModels in art work
                        self.currentArtWorkFilteredViewModels = []
                        
                        while artWorkViewModels.count > 0 {
                            let filteredSectionTitle = artWorkViewModels.first!.date.string(format: DateFormat.custom("yyyy-MM"))
                            let filteredArtWorkViewModels = artWorkViewModels.filter {
                                $0.date.string(format: DateFormat.custom("yyyy-MM")) == filteredSectionTitle
                            }
                            let artWorkFilteredViewModel: ArtWorkFilteredViewModel = ArtWorkFilteredViewModel(sectionTitle: filteredSectionTitle,
                                                                                                              artWorkViewModels: filteredArtWorkViewModels)
                            if !self.currentArtWorkFilteredViewModels!.contains(artWorkFilteredViewModel) {
                                self.currentArtWorkFilteredViewModels!.append(artWorkFilteredViewModel)
                            }
                            artWorkViewModels = artWorkViewModels.filter { !filteredArtWorkViewModels.contains($0) }
                        }
                        let artWorkFilteredListViewModel: ArtWorkFilteredListViewModel = ArtWorkFilteredListViewModel(artistType: self.currentArtistType,
                                                                                                                      artWorkFilteredViewModels: self.currentArtWorkFilteredViewModels!)
                        if self.allArtWorkFilteredListViewModels.contains(artWorkFilteredListViewModel) {
                            let index: Int = self.allArtWorkFilteredListViewModels.index(of: artWorkFilteredListViewModel)! // force to update
                            self.allArtWorkFilteredListViewModels[index] = artWorkFilteredListViewModel
                        }
                        completion(self.allArtWorkFilteredListViewModels, nil)
                        break
                    case .design:
                        var artWorkViewModels = self.artWorkViewModels as! Array<DesignViewModel>
                        // generate FilteredViewModels in art work
                        self.currentArtWorkFilteredViewModels = []
                        
                        while artWorkViewModels.count > 0 {
                            let filteredSectionTitle = artWorkViewModels.first!.date.string(format: DateFormat.custom("yyyy-MM"))
                            let filteredArtWorkViewModels = artWorkViewModels.filter {
                                $0.date.string(format: DateFormat.custom("yyyy-MM")) == filteredSectionTitle
                            }
                            let artWorkFilteredViewModel: ArtWorkFilteredViewModel = ArtWorkFilteredViewModel(sectionTitle: filteredSectionTitle,
                                                                                                              artWorkViewModels: filteredArtWorkViewModels)
                            if !self.currentArtWorkFilteredViewModels!.contains(artWorkFilteredViewModel) {
                                self.currentArtWorkFilteredViewModels!.append(artWorkFilteredViewModel)
                            }
                            artWorkViewModels = artWorkViewModels.filter { !filteredArtWorkViewModels.contains($0) }
                        }
                        let artWorkFilteredListViewModel: ArtWorkFilteredListViewModel = ArtWorkFilteredListViewModel(artistType: self.currentArtistType,
                                                                                                                      artWorkFilteredViewModels: self.currentArtWorkFilteredViewModels!)
                        if self.allArtWorkFilteredListViewModels.contains(artWorkFilteredListViewModel) {
                            let index: Int = self.allArtWorkFilteredListViewModels.index(of: artWorkFilteredListViewModel)! // force to update
                            self.allArtWorkFilteredListViewModels[index] = artWorkFilteredListViewModel
                        }
                        completion(self.allArtWorkFilteredListViewModels, nil)
                        break
                    case .dreadlocks:
                        var artWorkViewModels = self.artWorkViewModels as! Array<DreadlocksViewModel>
                        // generate FilteredViewModels in art work
                        self.currentArtWorkFilteredViewModels = []
                        
                        while artWorkViewModels.count > 0 {
                            let filteredSectionTitle = artWorkViewModels.first!.date.string(format: DateFormat.custom("yyyy-MM"))
                            let filteredArtWorkViewModels = artWorkViewModels.filter {
                                $0.date.string(format: DateFormat.custom("yyyy-MM")) == filteredSectionTitle
                            }
                            let artWorkFilteredViewModel: ArtWorkFilteredViewModel = ArtWorkFilteredViewModel(sectionTitle: filteredSectionTitle,
                                                                                                              artWorkViewModels: filteredArtWorkViewModels)
                            if !self.currentArtWorkFilteredViewModels!.contains(artWorkFilteredViewModel) {
                                self.currentArtWorkFilteredViewModels!.append(artWorkFilteredViewModel)
                            }
                            artWorkViewModels = artWorkViewModels.filter { !filteredArtWorkViewModels.contains($0) }
                        }
                        let artWorkFilteredListViewModel: ArtWorkFilteredListViewModel = ArtWorkFilteredListViewModel(artistType: self.currentArtistType,
                                                                                                                      artWorkFilteredViewModels: self.currentArtWorkFilteredViewModels!)
                        if self.allArtWorkFilteredListViewModels.contains(artWorkFilteredListViewModel) {
                            let index: Int = self.allArtWorkFilteredListViewModels.index(of: artWorkFilteredListViewModel)! // force to update
                            self.allArtWorkFilteredListViewModels[index] = artWorkFilteredListViewModel
                        }
                        completion(self.allArtWorkFilteredListViewModels, nil)
                        break
                    }
                })
                
            }
        }
    }
    
    func insertArtWorks(artistType: ArtistType,
                        artistLink: String,
                        completion: @escaping (_ result: Bool, _ error: NSError?)->()?) {
        self.dataManager.dataQueue.async {
            var artWorkFilteredViewModels: Array<ArtWorkFilteredViewModel> = []
            var artWorkViewModels: Array<AnyObject> = []
            
            for allArtWorkFilteredListViewModel in self.allArtWorkFilteredListViewModels {
                if allArtWorkFilteredListViewModel.artistType == self.getCurrentArtistType() {
                    artWorkFilteredViewModels = allArtWorkFilteredListViewModel.artWorkFilteredViewModels
                    for artWorkFilteredViewModel in artWorkFilteredViewModels {
                        artWorkViewModels = artWorkViewModels + artWorkFilteredViewModel.artWorkViewModels
                    }
                }
            }
            self.dataManager.insertArtWorks(artistType: artistType, artistLink: artistLink,
                                            artWorkViewModels: artWorkViewModels) {
                (result, error) -> Void in
                if error != nil {
                    completion(false, error)
                }
                if result {
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: Setter
    func setCurrentArtistType(artistType: ArtistType) {
        self.currentArtistType = artistType
    }
    
    func getCurrentArtistType() -> ArtistType {
        return self.currentArtistType
    }
        
    // MARK: Memmory Life Cycle
    func enterArtWorks(artistViewModelIndex: Int) {
        
        // clean data
        self.allArtWorkFilteredListViewModels.removeAll()
        self.currentArtWorkFilteredViewModels = nil
        self.artWorkViewModels = nil
        self.dataManager.artWorkViewModels = nil
        
        // set new data
        self.currentArtistViewModel = self.artistViewModels?[artistViewModelIndex]
        // TODO: mutil thread
        if self.currentArtistViewModel != nil {
            for service in self.currentArtistViewModel!.services {
                let artWorkFilteredListViewModel: ArtWorkFilteredListViewModel = ArtWorkFilteredListViewModel(artistType: ArtistType(rawValue: service)!,
                                                                                                              artWorkFilteredViewModels: Array<ArtWorkFilteredViewModel>())
                self.allArtWorkFilteredListViewModels.append(artWorkFilteredListViewModel)
            }
        }
        
    }
    
    func exitArtWorks() {
        self.insertArtWorks(artistType: self.getCurrentArtistType(),
                            artistLink: self.currentArtistViewModel!.link,
                            completion: { (result, error) -> Void in
                                if error != nil {
                                    
                                }
                                if result {
                                    
                                }
        })
    }

    func enterArtWorkDetail(selectedArtWork: AnyObject) {
        self.selectedArtWork = selectedArtWork
    }
    
    func exitArtWorkDetail() {
        
    }
    
}
