

public struct HTMLElementGenerator: GeneratorType {
    
    private var node: xmlNodePtr
    
    init(node: xmlNodePtr) {
        self.node = node
    }
    
    mutating public func next() -> HTMLElement? {
        
        if node == nil {
            return nil
        }
        
        let tempNode = node
        node = node.memory.next
        
        return HTMLElement(node: tempNode)
    }
}
