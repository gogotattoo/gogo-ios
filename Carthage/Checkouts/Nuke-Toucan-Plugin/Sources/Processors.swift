// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import Foundation
import Toucan
import Nuke

/// Processor in which you can wrap Toucan calls.
public struct Processor: Nuke.Processing {
    private let closure: (_ input: Toucan) -> Toucan?
    private let key: AnyHashable
    
    /// Initializes `Processor` with the given key and closure.
    /// - parameter key: Key is used to compare image processors. Equivalent
    /// image processors should have the same key.
    public init<Key: Hashable>(key: Key, closure: @escaping (_ input: Toucan) -> Toucan?) {
        self.key = AnyHashable(key)
        self.closure = closure
    }
    
    public func process(_ image: Image) -> Image? {
        return self.closure(Toucan(image: image))?.image
    }
    
    /// Returns true if the underlying processors are pairwise-equivalent.
    public static func ==(lhs: Processor, rhs: Processor) -> Bool {
        return lhs.key == rhs.key
    }
}

public extension Request {
    /// Appends a Toucan closure to the given request.
    /// - parameter key: Key is used to compare image processors. Equivalent
    /// image processors should have the same key.
    public mutating func process<Key: Hashable>(key: Key, closure: @escaping (Toucan) -> Toucan?) {
        process(with: Processor(key: key, closure: closure))
    }
    
    /// Appends a Toucan closure to the given request.
    /// - parameter key: Key is used to compare image processors. Equivalent
    /// image processors should have the same key.
    public func processed<Key: Hashable>(key: Key, closure: @escaping (Toucan) -> Toucan?) -> Request {
        return processed(with: Processor(key: key, closure: closure))
    }
}
