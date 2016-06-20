
import Foundation

public class HTMLParser {
    
    private let htmlDoc: htmlDocPtr
    
    public init(data: Data) {
        let bytes = UnsafePointer<Int8>((data as NSData).bytes)
        
        let options = HTML_PARSE_RECOVER.rawValue | HTML_PARSE_NOERROR.rawValue | HTML_PARSE_NOWARNING.rawValue
        htmlDoc = htmlReadMemory(bytes,
                                 Int32(data.count),
                                 nil,
                                 nil,
                                 Int32(options))
    }
    
    deinit {
        xmlFreeDoc(htmlDoc)
    }
}

//MARK:  Query methods

extension HTMLParser {
    
    public func rootNode() -> HTMLElement {
        let node = xmlDocGetRootElement(htmlDoc)        
        return HTMLElement(node: node!)!
    }
    
    
    public func children() -> HTMLElements {
        return rootNode().children
    }
    
    
    public func queryXPath(_ path: String) -> [HTMLElement] {
        var elements: [HTMLElements] = []
        
        let xPathContext = xmlXPathNewContext(htmlDoc)
        
        if xPathContext == nil {
            return []
        }
        
        let result = xmlXPathEval(path, xPathContext)
        if (result == nil) {
            return []
        }
        
        let nodeSetVal = result?.pointee.nodesetval
        
        if (nodeSetVal == nil) {
            xmlXPathFreeObject(result)
            xmlXPathFreeContext(xPathContext)
            return []
        }
        
        let numberOfNodes = Int((nodeSetVal?.pointee.nodeNr)!)
        let nodePtr = nodeSetVal?.pointee.nodeTab
        
        for i in 0 ..< numberOfNodes {
            elements.append(HTMLElements(node: (nodePtr?[i]!)!))
        }
        xmlXPathFreeContext(xPathContext)
        xmlXPathFreeObject(result)
        
        return elements.flatMap { $0 }
    }
}

