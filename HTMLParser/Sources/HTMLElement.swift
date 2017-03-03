
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
        
        if node.pointee.type == XML_TEXT_NODE {
            let rawContent = xmlNodeGetContent(node)
            
            if rawContent != nil {
                text = String(cString: UnsafePointer(rawContent!))
                xmlFree(rawContent)
            }
            
            text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if text?.characters.count == 0 {
                return nil
            }
            
        } else {
            name = String(cString: UnsafePointer(node.pointee.name))
        }
        
        self.name = name
        self.text = text
        self.children = HTMLElements(node: node)
        self.attributes = node.pointee.attributes(node)
    }
    

    public var isTextNode: Bool {
        return node.pointee.type == XML_TEXT_NODE
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
    
    
    private func findNestedChildElementsInArray(_ array: inout [HTMLElement], inNode node: xmlNodePtr) {
        var currentNode = node.pointee.children
        while  currentNode != nil {
            if let node = HTMLElement(node: currentNode!) {
                array.append(node)
                findNestedChildElementsInArray(&array, inNode: currentNode!)
            }
            currentNode = currentNode?.pointee.next
        }
    }
    
    
    private let node: xmlNodePtr
}
