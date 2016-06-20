
public struct HTMLElements {
    
    private let node: xmlNodePtr
    
    init(node: xmlNodePtr) {
        self.node = node
    }
}

extension HTMLElements: Sequence {
    public func makeIterator() -> HTMLElementGenerator {
        return HTMLElementGenerator(node: node)
    }
}

