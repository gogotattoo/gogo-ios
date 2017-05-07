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

class UploadArtWorksViewController: BaseViewController {

    @IBOutlet weak var navigationBarBackgroundView: UIView!
    fileprivate var navigationBarRightButton: UIBarButtonItem?
    fileprivate lazy var photoPickerActionSheet = PhotoPickerActionSheet()

    @IBOutlet weak var uploadingImageView: UIImageView!
    @IBOutlet weak var uploadingImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadingImageViewWidthConstraint: NSLayoutConstraint!
    
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
        self.navigationBarBackgroundView.backgroundColor = Palette.gogoRed
        self.title = "Upload ArtWorks"
        self.uploadingImageViewHeightConstraint.constant = UIScreen.main.bounds.size.width - 8 * 2
        
        self.navigationBarRightButton = UIBarButtonItem(title: "Upload",
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(uploadAction(_:)))
        self.navigationBarRightButton?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = navigationBarRightButton
        
        self.uploadingImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                  action: #selector(self.chosePhotoAction))
        self.uploadingImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // If you don't want use iCloud entitlement just set this value True
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

    }
    
    func basicData() {
        
    }
    
    func uploadAction(_ sender: UIBarButtonItem) {
        let limit : UInt32 = 6
        Alamofire.upload( multipartFormData: { multipartFormData in
            multipartFormData.append(UIImageJPEGRepresentation(self.uploadingImageView.image!, 1)!,
                                     withName: "uploadfile",
                                     fileName: "gogo.tattoo_\(arc4random_uniform(limit)).jpeg",
                                     mimeType: "image/jpeg")
        }, to: "\(Constant.Network.host.rawValue)/upload?artist_name=xizi&made_at=chushangfeng&made_date=2017/04/30",
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                upload.responseJSON { response in
                    debugPrint(response)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func chosePhotoAction() {
        self.photoPickerActionSheet.present(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
