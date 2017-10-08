//
//  ArtWorksViewController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 19/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class ArtWorksViewController: BaseViewController {
  
  @IBOutlet weak var navigationBarBackgroundView: UIView!
  @IBOutlet weak var navgiationBackGroundHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var menuCollectionView: UICollectionView!
  @IBOutlet weak var artWorkListCollectionView: UICollectionView!
  fileprivate var doingAnimation: Bool = false
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.basicUI()
    self.basicData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ArtWorks_ArtWorkDetail",
      let artWorkDetailViewController = segue.destination as? ArtWorkDetailViewController {
      print(artWorkDetailViewController)
    }
  }
  
  // MARK: - UI
  func basicUI() {
    // System & device adaptation
    if #available(iOS 11.0, *) {
      self.artWorkListCollectionView.contentInsetAdjustmentBehavior = .never
    } else {
      self.automaticallyAdjustsScrollViewInsets = false
    }
    if DeviceInfo.modelName() == "iPhone X" {
      self.navgiationBackGroundHeightConstraint.constant = 90.0
    } else {
      self.navgiationBackGroundHeightConstraint.constant = 64.0
    }
    
    self.title = "loading...".localized
    self.navigationBarBackgroundView.backgroundColor = Palette.gogoRed
    self.menuCollectionView.backgroundColor = Palette.gogoRed
    
    let menuCollectionViewCellNib = UINib(nibName: kMenuCollectionViewCellReuseID, bundle: nil)
    self.menuCollectionView.register(menuCollectionViewCellNib, forCellWithReuseIdentifier: kMenuCollectionViewCellReuseID)
    let artWorkListCollectionViewCellNib = UINib(nibName: kArtWorkListCollectionViewCellReuseID, bundle: nil)
    self.artWorkListCollectionView.register(artWorkListCollectionViewCellNib, forCellWithReuseIdentifier: kArtWorkListCollectionViewCellReuseID)
  }
  
  // MARK: - Data
  func basicData() {
    guard let currentArtistViewModel = MainManager.sharedInstance.currentArtistViewModel else { return }
    if currentArtistViewModel.services.count > 0,
      let artType = ArtType(rawValue: currentArtistViewModel.services.first!) {
      MainManager.sharedInstance.setCurrentArtType(artType: artType)
    }
    MainManager.sharedInstance.requestArtWorkList(currentArtistViewModel.link) {
      (result, error) -> Void in
      if error != nil {
        DispatchQueue.main.async(execute: { // TODO: indicator show alert for 2 seconds
          self.doingAnimation = false
          self.alert("\(error!.localizedDescription)")
        })
      }
      if result != nil {
        DispatchQueue.main.async(execute: {
          self.doingAnimation = false
          self.title = "\(MainManager.sharedInstance.currentArtType.rawValue)"
          self.artWorkListCollectionView.reloadData()
        })
      }
    }
  }
  
  func requestData() {
    guard let currentArtistViewModel = MainManager.sharedInstance.currentArtistViewModel else { return }
    MainManager.sharedInstance.requestArtWorkList(currentArtistViewModel.link) {
      (result, error) -> Void in
      if error != nil {
        DispatchQueue.main.async(execute: { // TODO: indicator show alert for 2 seconds
          self.doingAnimation = false
          self.alert("\(error!.localizedDescription)")
        })
      }
      if result != nil {
        DispatchQueue.main.async(execute: {
          self.doingAnimation = false
          self.title = "\(MainManager.sharedInstance.currentArtType.rawValue)"
          self.artWorkListCollectionView.reloadData()
        })
      }
    }
  }
  
}

// MARK: - UICollectionViewDataSource
extension ArtWorksViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    guard let currentArtistViewModel = MainManager.sharedInstance.currentArtistViewModel else { return 0 }
    if collectionView == self.menuCollectionView {
      return currentArtistViewModel.services.count
    }
    if collectionView == self.artWorkListCollectionView {
      return currentArtistViewModel.services.count
    }
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == self.menuCollectionView {
      let menuCollectionViewCell: MenuCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: kMenuCollectionViewCellReuseID,
                                                                                              for: indexPath) as! MenuCollectionViewCell
      if let currentArtistViewModel = MainManager.sharedInstance.currentArtistViewModel,
        indexPath.row < currentArtistViewModel.services.count {
        menuCollectionViewCell.bindData(index: indexPath.row, text: currentArtistViewModel.services[indexPath.row])
      }
      return menuCollectionViewCell
    }
    if collectionView == self.artWorkListCollectionView {
      let artWorkListCollectionViewCell: ArtWorkListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: kArtWorkListCollectionViewCellReuseID,
                                                                                                            for: indexPath) as! ArtWorkListCollectionViewCell
      if let artWorkMatrixViewModels = MainManager.sharedInstance.artWorkMatrixViewModels,
        indexPath.row < artWorkMatrixViewModels.count {
        artWorkListCollectionViewCell.bindData(artWorkMatrixViewModels[indexPath.row].artWorkFilteredViewModels)
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
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
}

// MARK: - UICollectionViewDelegate
extension ArtWorksViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    if collectionView == self.menuCollectionView {
//      if indexPath.row == MainManager.sharedInstance.selectedIndex {
//        return
//      }
//      // TODO: optimize
//      if indexPath.row > MainManager.sharedInstance.selectedIndex { // next, to right
//        let visibleItems = self.artWorkListCollectionView.indexPathsForVisibleItems
//        guard let visibleItemsFirst = visibleItems.first else { return }
//        let currentItem: IndexPath = visibleItemsFirst
//        let nextItem = IndexPath(item: indexPath.row, section: currentItem.section)
//        UIView.animate(withDuration: 0.3, animations: {
//          self.artWorkListCollectionView.scrollToItem(at: nextItem as IndexPath,
//                                                      at: UICollectionViewScrollPosition.right,
//                                                      animated: false)
//        }, completion: { (finished) in
//          if let artType = ArtType(rawValue: MainManager.sharedInstance.currentArtistViewModel!.services[indexPath.row]) {
//            MainManager.sharedInstance.insertArtWorks(artType: MainManager.sharedInstance.currentArtType,
//                                                      artistLink: MainManager.sharedInstance.currentArtistViewModel!.link,
//                                                      completion: { (result, error) -> Void in
//                                                        if error != nil {
//
//                                                        }
//                                                        if result {
//                                                          DispatchQueue.main.async(execute: {
//                                                            MainManager.sharedInstance.setCurrentArtType(artType: artType)
//                                                            self.menuCollectionView.reloadData()
//                                                            self.requestData()
//                                                          })
//                                                        }
//            })
//          }
//        })
//      }
//      if indexPath.row < MainManager.sharedInstance.selectedIndex { // previous, to left
//        let visibleItems = self.artWorkListCollectionView.indexPathsForVisibleItems
//        guard let visibleItemsFirst = visibleItems.first else { return }
//        let currentItem: IndexPath = visibleItemsFirst
//        let nextItem = IndexPath(item: indexPath.row, section: currentItem.section)
//
//        UIView.animate(withDuration: 0.3, animations: {
//          self.artWorkListCollectionView.scrollToItem(at: nextItem as IndexPath,
//                                                      at: UICollectionViewScrollPosition.left,
//                                                      animated: false)
//        }, completion: { (finished) in
//          if let artType = ArtType(rawValue: MainManager.sharedInstance.currentArtistViewModel!.services[indexPath.row]) {
//            MainManager.sharedInstance.insertArtWorks(artType: MainManager.sharedInstance.currentArtType,
//                                                      artistLink: MainManager.sharedInstance.currentArtistViewModel!.link,
//                                                      completion: { (result, error) -> Void in
//                                                        if error != nil {
//
//                                                        }
//                                                        if result {
//                                                          DispatchQueue.main.async(execute: {
//                                                            MainManager.sharedInstance.setCurrentArtType(artType: artType)
//                                                            self.menuCollectionView.reloadData()
//                                                            self.requestData()
//                                                          })
//                                                        }
//            })
//          }
//        })
//      }
//    }
  }
  
}

// MARK: - UICollectionViewDelegateFlowLayout
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

// MARK: - UIScrollViewDelegate
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

// MARK: - BackButtonHandlerProtocol
extension ArtWorksViewController: BackButtonHandlerProtocol {
  
  func navigationShouldPopOnBackButton() -> Bool {
    MainManager.sharedInstance.exitArtWorks()
    return true
  }
  
}
