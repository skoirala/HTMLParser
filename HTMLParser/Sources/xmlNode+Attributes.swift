

extension xmlNode {
    
    func attributes(_ nodePtr: xmlNodePtr) -> [String: String] {
        
        var attributes: [String: String] = [:]
        
        var properties = self.properties
        
        while properties != nil {
            if let name = properties?.pointee.name,
                let value = xmlGetProp(nodePtr, name) {
            
                let nameString = String(cString: UnsafePointer(name))
                let valueString = String(cString: UnsafePointer(value))
                
                xmlFree(value)
                
                attributes[nameString] = valueString
            }
            
            
            properties = properties?.pointee.next
        }
        return attributes
    }
}
