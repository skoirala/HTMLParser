
public struct HTMLElements {
    
    private let node: xmlNodePtr
    
    init(node: xmlNodePtr) {
        self.node = node
    }
}

extension HTMLElements: SequenceType {
    public func generate() -> HTMLElementGenerator {
        return HTMLElementGenerator(node: node)
    }
}

