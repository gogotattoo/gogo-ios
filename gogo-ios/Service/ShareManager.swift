//
//  ShareManager.swift
//  gogo-ios
//
//  Created by Hongli Yu on 05/05/2017.
//  Copyright © 2017 Hongli Yu. All rights reserved.
//

import Foundation

final class ShareManager: NSObject, WXApiDelegate {
  
  static let sharedInstance = ShareManager()
  fileprivate(set) var scene: WXScene = WXSceneSession
  
  override init() {
    super.init()
    WXApi.registerApp("wx53fa670d677abeba", enableMTA: false)
  }
  
  func setScene(scene: WXScene) {
    self.scene = scene
  }
  
  fileprivate func checkIfWeChatInstalled() -> Bool {
    return WXApi.isWXAppInstalled()
  }
  
  func shareSinglePicture(image: UIImage) {
    let imageObject: WXImageObject = WXImageObject()
    imageObject.imageData = UIImagePNGRepresentation(image)
    
    let mediaMessage: WXMediaMessage = WXMediaMessage()
    let resizedImage = image.scaleImageToFitSize(size: CGSize(width: 50, height: 50))
    mediaMessage.setThumbImage(resizedImage)
    mediaMessage.mediaObject = imageObject
    
    let shareRequest: SendMessageToWXReq = SendMessageToWXReq()
    shareRequest.bText = false
    shareRequest.message = mediaMessage
    shareRequest.scene = Int32(self.scene.rawValue)
    
    WXApi.send(shareRequest)
  }
  
  fileprivate func alertIfNeedInstallWeChat() {
    let alertController: UIAlertController = UIAlertController(title: "WeChat Not Installed",
                                                               message: "message",
                                                               preferredStyle: .alert)
    let installWeChatAction: UIAlertAction = UIAlertAction(title: "install", style: .default) { (alertAction) in
      UIApplication.shared.openURL(URL(string: WXApi.getWXAppInstallUrl())!)
    }
    alertController.addAction(installWeChatAction)
    let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: .default) { (alertAction) in
      //
    }
    alertController.addAction(cancelAction)
    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
      rootVC.present(alertController, animated: true, completion: nil)
    }
  }
  
  func shareSessionAction(title: String, description: String,
                          image: UIImage, url: String, sender: UIViewController) {
    if self.checkIfWeChatInstalled() {
      self.setScene(scene: WXSceneSession)
      self.shareWebPage(title: title, description: description,
                        image: image, url: url)
    } else {
      self.alertIfNeedInstallWeChat()
    }
  }
  
  func shareTimelineAction(title: String, description: String,
                           image: UIImage, url: String, sender: UIViewController) {
    if self.checkIfWeChatInstalled() {
      self.setScene(scene: WXSceneTimeline)
      self.shareWebPage(title: title, description: description,
                        image: image, url: url)
    } else {
      self.alertIfNeedInstallWeChat()
    }
  }
  
  fileprivate func shareWebPage(title: String, description: String,
                                image: UIImage, url: String) {
    let message: WXMediaMessage = WXMediaMessage()
    message.title = title
    message.description = description
    message.setThumbImage(image)
    
    let webPageObject = WXWebpageObject()
    webPageObject.webpageUrl = url
    message.mediaObject = webPageObject
    
    let req: SendMessageToWXReq = SendMessageToWXReq()
    req.bText = false
    req.message = message
    req.scene = Int32(self.scene.rawValue)
    
    WXApi.send(req)
  }
  
  // MARK: WXApiDelegate
  func onReq(_ req: BaseReq!) {
    // WeChat => Project
    // TODO: need WeChat white list
    if req is GetMessageFromWXReq {
      //
    } else if req is ShowMessageFromWXReq {
      
    } else if req is LaunchFromWXReq {
      
    }
  }
  
  func onResp(_ resp: BaseResp!) {
    // WXApi sendReq call back
    if resp is SendMessageToWXResp {
      switch resp.errCode {
      case WXSuccess.rawValue: // 成功
        break
      case WXErrCodeCommon.rawValue: // 普通错误类型
        self.alertWithErrorMessage(message: "Common Error")
        break
      case WXErrCodeUserCancel.rawValue: // 用户点击取消并返回
        break
      case WXErrCodeSentFail.rawValue: // 发送失败
        self.alertWithErrorMessage(message: "Request Error")
        break
      case WXErrCodeAuthDeny.rawValue: // 授权失败
        self.alertWithErrorMessage(message: "Authorization Error")
        break
      case WXErrCodeUnsupport.rawValue: // 微信不支持
        self.alertWithErrorMessage(message: "WeChat Not Support Error")
        break
      default:
        break
      }
    }
  }
  
  func alertWithErrorMessage(message: String) {
    let alertController: UIAlertController = UIAlertController(title: "WeChat Share Failed",
                                                               message: message,
                                                               preferredStyle: .alert)
    let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: .destructive) { (alertAction) in
      //
    }
    alertController.addAction(alertAction)
    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
      rootVC.present(alertController, animated: true, completion: nil)
    }
  }
  
}
