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
    @IBOutlet weak var backgroundTableView: UITableView! // vertical
    @IBOutlet weak var artistCollectionVIew: UICollectionView!
    fileprivate var actionButton: ActionButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.basicUI()
        self.basicData()
    }
    
    func basicUI() {
        self.title = "loading..."
        self.navigationBarBackgroundView.backgroundColor = Palette.gogoRed
        let nib = UINib(nibName: "BackgroundTableViewCell", bundle: nil)
        self.backgroundTableView.register(nib, forCellReuseIdentifier: "BackgroundTableViewCell")
        
        let demoImage = UIImage(named: "DemoPic")! // TODO: Custom in the future
        let tattoo = ActionButtonItem(title: "Tattoo", image: demoImage)
        tattoo.action = {
            [weak self] item in
            guard let strongSelf = self else { return }
            strongSelf.actionButton.dismiss()
            let name = MainManager.sharedInstance.uploadArtistName
            MainManager.sharedInstance.uploadArtistType = ArtistType.tattoo
            strongSelf.requestInreviewArtWorks(artist: name, artistType: ArtistType.tattoo)
        }
        let henna = ActionButtonItem(title: "Henna", image: demoImage)
        henna.action = {
            [weak self] item in
            guard let strongSelf = self else { return }
            strongSelf.actionButton.dismiss()
            let name = MainManager.sharedInstance.uploadArtistName
            MainManager.sharedInstance.uploadArtistType = ArtistType.henna
            strongSelf.requestInreviewArtWorks(artist: name, artistType: ArtistType.henna)
        }
        let piercing = ActionButtonItem(title: "Piercing", image: demoImage)
        piercing.action = {
            [weak self] item in
            guard let strongSelf = self else { return }
            strongSelf.actionButton.dismiss()
            let name = MainManager.sharedInstance.uploadArtistName
            MainManager.sharedInstance.uploadArtistType = ArtistType.piercing
            strongSelf.requestInreviewArtWorks(artist: name, artistType: ArtistType.piercing)
        }
        let design = ActionButtonItem(title: "Design", image: demoImage)
        design.action = {
            [weak self] item in
            guard let strongSelf = self else { return }
            strongSelf.actionButton.dismiss()
            let name = MainManager.sharedInstance.uploadArtistName
            MainManager.sharedInstance.uploadArtistType = ArtistType.design
            strongSelf.requestInreviewArtWorks(artist: name, artistType: ArtistType.design)
        }
        let locks = ActionButtonItem(title: "Locks", image: demoImage)
        locks.action = {
            [weak self] item in
            guard let strongSelf = self else { return }
            strongSelf.actionButton.dismiss()
            let name = MainManager.sharedInstance.uploadArtistName
            MainManager.sharedInstance.uploadArtistType = ArtistType.dreadlocks
            strongSelf.requestInreviewArtWorks(artist: name, artistType: ArtistType.dreadlocks)
        }

        self.actionButton = ActionButton(attachedToView: self.view,
                                         items: [tattoo, henna, piercing, design, locks])
        self.actionButton.action = {
            [weak self] button in
            guard let strongSelf = self else { return }
            if MainManager.sharedInstance.uploadArtistName == "" {
                strongSelf.alert("Please long press the artist profile to chose :)")
                return
            }
            button.toggleMenu()
        }
        self.actionButton.setTitle("+", forState: UIControlState())
        self.actionButton.backgroundColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0)
    }
    
    func requestInreviewArtWorks(artist: String, artistType: ArtistType) {
        let size = CGSize(width: 30, height: 30)
        self.startAnimating(size, message: "Loading...",
                            type: NVActivityIndicatorType.ballScaleRipple)
        MainManager.sharedInstance.requestInReviewArtWorks(artist, artistType: artistType) {
            (result, error) -> Void in
            DispatchQueue.main.async(execute: {
                self.stopAnimating()
            })
            if error != nil {
                DispatchQueue.main.async(execute: {
                    self.alert("\(error!.localizedDescription)")
                })
            }
            if result != nil {
                if result!.count > 0 { // reveiw wip list
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "Main_WIP", sender: self)
                    })
                } else { // empty array
                    DispatchQueue.main.async(execute: {
                        MainManager.sharedInstance.uploadArtWorkViewModel = nil
                        self.performSegue(withIdentifier: "Main_Upload", sender: self)
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    MainManager.sharedInstance.uploadArtWorkViewModel = nil
                    self.performSegue(withIdentifier: "Main_Upload", sender: self)
                })
            }
        }
    }
    
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
                    self.title = "gogo.tattoo/dashboard"
                    self.artistCollectionVIew.reloadData()
                })
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Main_ArtWorks",
            let artWorksViewController = segue.destination as? ArtWorksViewController {
            debugPrint(artWorksViewController)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.backgroundTableView {
            let cell: BackgroundTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BackgroundTableViewCell",
                                                                              for: indexPath) as! BackgroundTableViewCell
            return cell
        }
        return UITableViewCell()
    }

}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: BackgroundTableViewHeaderView = Bundle.main.loadNibNamed("BackgroundTableViewHeaderView",
                                                                                 owner: self, options: nil)?.first as! BackgroundTableViewHeaderView
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (UIScreen.main.bounds.size.height / 667) * 340 // 340 check xib, iPhone7
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (UIScreen.main.bounds.size.height / 667) * 264 // 264 check xib, iPhone7
    }

}

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if MainManager.sharedInstance.artistViewModels != nil {
            return MainManager.sharedInstance.artistViewModels!.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if MainManager.sharedInstance.artistViewModels == nil {
            return UICollectionViewCell()
        }
        if indexPath.row >= MainManager.sharedInstance.artistViewModels!.count {
            return UICollectionViewCell()
        }
        let collectionViewCell: ArtistCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCollectionViewCell",
                                                                                              for: indexPath) as! ArtistCollectionViewCell
        let artistViewModel: ArtistViewModel = MainManager.sharedInstance.artistViewModels![indexPath.row]
        collectionViewCell.bindData(artistViewModel: artistViewModel)
        collectionViewCell.longPressActionCallBack = {
            for (index, element) in MainManager.sharedInstance.artistViewModels!.enumerated() {
                if element != artistViewModel {
                    if element.selectedArtist == true {
                        element.setSelectedArtist(selectedArtist: false)
                        let indexPath: IndexPath = IndexPath(row: index, section: 0)
                        if let cell = collectionView.cellForItem(at: indexPath) as? ArtistCollectionViewCell {
                            cell.bindData(artistViewModel: element)
                        } else {
                            collectionView.reloadData() // resue not working
                        }
                    }
                } else {
                    self.title = "gogo.tattoo/" + element.link
                }
            }
        }
        return collectionViewCell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        MainManager.sharedInstance.enterArtWorks(artistViewModelIndex: indexPath.row)
    }

}

