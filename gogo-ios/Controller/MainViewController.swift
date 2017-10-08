//
//  MainViewController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 14/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class MainViewController: BaseViewController {
  
  @IBOutlet weak var navigationBarBackgroundView: UIView!
  @IBOutlet weak var backgroundTableView: UITableView!
  @IBOutlet weak var artistCollectionView: UICollectionView!
  @IBOutlet weak var navgiationBackGroundHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var artistFlowLayout: UICollectionViewFlowLayout!
  
  // MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.basicUI()
    self.basicData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "Main_ArtWorks",
      let artWorksViewController = segue.destination as? ArtWorksViewController {
      debugPrint(artWorksViewController)
    }
  }
  
  // MARK: UI
  func basicUI() {
    // System & device adaptation
    if #available(iOS 11.0, *) {
      self.backgroundTableView.contentInsetAdjustmentBehavior = .never
    } else {
      self.automaticallyAdjustsScrollViewInsets = false
    }
    if DeviceInfo.modelName() == "iPhone X" {
      self.navgiationBackGroundHeightConstraint.constant = kNavgiationBackGroundHeightConstraintiPhoneX
    } else {
      self.navgiationBackGroundHeightConstraint.constant = kNavgiationBackGroundHeightConstraintNormal
    }
    
    self.title = "loading...".localized
    self.navigationBarBackgroundView.backgroundColor = Palette.gogoRed
    let backgroundTableViewCellNib = UINib(nibName: kBackgroundTableViewCellReuseID, bundle: nil)
    self.backgroundTableView.register(backgroundTableViewCellNib, forCellReuseIdentifier: kBackgroundTableViewCellReuseID)
    self.artistFlowLayout.itemSize = CGSize(width: 88, height: 88)
  }
  
  func updateUI() {
    self.title = "Dashboard".localized
    self.artistCollectionView.reloadData()
  }
  
  // MARK: Data
  func basicData() {
    MainManager.sharedInstance.requestArtistList {
      (result, error) -> Void in
      if error != nil {
        DispatchQueue.main.async(execute: {
          self.alert("\(error!.localizedDescription)")
        })
      }
      if result != nil {
        DispatchQueue.main.async(execute: {
          self.updateUI()
        })
      }
    }
  }
  
}

// MARK: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == self.backgroundTableView {
      let cell: BackgroundTableViewCell = tableView.dequeueReusableCell(withIdentifier: kBackgroundTableViewCellReuseID,
                                                                        for: indexPath) as! BackgroundTableViewCell
      return cell
    }
    return UITableViewCell()
  }
  
}

// MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView: BackgroundTableViewHeaderView = Bundle.main.loadNibNamed("BackgroundTableViewHeaderView",
                                                                             owner: self, options: nil)?.first as! BackgroundTableViewHeaderView
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return (UIScreen.main.bounds.size.height / 667) * 340 // 340 check xib, iPhone7
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return (UIScreen.main.bounds.size.width / 375) * 264 // 264 check xib, iPhone7
  }
  
}

// MARK: UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    guard let artistViewModels = MainManager.sharedInstance.artistViewModels else { return 0 }
    return artistViewModels.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let collectionViewCell: ArtistCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: kArtistCollectionViewCellReuseID,
                                                                                          for: indexPath) as! ArtistCollectionViewCell
    if let artistViewModels = MainManager.sharedInstance.artistViewModels,
      indexPath.row < artistViewModels.count {
      let artistViewModel: ArtistViewModel = artistViewModels[indexPath.row]
      collectionViewCell.bindData(artistViewModel)
    }
    return collectionViewCell
  }
  
}

// MARK: UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView,
                      didSelectItemAt indexPath: IndexPath) {
    MainManager.sharedInstance.enterArtWorks(artistViewModelIndex: indexPath.row)
  }
  
}
