//
//  ArtWorksViewController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 19/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class ArtWorksViewController: BaseViewController {
    
    @IBOutlet weak var menuCollectionView: UICollectionView! {
        didSet{
            menuCollectionView.backgroundColor = Palette.gogoRed
        }
    }
    @IBOutlet weak var navigationBarBackgroundView: UIView!
    @IBOutlet weak var artWorkListCollectionView: UICollectionView!
    var doingAnimation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.basicUI()
        self.basicData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TODO: Release memmory, keep current tableview data
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArtWorks_ArtWorkDetail",
            let artWorkDetailViewController = segue.destination as? ArtWorkDetailViewController {
            print(artWorkDetailViewController)
        }
    }
    
    func basicUI() {
        self.title = "loading..."
        self.navigationBarBackgroundView.backgroundColor = Palette.gogoRed
    }
    
    func basicData() {
        guard let currentArtistViewModel = MainManager.sharedInstance.currentArtistViewModel else {
            return
        }
        if currentArtistViewModel.services.count > 0,
            let artistType = ArtistType(rawValue: currentArtistViewModel.services.first!) {
            MainManager.sharedInstance.setCurrentArtistType(artistType: artistType)
        }
        MainManager.sharedInstance.requestArtWorkList(currentArtistViewModel.link) {
            (result, error) -> Void in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    // TODO: indicator show alert for 2 seconds
                    print(error!)
                    self.doingAnimation = false
                })
            }
            if result != nil {
                DispatchQueue.main.async(execute: {
                    self.doingAnimation = false
                    self.title = "gogo.tattoo/\(MainManager.sharedInstance.currentArtistType.rawValue)"
                    self.artWorkListCollectionView.reloadData()
                })
            }
        }
    }
    
    func requestData() {
        guard let currentArtistViewModel = MainManager.sharedInstance.currentArtistViewModel else {
            return
        }
        MainManager.sharedInstance.requestArtWorkList(currentArtistViewModel.link) {
            (result, error) -> Void in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    // TODO: indicator show alert for 2 seconds
                    print(error!)
                    self.doingAnimation = false
                })
            }
            if result != nil {
                DispatchQueue.main.async(execute: {
                    self.doingAnimation = false
                    self.title = "gogo.tattoo/\(MainManager.sharedInstance.currentArtistType.rawValue)"
                    self.artWorkListCollectionView.reloadData()
                })
            }
        }
    }
        
}

extension ArtWorksViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.menuCollectionView {
            if MainManager.sharedInstance.currentArtistViewModel != nil {
                return MainManager.sharedInstance.currentArtistViewModel!.services.count
            }
        }
        if collectionView == self.artWorkListCollectionView {
            if MainManager.sharedInstance.currentArtistViewModel != nil {
                return MainManager.sharedInstance.currentArtistViewModel!.services.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if MainManager.sharedInstance.currentArtistViewModel == nil {
            return UICollectionViewCell()
        }
        
        if collectionView == self.menuCollectionView {
            let menuCollectionViewCell: MenuCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell",
                                                                                                    for: indexPath) as! MenuCollectionViewCell
            menuCollectionViewCell.backgroundColor = UIColor.clear
            if indexPath.row < MainManager.sharedInstance.currentArtistViewModel!.services.count {
                menuCollectionViewCell.titleLabel.text = MainManager.sharedInstance.currentArtistViewModel!.services[indexPath.row]
                if indexPath.row == MainManager.sharedInstance.selectedIndex {
                    menuCollectionViewCell.titleLabel.textColor = UIColor.white
                } else {
                    menuCollectionViewCell.titleLabel.textColor = UIColor.lightGray
                }
            }
            return menuCollectionViewCell
        }
        
        if collectionView == self.artWorkListCollectionView {
            let artWorkListCollectionViewCell: ArtWorkListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtWorkListCollectionViewCell",
                                                                                                                  for: indexPath) as! ArtWorkListCollectionViewCell
            if indexPath.row < MainManager.sharedInstance.allArtWorkFilteredListViewModels.count {
                artWorkListCollectionViewCell.bindData(artWorkFilteredViewModels: MainManager.sharedInstance.allArtWorkFilteredListViewModels[indexPath.row].artWorkFilteredViewModels)
                artWorkListCollectionViewCell.cellSelectedCallBack = {
                    [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.performSegue(withIdentifier: "ArtWorks_ArtWorkDetail", sender: false)
                }
            }
            return artWorkListCollectionViewCell
        }
        return UICollectionViewCell()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension ArtWorksViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.menuCollectionView {
            if indexPath.row == MainManager.sharedInstance.selectedIndex {
                return
            }
            // TODO: optimize
            if indexPath.row > MainManager.sharedInstance.selectedIndex { // next, to right
                let visibleItems = self.artWorkListCollectionView.indexPathsForVisibleItems
                guard let visibleItemsFirst = visibleItems.first else { return }
                let currentItem: IndexPath = visibleItemsFirst
                let nextItem = IndexPath(item: indexPath.row, section: currentItem.section)
                UIView.animate(withDuration: 0.3, animations: { 
                    self.artWorkListCollectionView.scrollToItem(at: nextItem as IndexPath,
                                                                at: UICollectionViewScrollPosition.right,
                                                                animated: false)
                }, completion: { (finished) in
                    if let artistType = ArtistType(rawValue: MainManager.sharedInstance.currentArtistViewModel!.services[indexPath.row]) {
                        MainManager.sharedInstance.insertArtWorks(artistType: MainManager.sharedInstance.currentArtistType,
                                                                  artistLink: MainManager.sharedInstance.currentArtistViewModel!.link,
                                                                  completion: { (result, error) -> Void in
                                                                    if error != nil {
                                                                        
                                                                    }
                                                                    if result {
                                                                        DispatchQueue.main.async(execute: {
                                                                            MainManager.sharedInstance.setCurrentArtistType(artistType: artistType)
                                                                            self.menuCollectionView.reloadData()
                                                                            self.requestData()
                                                                        })
                                                                    }
                        })
                    }
                })
            }
            if indexPath.row < MainManager.sharedInstance.selectedIndex { // previous, to left
                let visibleItems = self.artWorkListCollectionView.indexPathsForVisibleItems
                guard let visibleItemsFirst = visibleItems.first else { return }
                let currentItem: IndexPath = visibleItemsFirst
                let nextItem = IndexPath(item: indexPath.row, section: currentItem.section)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.artWorkListCollectionView.scrollToItem(at: nextItem as IndexPath,
                                                                at: UICollectionViewScrollPosition.left,
                                                                animated: false)
                }, completion: { (finished) in
                    if let artistType = ArtistType(rawValue: MainManager.sharedInstance.currentArtistViewModel!.services[indexPath.row]) {
                        MainManager.sharedInstance.insertArtWorks(artistType: MainManager.sharedInstance.currentArtistType,
                                                                  artistLink: MainManager.sharedInstance.currentArtistViewModel!.link,
                                                                  completion: { (result, error) -> Void in
                                                                    if error != nil {
                                                                        
                                                                    }
                                                                    if result {
                                                                        DispatchQueue.main.async(execute: {
                                                                            MainManager.sharedInstance.setCurrentArtistType(artistType: artistType)
                                                                            self.menuCollectionView.reloadData()
                                                                            self.requestData()
                                                                        })
                                                                    }
                        })
                    }
                })
            }
        }
    }
    
}

extension ArtWorksViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let currentArtistViewModel = MainManager.sharedInstance.currentArtistViewModel else {
            return CGSize.zero
        }
        if collectionView == self.menuCollectionView {
            if 88.0 * CGFloat(currentArtistViewModel.services.count) < UIScreen.main.bounds.size.width {
                return CGSize(width: UIScreen.main.bounds.size.width / CGFloat(currentArtistViewModel.services.count), height: 44)
            }
            return CGSize(width: 88, height: 44)
        }
        if collectionView == self.artWorkListCollectionView {
            return CGSize(width: UIScreen.main.bounds.size.width,
                          height: (UIScreen.main.bounds.size.height - (44 + 64)))
        }
        return CGSize.zero
    }
    
}

extension ArtWorksViewController: UIScrollViewDelegate {
    
    // decelerate is true if it will continue moving afterwards
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.artWorkListCollectionView {
            
        }
    }
    
}

extension ArtWorksViewController: BackButtonHandlerProtocol {
    
    func navigationShouldPopOnBackButton() -> Bool {
        MainManager.sharedInstance.exitArtWorks()
        return true
    }
    
}
