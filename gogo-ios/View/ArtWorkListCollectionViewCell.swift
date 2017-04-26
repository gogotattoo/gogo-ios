//
//  ArtWorkListCollectionViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 20/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class ArtWorkListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contentTableView: UITableView!
    fileprivate var artWorkFilteredViewModels: Array<ArtWorkFilteredViewModel> = []
    var cellSelectedCallBack:(()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentTableView.delegate = self
        self.contentTableView.dataSource = self
        self.contentTableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "ArtWorkTableViewCell", bundle: nil)
        self.contentTableView.register(nib, forCellReuseIdentifier: "ArtWorkTableViewCell")
    }
    
    func bindData(artWorkFilteredViewModels: Array<ArtWorkFilteredViewModel>) {
        self.artWorkFilteredViewModels = artWorkFilteredViewModels
        self.contentTableView.reloadData()
    }
    
}

extension ArtWorkListCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artWorkFilteredViewModels[section].artWorkViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.contentTableView {
            let cell: ArtWorkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ArtWorkTableViewCell",
                                                                           for: indexPath) as! ArtWorkTableViewCell
            if indexPath.section < self.artWorkFilteredViewModels.count {
                let artWorkFilteredViewModel: ArtWorkFilteredViewModel = self.artWorkFilteredViewModels[indexPath.section]
                if indexPath.row < artWorkFilteredViewModel.artWorkViewModels.count {
                    let artWorkViewModel: AnyObject = artWorkFilteredViewModel.artWorkViewModels[indexPath.row]
                    cell.imageDownloadCompleteCallBack = {
                        self.contentTableView.beginUpdates()
                        self.contentTableView.endUpdates()
                    }
                    cell.bindData(artWorkViewModel: artWorkViewModel)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.artWorkFilteredViewModels.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let artWorkFilteredViewModel: ArtWorkFilteredViewModel = self.artWorkFilteredViewModels[section]
        return artWorkFilteredViewModel.sectionTitle
    }
    
}

extension ArtWorkListCollectionViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        let artWorkFilteredViewModel: ArtWorkFilteredViewModel = self.artWorkFilteredViewModels[indexPath.section]
        let artWorkViewModel: AnyObject = artWorkFilteredViewModel.artWorkViewModels[indexPath.row]
        MainManager.sharedInstance.enterArtWorkDetail(selectedArtWork: artWorkViewModel)
        self.cellSelectedCallBack?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let artWorkFilteredViewModel: ArtWorkFilteredViewModel = self.artWorkFilteredViewModels[indexPath.section]
        if indexPath.row < artWorkFilteredViewModel.artWorkViewModels.count {
            let artWorkViewModel: AnyObject = artWorkFilteredViewModel.artWorkViewModels[indexPath.row]
            
            // TODO: optimize
            switch MainManager.sharedInstance.currentArtistType {
            case .tattoo:
                if let artWorkViewModel = artWorkViewModel as? TattooViewModel {
                    if artWorkViewModel.cellHeight != 0 {
                        return artWorkViewModel.cellHeight
                    }
                }
                break
            case .henna:
                if let artWorkViewModel = artWorkViewModel as? HennaViewModel {
                    if artWorkViewModel.cellHeight != 0 {
                        return artWorkViewModel.cellHeight
                    }
                }
                break
            case .piercing:
                if let artWorkViewModel = artWorkViewModel as? PiercingViewModel {
                    if artWorkViewModel.cellHeight != 0 {
                        return artWorkViewModel.cellHeight
                    }
                }
                break
            case .design:
                if let artWorkViewModel = artWorkViewModel as? DesignViewModel {
                    if artWorkViewModel.cellHeight != 0 {
                        return artWorkViewModel.cellHeight
                    }
                }
                break
            case .dreadlocks:
                if let artWorkViewModel = artWorkViewModel as? DreadlocksViewModel {
                    if artWorkViewModel.cellHeight != 0 {
                        return artWorkViewModel.cellHeight
                    }
                }
                break
            }
            
        }
        return 320
    }

}

extension ArtWorkListCollectionViewCell: UIScrollViewDelegate {
    
    // decelerate is true if it will continue moving afterwards
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            self.contentTableView.beginUpdates()
//            self.contentTableView.endUpdates()
//        }
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        self.contentTableView.beginUpdates()
//        self.contentTableView.endUpdates()
//    }

}
