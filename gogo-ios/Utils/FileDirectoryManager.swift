//
//  FileDirectoryManager.swift
//  gogo-ios
//
//  Created by Hongli Yu on 13/10/2016.
//  Copyright © 2016 italki. All rights reserved.
//

import Foundation

final class FileDirectoryManager {
    
    class func libraryDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last!
    }
    
    class func documentDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    }
    
    class func preferencePanesDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.preferencePanesDirectory, .userDomainMask, true).last!
    }
    
    class func cachesDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!
    }

}
