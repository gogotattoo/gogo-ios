//
//  WIPArtWorksViewController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 10/05/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit

class WIPArtWorksViewController: BaseViewController {
  
  @IBOutlet weak var navigationBarBackgroundView: UIView!
  @IBOutlet weak var mainTableView: UITableView!
  fileprivate(set) var artWorkViewModels: [Any]?
  
  @IBOutlet weak var navgiationBackGroundHeightConstraint: NSLayoutConstraint!
  override func viewDidLoad() {
    super.viewDidLoad()
    self.basicUI()
    self.basicData()
  }
  
  func basicUI() {
    self.navigationBarBackgroundView.backgroundColor = Palette.gogoRed
    self.title = "WIP ArtWorks"
    let nib = UINib(nibName: "WIPArtWorkDetailTableViewCell", bundle: nil)
    self.mainTableView.register(nib, forCellReuseIdentifier: "WIPArtWorkDetailTableViewCell")
    self.mainTableView.rowHeight = UITableViewAutomaticDimension
    self.mainTableView.estimatedRowHeight = 280
    self.mainTableView.tableFooterView = UIView()
  }
  
  func basicData() {
    self.artWorkViewModels = MainManager.sharedInstance.artWorkViewModels
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
}

extension WIPArtWorksViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.artWorkViewModels != nil {
      return artWorkViewModels!.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if self.artWorkViewModels == nil { return UITableViewCell() }
    if indexPath.row >= self.artWorkViewModels!.count { return UITableViewCell() }
    let cell: WIPArtWorkDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WIPArtWorkDetailTableViewCell",
                                                                            for: indexPath) as! WIPArtWorkDetailTableViewCell
    let artWorkViewModel = self.artWorkViewModels![indexPath.row] as! ArtWorkViewModel
    if let imageIPFS = artWorkViewModel.imagesIPFS.first {
      cell.bindData(imageIPFS: imageIPFS)
      cell.imageDownloadCompleteCallBack = {
        self.mainTableView.beginUpdates()
        self.mainTableView.endUpdates()
      }
    }
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
}

extension WIPArtWorksViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.artWorkViewModels == nil { return }
    if indexPath.row >= self.artWorkViewModels!.count { return }
    let artWorkViewModel = self.artWorkViewModels![indexPath.row] as! ArtWorkViewModel
    MainManager.sharedInstance.uploadArtWorkViewModel = artWorkViewModel
    self.performSegue(withIdentifier: "WIP_Upload", sender: self)
  }
  
}
