//
//  UploadArtWorksViewController.swift
//  gogo-ios
//
//  Created by Hongli Yu on 30/04/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import UIKit
import Toucan
import Alamofire
import SwiftDate
import NVActivityIndicatorView

class UploadArtWorksViewController: BaseViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var navigationBarBackgroundView: UIView!
    @IBOutlet weak var uploadingImageView: UIImageView!
    // Manage the scroll view content size
    @IBOutlet weak var uploadingImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadingImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsView: ASJTagsView!
    @IBOutlet weak var bodyPartsView: ASJTagsView!
    // Manage tags view height
    @IBOutlet weak var tagsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bodyPartsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var artistNameTextField: UITextField!
    @IBOutlet weak var artWorkTypeTextField: UITextField!
    @IBOutlet weak var artWorkNameTextField: UITextField!
    @IBOutlet weak var cityAndCountryTextField: UITextField!
    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var createDateTextField: UITextField!
    @IBOutlet weak var costTimeTextFiled: UITextField!
    @IBOutlet weak var checkURLLabel: UILabel!
    @IBOutlet weak var checkURLIndicator: UIActivityIndicatorView!
    @IBOutlet weak var URLLabel: UILabel!
    
    fileprivate var navigationBarRightButton: UIBarButtonItem?
    fileprivate lazy var photoPickerActionSheet = PhotoPickerActionSheet()
    fileprivate var tags: [String] = ["cover", "color", "black and gray",
                                      "bird", "animal", "dragon", "flower", "koi"]
    fileprivate var bodyParts: [String] = ["shoulder", "arm", "chest", "leg"]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.basicUI()
        self.basicData()
    }
        
    func basicUI() {
        self.navigationBarBackgroundView.backgroundColor = Palette.gogoRed
        self.title = "Upload ArtWorks"
        
        self.uploadingImageViewWidthConstraint.constant = UIScreen.main.bounds.size.width - 8 * 2
        self.uploadingImageViewHeightConstraint.constant = UIScreen.main.bounds.size.width - 8 * 2
        
        self.navigationBarRightButton = UIBarButtonItem(title: "Upload",
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(self.uploadAction(_:)))
        self.navigationBarRightButton?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = navigationBarRightButton
        
        self.uploadingImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                  action: #selector(self.chosePhotoAction))
        self.uploadingImageView.addGestureRecognizer(tapGestureRecognizer)
        
        self.artistNameTextField.text = MainManager.sharedInstance.uploadArtistName
        self.artWorkTypeTextField.text = MainManager.sharedInstance.uploadArtistType.rawValue
        
        if let uploadArtWorkViewModel = MainManager.sharedInstance.uploadArtWorkViewModel {
            self.artWorkNameTextField.text = uploadArtWorkViewModel.title
            self.cityAndCountryTextField.text = uploadArtWorkViewModel.madeAtCity + "&" + uploadArtWorkViewModel.madeAtCountry
            self.storeNameTextField.text = uploadArtWorkViewModel.madeAtShop
            self.createDateTextField.text = uploadArtWorkViewModel.madeDate.string(format: DateFormat.custom("yyyy/MM/dd"))
            self.costTimeTextFiled.text = String(uploadArtWorkViewModel.durationMin)
            if uploadArtWorkViewModel.gender == "female" {
                self.genderSegment.selectedSegmentIndex = 0
            }
            if uploadArtWorkViewModel.gender == "male" {
                self.genderSegment.selectedSegmentIndex = 1
            }
            self.tags = uploadArtWorkViewModel.tags
            self.bodyParts = uploadArtWorkViewModel.bodypart
        } else {
            self.createDateTextField.text = Date().string(format: DateFormat.custom("yyyy/MM/dd"))
        }
        
        // PhotoPickerActionSheet
        // TODO: config params in one function
        self.photoPickerActionSheet.alertTitle = nil
        self.photoPickerActionSheet.alertMessage = nil
        self.photoPickerActionSheet.allowDestructive = true
        self.photoPickerActionSheet.allowEditing = false
        self.photoPickerActionSheet.cameraDevice = .rear
        self.photoPickerActionSheet.cameraFlashMode = .auto
        
        self.photoPickerActionSheet.onPhoto = {
            (image: UIImage?) -> Void in
            if image != nil {
                let imageWidth = UIScreen.main.bounds.size.width - 8 * 2
                let proportion = image!.size.width / imageWidth
                let imageHeight = image!.size.height / proportion
                self.uploadingImageViewHeightConstraint.constant = imageHeight
                self.uploadingImageView.image = image!
            }
        }
        self.photoPickerActionSheet.onCancel = {
            print("Cancel Pressed")
        }
        self.photoPickerActionSheet.onError = { (error) in
            print("Error: \(error.name())")
        }
        
        // tags
        self.tagsView.appendTags(self.tags)
        self.tagsViewHeightConstraint.constant = self.tagsView.contentSize.height
        self.tagsView.tapBlock = {
            [weak self] tagText, idx in
            guard let strongSelf = self else { return }
            strongSelf.addTags()
        }
        self.tagsView.deleteBlock = {
            [weak self] tagText, idx in
            guard let strongSelf = self else { return }
            strongSelf.tags.remove(at: idx)
            strongSelf.tagsView.deleteTag(at: idx)
            strongSelf.tagsViewHeightConstraint.constant = strongSelf.tagsView.contentSize.height
        }
        let addTagsGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addTags))
        self.tagsView.addGestureRecognizer(addTagsGestureRecognizer)

        self.bodyPartsView.appendTags(self.bodyParts)
        self.bodyPartsViewHeightConstraint.constant = self.bodyPartsView.contentSize.height
        self.bodyPartsView.tapBlock = {
            [weak self] tagText, idx in
            guard let strongSelf = self else { return }
            strongSelf.addBodyParts()
        }
        self.bodyPartsView.deleteBlock = {
            [weak self] tagText, idx in
            guard let strongSelf = self else { return }
            strongSelf.bodyParts.remove(at: idx)
            strongSelf.bodyPartsView.deleteTag(at: idx)
            strongSelf.bodyPartsViewHeightConstraint.constant = strongSelf.bodyPartsView.contentSize.height
        }
        let addBodyPartsGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addBodyParts))
        self.bodyPartsView.addGestureRecognizer(addBodyPartsGestureRecognizer)
    }
    
    // TODO: Optimize
    func addTags() {
        let alert = UIAlertController(title: "Add tags",
                                      message: "Create a new tag",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak alert] (_) in
            let textField = alert!.textFields![0]
            let text = textField.text
            self.tags.append(text!)
            self.tagsView.addTag(text!)
            self.tagsViewHeightConstraint.constant = self.tagsView.contentSize.height
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addBodyParts() {
        let alert = UIAlertController(title: "Add body parts",
                                      message: "Create a new tag",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak alert] (_) in
            let textField = alert!.textFields![0]
            let text = textField.text
            self.bodyParts.append(text!)
            self.bodyPartsView.addTag(text!)
            self.bodyPartsViewHeightConstraint.constant = self.bodyPartsView.contentSize.height
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func basicData() {
        
    }
    
    func uploadAction(_ sender: UIBarButtonItem) {
        // TODO: optimize
        let size = CGSize(width: 30, height: 30)
        self.startAnimating(size, message: "Uploading image to ipfs",
                            type: NVActivityIndicatorType.ballScaleRipple)
        let limit : UInt32 = 6
        Alamofire.upload( multipartFormData: { multipartFormData in
            multipartFormData.append(UIImageJPEGRepresentation(self.uploadingImageView.image!, 1)!,
                                     withName: "uploadfile",
                                     fileName: "gogo.tattoo_\(arc4random_uniform(limit)).jpeg",
                                     mimeType: "image/jpeg")
        }, to: "\(Constant.Network.host.rawValue)/upload?artist_name=\(self.artistNameTextField.text!)&made_at=\(self.storeNameTextField.text!)&made_date=\(self.createDateTextField.text!)",
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    let percent = String(Progress.fractionCompleted * 100).substring(to: 4)
                    NVActivityIndicatorPresenter.sharedInstance.setMessage("Uploading image to ipfs: \(percent)%")
                })
                upload.responseJSON { response in
                    let error = response.result.error
                    if error != nil {
                        DispatchQueue.main.async(execute: {
                            self.stopAnimating()
                            self.alert(error!.localizedDescription)
                        })
                        return
                    }
                    if response.result.isSuccess {
                        DispatchQueue.main.async(execute: { 
                            let data = response.result.value
                            if let dictionary: Dictionary<String, String> = data as? Dictionary<String, String> {
                                NVActivityIndicatorPresenter.sharedInstance.setMessage("Updating image hash...")
                                self.requestIfUploadImageSucceed(dictionary: dictionary)
                            }
                        })
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func requestIfUploadImageSucceed(dictionary: Dictionary<String, String>) {
        let IPFSHash = dictionary["Hash"]
//        let imageURL = dictionary["URL"]
        var params: Parameters = [:]
        params["bodypart"] = self.bodyParts
        params["date"] = Date().string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ")) // upload time, current time
        params["duration_min"] = Int(self.costTimeTextFiled.text!) // TODO: check
        params["extra"] = ""
        params["gender"] = self.genderSegment.titleForSegment(at: self.genderSegment.selectedSegmentIndex)?.lowercased()
        params["image_ipfs"] = ""
        params["images_ipfs"] = [IPFSHash]
        params["link"] = Constant.Network.host.rawValue + "/xizi/tattoo/\(self.artWorkNameTextField.text!)"
        let cityAndCountry: Array<String> = self.cityAndCountryTextField.text!.components(separatedBy: "&")
        if cityAndCountry.count == 2 {
            params["made_at_city"] = cityAndCountry[0].trim()
            params["made_at_country"] = cityAndCountry[1].trim()
        }
        params["made_at_shop"] = self.storeNameTextField.text!
        if let date = self.createDateTextField.text!.date(format: DateFormat.custom("yyyy/MM/dd"))?.absoluteDate {
            params["made_date"] = date.string(format: DateFormat.custom("yyyy-MM-dd'T'HH:mm:ssZ"))
        }
        params["tags"] = self.tags
        params["title"] = self.artWorkNameTextField.text!
        params["type"] = self.artWorkTypeTextField.text!
        
        let path = "/\(MainManager.sharedInstance.uploadArtistName)/\(MainManager.sharedInstance.uploadArtistType.rawValue)/\(self.artWorkNameTextField.text!)"
        MainManager.sharedInstance.requestIfUploadImageSucceed(path: path, params: params) {
            (result, error) -> Void in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    self.stopAnimating()
                    self.alert(error!.localizedDescription)
                })
                return
            }
            if result != nil {
                debugPrint(result ?? "") // TODO: parse data, get offest, now if it returns then succeed
                DispatchQueue.main.async(execute: {
                    NVActivityIndicatorPresenter.sharedInstance.setMessage("Succeed")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                        self.stopAnimating()
                    }
                })
            }
        }
        
    }
    
    func dataToJSON(_ data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func chosePhotoAction() {
        self.photoPickerActionSheet.present(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension UploadArtWorksViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}
