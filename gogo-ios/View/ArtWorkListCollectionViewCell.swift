//
//  ArtWorkListCollectionViewCell.swift
//  gogo-ios
//
//  Created by Hongli Yu on 04/10/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

let kArtWorkListCollectionViewCellReuseID = "ArtWorkListCollectionViewCell"

class ArtWorkListCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var contentTableView: UITableView!
  fileprivate var artWorkSectionViewModels: [ArtWorkSectionViewModel] = []
  var cellSelectedCallBack:(()->Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.contentTableView.delegate = self
    self.contentTableView.dataSource = self
    self.contentTableView.tableFooterView = UIView()
    let nib = UINib(nibName: kArtWorkTableViewCellReuseID, bundle: nil)
    self.contentTableView.register(nib, forCellReuseIdentifier: kArtWorkTableViewCellReuseID)
  }
  
  func bindData(_ artWorkSectionViewModels: [ArtWorkSectionViewModel]) {
    self.artWorkSectionViewModels = artWorkSectionViewModels
    self.contentTableView.reloadData()
  }
  
}

extension ArtWorkListCollectionViewCell: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.artWorkSectionViewModels[section].artWorkViewModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == self.contentTableView {
      let cell: ArtWorkTableViewCell = tableView.dequeueReusableCell(withIdentifier: kArtWorkTableViewCellReuseID,
                                                                     for: indexPath) as! ArtWorkTableViewCell
      if indexPath.section < self.artWorkSectionViewModels.count {
        let artWorkSectionViewModel: ArtWorkSectionViewModel = self.artWorkSectionViewModels[indexPath.section]
        if indexPath.row < artWorkSectionViewModel.artWorkViewModels.count {
          let artWorkViewModel = artWorkSectionViewModel.artWorkViewModels[indexPath.row]
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
    return self.artWorkSectionViewModels.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let artWorkSectionViewModel: ArtWorkSectionViewModel = self.artWorkSectionViewModels[section]
    return artWorkSectionViewModel.title
  }
  
}

extension ArtWorkListCollectionViewCell: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let artWorkSectionViewModel: ArtWorkSectionViewModel = self.artWorkSectionViewModels[indexPath.section]
    let artWorkViewModel = artWorkSectionViewModel.artWorkViewModels[indexPath.row]
    MainManager.sharedInstance.enterArtWorkDetail(selectedArtWork: artWorkViewModel)
    self.cellSelectedCallBack?()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let artWorkSectionViewModel: ArtWorkSectionViewModel = self.artWorkSectionViewModels[indexPath.section]
    if indexPath.row < artWorkSectionViewModel.artWorkViewModels.count {
      let artWorkViewModel = artWorkSectionViewModel.artWorkViewModels[indexPath.row]
      
      // TODO: optimize
      switch MainManager.sharedInstance.currentArtType {
      case .artwork:
        break
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

