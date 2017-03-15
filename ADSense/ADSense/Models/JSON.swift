
internal struct JSON {
    
    public let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    subscript(key: String) -> JSON? {
        guard let value = value as? [String: Any] else { return nil }
        
        guard let extractedValue = value[key] else { return nil }
        return JSON(value: extractedValue)
    }
}
