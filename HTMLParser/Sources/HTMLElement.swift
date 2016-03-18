
import Foundation

public struct HTMLElement {
    
    public let name: String?
    public let text: String?
    public let attributes: [String: String]
    public let children: HTMLElements

    public init?(node: xmlNodePtr) {
        self.node = node
        var name: String? = nil
        var text: String? = nil
        
        if node.memory.type == XML_TEXT_NODE {
            let rawContent = xmlNodeGetContent(node)
            
            if rawContent != nil {
                text = String.fromCString(UnsafePointer(rawContent))
                xmlFree(rawContent)
            }
            
            text = text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            if text?.characters.count == 0 {
                return nil
            }
            
        } else {
            name = String.fromCString(UnsafePointer(node.memory.name))
        }
        
        self.name = name
        self.text = text
        self.children = HTMLElements(node: node)
        self.attributes = node.memory.attributes(node)
    }
    

    public var isTextNode: Bool {
        return node.memory.type == XML_TEXT_NODE
    }
    
    
    public func childNodeText() -> String? {
        return allNestedChildElements()
            .filter { $0.isTextNode }
            .flatMap { $0.text }.first
    }
    
    
    public func allNestedChildElements() -> [HTMLElement] {
        var array = [HTMLElement]()
        findNestedChildElementsInArray(&array, inNode: node)
        return array
    }
    
    
    private func findNestedChildElementsInArray(inout array: [HTMLElement], inNode node: xmlNodePtr) {
        var currentNode = node.memory.children
        while  currentNode != nil {
            if let node = HTMLElement(node: currentNode) {
                array.append(node)
                findNestedChildElementsInArray(&array, inNode: currentNode)
            }
            currentNode = currentNode.memory.next
        }
    }
    
    
    private let node: xmlNodePtr
}
