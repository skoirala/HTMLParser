

extension xmlNode {
    
    func attributes(nodePtr: xmlNodePtr) -> [String: String] {
        
        var attributes: [String: String] = [:]
        
        var properties = self.properties
        
        while properties != nil {
            let name = properties.memory.name
            let value = xmlGetProp(nodePtr, name)
            
            let nameString = String.fromCString(UnsafePointer(name))
            let valueString = String.fromCString(UnsafePointer(value))
            
            if value != nil {
                xmlFree(value)
            }
            
            if let nameString = nameString, valueString = valueString {
                attributes[nameString] = valueString
            }
            
            properties = properties.memory.next
        }
        return attributes
    }
}