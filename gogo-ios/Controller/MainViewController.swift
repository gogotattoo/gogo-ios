//
//  MainViewController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 14/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Alamofire
import Nuke

class MainViewController: BaseViewController {

    @IBOutlet weak var navigationBarBackgroundView: UIView!
    @IBOutlet weak var backgroundTableView: UITableView! // vertical
    @IBOutlet weak var artistCollectionVIew: UICollectionView!
    @IBOutlet weak var uploadButton: UIButton!
    
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
        self.uploadButton.titleLabel!.font = UIFont.icomoon(ofSize: 24)
        self.uploadButton.backgroundColor = Palette.gogoRed
        self.uploadButton.setTitleColor(UIColor.white, for: .normal)
        self.uploadButton.setTitle(Icomoon.upload.rawValue, for: .normal)
    }
    
    func basicData() {
        MainManager.sharedInstance.requestArtistList {
            (result, error) -> Void in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    print(error!)
                    // indicator alert 2 seconds
                })
            }
            if result != nil {
                DispatchQueue.main.async(execute: {
                    self.title = "gogo.tattoo"
                    self.artistCollectionVIew.reloadData()
                })
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Main_ArtWorks",
            let artWorksViewController = segue.destination as? ArtWorksViewController {
            print(artWorksViewController)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func uploadAction(_ sender: Any) {
        let alertController: UIAlertController = UIAlertController(title: "Upload is coming",
                                                                   message: "",
                                                                   preferredStyle: .alert)
        let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: .destructive) { (alertAction) in
            //
        }
        alertController.addAction(alertAction)
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(alertController, animated: true, completion: nil)
        }
        // TODO: upload
//        self.performSegue(withIdentifier: "Main_Upload", sender: false)
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
        return (UIScreen.main.bounds.size.height / 667) * 340 // 340 check xib
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (UIScreen.main.bounds.size.height / 667) * 264 // 264 check xib
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
        let collectionViewCell: ArtistCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCollectionViewCell", for: indexPath) as! ArtistCollectionViewCell
        let artistViewModel: ArtistViewModel = MainManager.sharedInstance.artistViewModels![indexPath.row]
        let imageURLString = Constant.Network.imageHost + artistViewModel.avatarIPFS
        
        Manager.shared.loadImage(with: Request(url: URL(string: imageURLString)!)) {
            (result) in
            let image = result.value
            collectionViewCell.avatarImageView.image = image
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

