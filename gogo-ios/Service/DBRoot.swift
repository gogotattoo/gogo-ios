//
//  DBRoot.swift
//  italki
//
//  Created by Hongli Yu on 12/10/2016.
//  Copyright © 2016 italki. All rights reserved.
//

import Foundation
import RealmSwift

typealias ClosureType = () -> ()

final public class DBRoot {
    
    var reamlTaskThread: Thread?
    var queueCondition: NSCondition = NSCondition()
    var blockQueue: Array = [ClosureType]()
    var reamlTaskRunloop: CFRunLoop?
    
    init() {
        self.config()
        self.createTaskThread()
    }
    
    func reset() {
        self.config()
    }
    
    // MARK: Realm Task Thread
    /// Remember that Realm objects can only be accessed from the thread on which they were first created, so this copy will only work for Realms on the same thread.
    /// All db opration in datamanager concurrent queue, but in the same thread
    func createTaskThread() {
        if self.reamlTaskThread == nil {
            self.reamlTaskThread = Thread(target: self,
                                          selector: #selector(DBRoot.taskThreadEntryPoint(_:)),
                                          object: nil)
            self.reamlTaskThread!.start()
        }
    }
    
    @objc func taskThreadEntryPoint(_ sender: AnyObject?) {
        autoreleasepool {
            Thread.current.name = "realm_task_thread"
            self.reamlTaskRunloop = CFRunLoopGetCurrent()
            let runloop: RunLoop = RunLoop.current
            runloop.add(NSMachPort(), forMode: RunLoopMode.commonModes)
            runloop.run()
        }
    }
    
    @objc func realmTaskStart() {
        self.queueCondition.lock()
        var block: ClosureType?
        if self.blockQueue.first != nil {
            block = self.blockQueue.removeFirst()
            #if DEBUG
                //print(block)
            #endif
        }
        block?()
        self.queueCondition.unlock()
    }
    
    func enqueueRealmTask(_ block: @escaping ClosureType) {
        self.queueCondition.lock()
        self.blockQueue.append(block) // how to copy a block
        self.queueCondition.unlock()
    }
    
    func addTask(_ block: @escaping ClosureType) {
        self.enqueueRealmTask(block)
        while true {
            if self.reamlTaskRunloop == nil {
                #if DEBUG
                    print("waiting run loop ready!")
                #endif
            } else {
                break
            }
        }
        weak var weakSelf = self
        CFRunLoopPerformBlock(self.reamlTaskRunloop, CFRunLoopMode.commonModes.rawValue) {
            let strongSelf = weakSelf
            strongSelf?.realmTaskStart()
        }
        CFRunLoopWakeUp(self.reamlTaskRunloop)
    }
    
    // MARK: Realm Config
    func config() {
        // TODO: logout then login again, the user id will be changed
        self.setDefaultRealmForUser("Default")
    }
    
    func setDefaultRealmForUser(_ userID: String) {
        var config = Realm.Configuration()
        config.schemaVersion = 0
        let path = FileDirectoryManager.documentDirectory() + "/\(userID).realm"
        config.fileURL = URL(fileURLWithPath: path)
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: Database Actions
    /// Artist
    func insertArtists(_ artistViewModels: Array<ArtistViewModel>,
                       completion: @escaping (_ result: Bool, _ error: NSError?)->()?) {
        let block = {
            autoreleasepool {
                #if DEBUG
                    print(Realm.Configuration.defaultConfiguration.fileURL!)
                #endif
                do {
                    let realm = try Realm()
                    realm.beginWrite()
                    for artistViewModel in artistViewModels {
                        let artist: Artist = artistViewModel.fetchArtist()
                        realm.add(artist, update: true)
                    }
                    try realm.commitWrite()
                    completion(true, nil)
                } catch let error as NSError {
                    completion(false , error)
                }
            }
        }
        self.addTask(block)
    }
    
    func selectArtists(_ completion: @escaping (_ result: Array<ArtistViewModel>?, _ error: NSError?)->()?) {
        let block = {
            autoreleasepool {
                do {
                    var retArray: Array<ArtistViewModel> = [ArtistViewModel]()
                    let realm = try Realm()
                    realm.beginWrite()
                    let artists = realm.objects(Artist.self).sorted(byKeyPath: "link", ascending: false)
                    try realm.commitWrite()
                    if artists.count == 0 {
                        completion(nil, nil) // TODO: the table is empty, need error?
                        return
                    }
                    for artist in artists {
                        let artistViewModel: ArtistViewModel = ArtistViewModel(artist: artist)
                        retArray.append(artistViewModel)
                    }
                    completion(retArray, nil)
                } catch let error as NSError {
                    completion(nil , error)
                }
            }
        }
        self.addTask(block)
    }

    /// ArtWork
    func insertArtWorks(_ artWorkViewModels: Array<AnyObject>,
                        artistType: ArtistType,
                        artistLink: String,
                        completion: @escaping (_ result: Bool, _ error: NSError?)->()?) {
        let block = {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    realm.beginWrite()
                    for artWorkViewModel in artWorkViewModels {
                        switch artistType { // TODO: optimize
                        case .artwork:
                            break
                        case .tattoo:
                            let artWork: Tattoo = (artWorkViewModel as! TattooViewModel).fetchArtWork()
                            artWork.artistType = artistType.rawValue
                            artWork.artistLink = artistLink
                            realm.add(artWork, update: true)
                            break
                        case .henna:
                            let artWork: Henna = (artWorkViewModel as! HennaViewModel).fetchArtWork()
                            artWork.artistType = artistType.rawValue
                            artWork.artistLink = artistLink
                            realm.add(artWork, update: true)
                            break
                        case .piercing:
                            let artWork: Piercing = (artWorkViewModel as! PiercingViewModel).fetchArtWork()
                            artWork.artistType = artistType.rawValue
                            artWork.artistLink = artistLink
                            realm.add(artWork, update: true)
                            break
                        case .design:
                            let artWork: Design = (artWorkViewModel as! DesignViewModel).fetchArtWork()
                            artWork.artistType = artistType.rawValue
                            artWork.artistLink = artistLink
                            realm.add(artWork, update: true)
                            break
                        case .dreadlocks:
                            let artWork: Dreadlocks = (artWorkViewModel as! DreadlocksViewModel).fetchArtWork()
                            artWork.artistType = artistType.rawValue
                            artWork.artistLink = artistLink
                            realm.add(artWork, update: true)
                            break
                        }
                    }
                    try realm.commitWrite()
                    completion(true, nil)
                } catch let error as NSError {
                    completion(false , error)
                }
            }
        }
        self.addTask(block)
    }
    
    func selectArtWorks(artistType: ArtistType, artistLink: String,
                        completion: @escaping (_ result: Array<AnyObject>?, _ error: NSError?)->()?) {
        let block = {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    realm.beginWrite()
                    var artWorkType = ArtWork.self
                    switch artistType {
                    case .tattoo:
                        artWorkType = Tattoo.self
                        break
                    case .henna:
                        artWorkType = Henna.self
                        break
                    case .piercing:
                        artWorkType = Piercing.self
                        break
                    case .design:
                        artWorkType = Design.self
                        break
                    case .dreadlocks:
                        artWorkType = Dreadlocks.self
                        break
                    default:
                        artWorkType = ArtWork.self
                        break
                    }
                    let artWorks = realm.objects(artWorkType).sorted(byKeyPath: "date", ascending: false)
                    try realm.commitWrite()
                    
                    if artWorks.count == 0 {
                        completion(nil, nil) // TODO: the table is empty, need error?, not possibale?
                        return
                    }
                    
                    var retArray: Array<AnyObject> = []
                    for artWork in artWorks {
                        switch artistType {
                        case .tattoo:
                            let tattooViewModel: TattooViewModel = TattooViewModel(tattoo: artWork as? Tattoo)
                            if tattooViewModel.artistLink == artistLink && tattooViewModel.artistType == artistType {
                                retArray.append(tattooViewModel)
                            }
                            break
                        case .henna:
                            let hennaViewModel: HennaViewModel = HennaViewModel(henna: artWork as? Henna)
                            if hennaViewModel.artistLink == artistLink && hennaViewModel.artistType == artistType {
                                retArray.append(hennaViewModel)
                            }
                            break
                        case .piercing:
                            let piercingViewModel: PiercingViewModel = PiercingViewModel(piercing: artWork as? Piercing)
                            if piercingViewModel.artistLink == artistLink && piercingViewModel.artistType == artistType {
                                retArray.append(piercingViewModel)
                            }
                            break
                        case .design:
                            let designViewModel: DesignViewModel = DesignViewModel(design: artWork as? Design)
                            if designViewModel.artistLink == artistLink && designViewModel.artistType == artistType {
                                retArray.append(designViewModel)
                            }
                            break
                        case .dreadlocks:
                            let dreadlocksViewModel: DreadlocksViewModel = DreadlocksViewModel(dreadlocks: artWork as? Dreadlocks)
                            if dreadlocksViewModel.artistLink == artistLink && dreadlocksViewModel.artistType == artistType {
                                retArray.append(dreadlocksViewModel)
                            }
                            break
                        default:
                            break
                        }
                    }
                    completion(retArray, nil)
                } catch let error as NSError {
                    completion(nil , error)
                }
            }
        }
        self.addTask(block)
    }
    
}
