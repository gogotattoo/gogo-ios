//
//  ArtWorkDetailViewController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 26/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class ArtWorkDetailViewController: UIViewController {

    @IBOutlet weak var navigationBarBackgroundView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    
    var dataSourceLength: Int = 0
    var QRCodeStrings: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.basicUI()
        self.basicData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.becomeTransparent(true, tintColor: UIColor.white,
                                                              titleColor: UIColor.white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.becomeTransparent(false, tintColor: view.tintColor,
                                                              titleColor: UIColor.black)
    }
    
    func basicUI() {
        switch MainManager.sharedInstance.currentArtistType {
        case .tattoo:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? TattooViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.title = artWorkViewModel.title
            }
            break
        case .henna:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? HennaViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.title = artWorkViewModel.title
            }
            break
        case .piercing:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? PiercingViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.title = artWorkViewModel.title
            }
            break
        case .design:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? DesignViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.title = artWorkViewModel.title
            }
            break
        case .dreadlocks:
            if let artWorkViewModel = MainManager.sharedInstance.selectedArtWork as? DreadlocksViewModel {
                self.dataSourceLength = artWorkViewModel.imagesIPFS.count
                self.title = artWorkViewModel.title
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

