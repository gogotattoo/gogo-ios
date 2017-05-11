//
//  ArtWorkDetailViewController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 26/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Nuke
import Toucan
import NukeToucanPlugin

class ArtWorkDetailViewController: BaseViewController {

    @IBOutlet weak var navigationBarBackgroundView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var shareButton: UIBarButtonItem! {
        didSet {
            shareButton.setTitleTextAttributes([NSFontAttributeName : UIFont.icomoon(ofSize: 20) ?? UIFont.systemFont(ofSize: 20),
                                                NSForegroundColorAttributeName : UIColor.white],
                                               for: .normal)
            shareButton.title = Icomoon.share.rawValue
        }
    }
    
    var dataSourceLength: Int = 0
    var QRCodeStrings: [String] = []
    var imagesIPFS: [String] = [] // inclouding the thumbnail
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.basicUI()
        self.basicData()
    }
        
    func basicUI() {
        switch MainManager.sharedInstance.currentArtistType {
        case .artwork:
            break
        case .tattoo:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? TattooViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.imagesIPFS = artWorkViewModel.imagesIPFS
                self.title = artWorkViewModel.title
                self.imagesIPFS.insert(artWorkViewModel.imageIPFS, at: 0)
            }
            break
        case .henna:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? HennaViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.imagesIPFS = artWorkViewModel.imagesIPFS
                self.title = artWorkViewModel.title
                self.imagesIPFS.insert(artWorkViewModel.imageIPFS, at: 0)
            }
            break
        case .piercing:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? PiercingViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.imagesIPFS = artWorkViewModel.imagesIPFS
                self.title = artWorkViewModel.title
                self.imagesIPFS.insert(artWorkViewModel.imageIPFS, at: 0)
            }
            break
        case .design:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? DesignViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.imagesIPFS = artWorkViewModel.imagesIPFS
                self.title = artWorkViewModel.title
                self.imagesIPFS.insert(artWorkViewModel.imageIPFS, at: 0)
            }
            break
        case .dreadlocks:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? DreadlocksViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.imagesIPFS = artWorkViewModel.imagesIPFS
                self.title = artWorkViewModel.title
                self.imagesIPFS.insert(artWorkViewModel.imageIPFS, at: 0)
            }
            break
        }
        self.navigationBarBackgroundView.backgroundColor = Palette.gogoRed
        
        let nib = UINib(nibName: "ArtWorkDetailTableViewCell", bundle: nil)
        self.mainTableView.register(nib, forCellReuseIdentifier: "ArtWorkDetailTableViewCell")
        let nib2 = UINib(nibName: "QRCodeTableViewCell", bundle: nil)
        self.mainTableView.register(nib2, forCellReuseIdentifier: "QRCodeTableViewCell")
        
        self.mainTableView.rowHeight = UITableViewAutomaticDimension
        self.mainTableView.estimatedRowHeight = 280
        self.mainTableView.tableFooterView = UIView()
    }
    
    func basicData() {
        
        let link = MainManager.sharedInstance.currentArtistViewModel!.link
        let artistType = MainManager.sharedInstance.currentArtistType
        let titleString = self.title!.replace(target: " ", withString:"_").lowercased()
        
        self.QRCodeStrings.append("http://gogo.tattoo/\(link)/\(artistType.rawValue)/\(titleString)")
        self.QRCodeStrings.append("https://gogotattoo.github.io/\(link)/\(artistType.rawValue)/\(titleString)")
        
        self.dataSourceLength = self.dataSourceLength + self.QRCodeStrings.count
        
        MainManager.sharedInstance.artWorkDetailCellHeightArray.removeAll()
        for _ in 1...self.dataSourceLength {
            MainManager.sharedInstance.artWorkDetailCellHeightArray.append(280)
        }
        
    }
    
    @IBAction func shareAction(_ sender: Any, event: UIEvent) {
        
        var dataSource: [DPArrowMenuViewModel] = []
        let imageTimeLine = UIImage(text: Iconfont.wechatTimeLine, fontSize: 45,
                                    imageSize: CGSize(width: 50, height: 50), imageColor: UIColor.black)
        let imageSession = UIImage(text: Iconfont.wechatSession, fontSize: 45,
                                   imageSize: CGSize(width: 50, height: 50), imageColor: UIColor.black)
        // TODO: All Pictures need icon
        let arrowMenuViewModel0: DPArrowMenuViewModel = DPArrowMenuViewModel(title: "All Pictures",
                                                                             imageName: nil, image: UIImage(named: "DemoPic"))
        let arrowMenuViewModel1: DPArrowMenuViewModel = DPArrowMenuViewModel(title: "WebLink TimeLine",
                                                                             imageName: nil, image: imageTimeLine)
        let arrowMenuViewModel2: DPArrowMenuViewModel = DPArrowMenuViewModel(title: "WebLink Session",
                                                                             imageName: nil, image: imageSession)
        dataSource.append(arrowMenuViewModel0)
        dataSource.append(arrowMenuViewModel1)
        dataSource.append(arrowMenuViewModel2)
        guard let view = event.allTouches?.first?.view else { return }
        DPArrowMenu.showForSender(sender: view, with: dataSource, done: {
            [unowned self] (selectedIndex) in
            if selectedIndex == 0 {
                var activityItems: Array<UIImage> = []
                for imageIPFS in self.imagesIPFS {
                    let imageURLString = Constant.Network.imageHost + imageIPFS
                    let image = MainManager.sharedInstance.loadCacheImage(url: URL(string: imageURLString)!)
                    if image == nil { continue }
                    let data = UIImage.compress(image: image!, maxFileSize: 250, compression: 0.9, maxCompression: 0.1)
                    if data == nil { continue }
                    let imageToShare = UIImage(data: data!)
                    if imageToShare == nil { continue }
                    activityItems.append(imageToShare!)
                }
                for QRString in self.QRCodeStrings {
                    let image = MainManager.sharedInstance.loadCacheImage(url: URL(string: QRString)!)
                    if image == nil { continue }
                    let data = UIImage.compress(image: image!, maxFileSize: 250, compression: 0.9, maxCompression: 0.1)
                    if data == nil { continue }
                    let imageToShare = UIImage(data: data!)
                    if imageToShare == nil { continue }
                    activityItems.append(imageToShare!)
                }
                if activityItems.count > 9 { // largest number of sharing images
                    activityItems = Array(activityItems.prefix(9))
                }
                if activityItems.count > 0 {
                    let activityVC: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: {
                        //
                    })
                }
            }
            if selectedIndex == 1 { // TODO: optimize
                let link = MainManager.sharedInstance.currentArtistViewModel!.link
                let artistType = MainManager.sharedInstance.currentArtistType
                let titleString = self.title!.replace(target: " ", withString:"_").lowercased()
                let imageURLString = Constant.Network.imageHost + (self.imagesIPFS.first ?? "")
                Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
                    (result) in
                    let image = result.value
                    if image == nil { return }
                    // resize image view, based on the coming image size, need optimize
                    let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
                    let proportion = image!.size.width / imageWidth
                    let imageHeight = image!.size.height / proportion
                    let resizedAndMaskedImage = Toucan(image: image!).resize(CGSize(width: imageWidth, height: imageHeight)).image
                    ShareManager.sharedInstance.shareTimelineAction(title: titleString, description: "this is awesome",
                                                                    image: resizedAndMaskedImage,
                                                                    url: "https://gogotattoo.github.io/\(link)/\(artistType.rawValue)/\(titleString)",
                        sender: self)
                }
            }
            if selectedIndex == 2 {
                let link = MainManager.sharedInstance.currentArtistViewModel!.link
                let artistType = MainManager.sharedInstance.currentArtistType
                let titleString = self.title!.replace(target: " ", withString:"_").lowercased()
                let imageURLString = Constant.Network.imageHost + (self.imagesIPFS.first ?? "")
                Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
                    (result) in
                    let image = result.value
                    if image == nil { return }
                    // resize image view, based on the coming image size, need optimize
                    let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
                    let proportion = image!.size.width / imageWidth
                    let imageHeight = image!.size.height / proportion
                    let resizedAndMaskedImage = Toucan(image: image!).resize(CGSize(width: imageWidth, height: imageHeight)).image
                    ShareManager.sharedInstance.shareSessionAction(title: titleString, description: "this is awesome",
                                                                   image: resizedAndMaskedImage,
                                                                   url: "https://gogotattoo.github.io/\(link)/\(artistType.rawValue)/\(titleString)",
                        sender: self)
                }
            }
        }) {
            // cancel action call back
            print("cancel action call back")
        }
    }
    
}

extension ArtWorkDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceLength
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < self.dataSourceLength - self.QRCodeStrings.count {
            let cell: ArtWorkDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ArtWorkDetailTableViewCell",
                                                                                 for: indexPath) as! ArtWorkDetailTableViewCell
            switch MainManager.sharedInstance.currentArtistType {
            case .artwork:
                break
            case .tattoo:
                if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? TattooViewModel {
                    cell.bindData(imageIPFS: artWorkViewModel.imagesIPFS[indexPath.row], index: indexPath.row)
                }
                break
            case .henna:
                if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? HennaViewModel {
                    cell.bindData(imageIPFS: artWorkViewModel.imagesIPFS[indexPath.row], index: indexPath.row)
                }
                break
            case .piercing:
                if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? PiercingViewModel {
                    cell.bindData(imageIPFS: artWorkViewModel.imagesIPFS[indexPath.row], index: indexPath.row)
                }
                break
            case .design:
                if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? DesignViewModel {
                    cell.bindData(imageIPFS: artWorkViewModel.imagesIPFS[indexPath.row], index: indexPath.row)
                }
                break
            case .dreadlocks:
                if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? DreadlocksViewModel {
                    cell.bindData(imageIPFS: artWorkViewModel.imagesIPFS[indexPath.row], index: indexPath.row)
                }
                break
            }
            cell.imageDownloadCompleteCallBack = {
                self.mainTableView.beginUpdates()
                self.mainTableView.endUpdates()
            }
            return cell
        } else {
            if indexPath.row >= self.dataSourceLength - self.QRCodeStrings.count
                && indexPath.row < self.dataSourceLength {
                let cell: QRCodeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "QRCodeTableViewCell",
                                                                              for: indexPath) as! QRCodeTableViewCell
                cell.bindData(urlString: QRCodeStrings[indexPath.row - (self.dataSourceLength - self.QRCodeStrings.count)],
                              index: indexPath.row)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}

extension ArtWorkDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < MainManager.sharedInstance.artWorkDetailCellHeightArray.count {
            return MainManager.sharedInstance.artWorkDetailCellHeightArray[indexPath.row]
        }
        return 280
    }
    
}
