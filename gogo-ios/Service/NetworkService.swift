//
//  NetworkService.swift
//  italki
//
//  Created by Hongli Yu on 12/10/2016.
//  Copyright © 2016 italki. All rights reserved.
//

import Foundation
import Alamofire

extension NSNumber {
  fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

/// To remove square brackets from Alamofire array values
struct CustomEncoding: ParameterEncoding {
  
  fileprivate func escape(_ string: String) -> String {
    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    
    var allowedCharacterSet = CharacterSet.urlQueryAllowed
    allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
    
    var escaped = ""
    if #available(iOS 8.3, *) {
      escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    } else {
      let batchSize = 50
      var index = string.startIndex
      
      while index != string.endIndex {
        let startIndex = index
        let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
        let range = startIndex..<endIndex
        
        let substring = string.substring(with: range)
        
        escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
        
        index = endIndex
      }
    }
    return escaped
  }
  
  fileprivate func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
    var components: [(String, String)] = []
    
    if let dictionary = value as? [String: Any] {
      for (nestedKey, value) in dictionary {
        components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
      }
    } else if let array = value as? [Any] {
      for value in array {
        components += queryComponents(fromKey: "\(key)[]", value: value)
      }
    } else if let value = value as? NSNumber {
      if value.isBool {
        components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
      } else {
        components.append((escape(key), escape("\(value)")))
      }
    } else if let bool = value as? Bool {
      components.append((escape(key), escape((bool ? "1" : "0"))))
    } else {
      components.append((escape(key), escape("\(value)")))
    }
    
    return components
  }
  
  fileprivate func query(_ parameters: [String: Any]) -> String {
    var components: [(String, String)] = []
    for key in parameters.keys.sorted(by: <) {
      let value = parameters[key]!
      components += queryComponents(fromKey: key, value: value)
    }
    return components.map { "\($0)=\($1)" }.joined(separator: "&")
  }
  
  func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
    var request: URLRequest = try urlRequest.asURLRequest()
    guard let parameters = parameters else { return request }
    guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
      // Handle the error
      return request
    }
    if request.urlRequest?.httpMethod == "GET" {
      mutableRequest.url = URL(string: (mutableRequest.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))!)
    }
    
    if request.urlRequest?.httpMethod == "POST" {
      mutableRequest.httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
      if mutableRequest.httpBody != nil {
        let httpBody = NSString(data: mutableRequest.httpBody!, encoding: String.Encoding.utf8.rawValue)!
        mutableRequest.httpBody = httpBody.replacingOccurrences(of: "%5B%5D=", with: "=").data(using: String.Encoding.utf8)
      }
    }
    request = mutableRequest as URLRequest
    return request
  }
  
}

struct NetworkServiceError {
  
  enum ErrorType: String, RawRepresentable {
    case Canceled = "User canceled the request."
    case Timeout = "Request timed out."
    case MissingArgument = "Request is missing some arguments."
    case NotLoggedIn = "You are not logged in." // Server does not receive token or token is ""
    case NotAllowed = "Permission is not allowed."
    case NotFound = "Resources not found."
    case WrongMethod = "Request method is wrong."
    case TokenTimeout = "Login token has expired." // Server receives token, but token is wrong
    case ServerDown = "Server is temporarily unavailable."
    case NoNetwork = "Network unavailable."
    case ServerUnreachable = "Server could not be reached. Please try again later!"
    case Known = "Known" // login only, when the error is known on server side but is not covered on front end
    case Unknown = "An unknown error has occurred."
    case WrongReturnData = "Something is wrong with the data from the server."
    case UserDeactivated = "This account has been deactivated."
    case IncorrectPassword = "Incorrect password. Passwords are case sensitive."
    case ITCNotEnough = "ITC not enough."
  }
  var type = ErrorType.Unknown
  
}

final class NetworkService {
  
  fileprivate var netWorkQueue: DispatchQueue = DispatchQueue(label: "com.italki.networkservice", attributes: DispatchQueue.Attributes.concurrent)
  fileprivate var sessionTaskPool: Array<URLSessionTask> = [URLSessionTask]()
  
  init() {
    
  }
  
  func config() {
    // TODO: time out, concurrent requests count, etc
  }
  
  /// Request data from server
  ///
  /// - Parameter path: the path part of the URLString
  /// - Parameter parameters: optional needed parameters dictionary
  /// - Parameter method: get or post, default is get
  /// - Parameter completion: result, error
  ///
  /// - Note: login logic is different from other nomal requests
  func request(_ path: String,
               parameters: [String: AnyObject]?,
               method: Alamofire.HTTPMethod = .get,
               completion: @escaping (_ result: AnyObject?, _ error: NSError?)->()?) {
    let task: URLSessionTask = self.dataTaskRequest(path, parameters: parameters,
                                                    method: method, completion: completion)
    self.netWorkQueue.async(flags: .barrier, execute: {
      if !self.sessionTaskPool.contains(task) {
        self.sessionTaskPool.append(task)
      }
    })
  }
  
  fileprivate func dataTaskRequest(_ path: String,
                                   parameters: [String: AnyObject]?,
                                   method: Alamofire.HTTPMethod = .get,
                                   completion: @escaping (_ result: AnyObject?, _ error: NSError?)->()?) -> URLSessionTask {
    
    // header
    var headers: [String: String]?
    headers = ["X-Token": "token",
               "X-GOGOTATTO-VERSION": "1",
               "X-Version": DeviceInfo.appVersion(),
               "User-Agent": "app_ios;\(DeviceInfo.systemVersion());\(DeviceInfo.appVersion());\(DeviceInfo.modelName());"]
    
    // encoding
    var encoding: ParameterEncoding?
    if method == .get {
      encoding = URLEncoding.default
    }
    if method == .post {
      encoding = JSONEncoding(options: [])
      //            encoding = CustomEncoding()
    }
    
    // path
    let URLString = Constant.Network.MainHost.ProductionIP.rawValue + path
    let request = Alamofire.request(URLString, method: method, parameters: parameters,
                                    encoding: encoding!, headers: headers)
    request.responseData(queue: self.netWorkQueue) {
      (response) in
      #if DEBUG
        //                print("### self.sessionTaskPool.count: ", self.sessionTaskPool.count)
      #endif
      
      self.netWorkQueue.async(flags: .barrier, execute: {
        if self.sessionTaskPool.contains(request.task!) {
          let index: Int = self.sessionTaskPool.index(of: request.task!)!
          if self.sessionTaskPool.count > index {
            self.sessionTaskPool.remove(at: index)
          }
        }
      })
      
      let error = response.result.error
      if error != nil {
        completion(nil, error! as NSError)
        return
      }
      if response.result.isSuccess {
        let data = response.result.value
        var dataArray: AnyObject?
        if data != nil && data?.count != nil {
          dataArray = self.dataToJSON(data!) as AnyObject
        }
        completion(dataArray, nil)
      } else {
        print("Request failed but no error in call back block, weird")
      }
    }
    return request.task!
  }
  
  /// Cancel datatask by ID
  func cancel(_ taskID: Int) {
    self.netWorkQueue.async(flags: .barrier, execute: {
      var index: Int?
      for task: URLSessionTask in self.sessionTaskPool {
        if task.taskIdentifier == taskID {
          task.cancel()
          index = self.sessionTaskPool.index(of: task)
          break
        }
      }
      if index != nil {
        self.sessionTaskPool.remove(at: index!)
      }
    })
  }
  
  func dataToJSON(_ data: Data) -> Any? {
    do {
      return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    } catch let error {
      print(error)
      return nil
    }
  }
  
}
