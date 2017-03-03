
import Foundation


public struct JSON {
    
    public let value: AnyObject
    
    public init(_ value: AnyObject) {
        self.value = value
    }
}

extension JSON {
    public func isArray() -> Bool {
        return self.value is [AnyObject]
    }
    
    public var string: String? {
        return value as? String
    }
    
    public var integer: Int? {
        return value as? Int
    }
    
    public var double: Double? {
        return value as? Double
    }
}

extension JSON {
    public subscript(index: String) -> JSON? {
        if let value = value as? [String: AnyObject], let indexedValue = value[index] {
            return JSON(indexedValue)
        }
        return nil
    }
}

extension JSON: Collection {
    
    public var startIndex: Int {
        if value is [AnyObject] {
            return 0
        }
        fatalError("cannot use collection methods for type \(type(of: value))")
    }
    
    public var endIndex: Int {
        if let value = value as? [AnyObject] {
            return value.count
        }
        fatalError("cannot use collection methods for type \(type(of: value))")
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public subscript(index: Int) -> JSON {
        if let value = value as? [AnyObject] {
            let item = value[index]
            return JSON(item)
        }
        fatalError("cannot use collection methods for type \(type(of: value))")
    }
    
    
}
