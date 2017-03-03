
import Foundation

public class HTMLParser {
    
    internal let htmlDoc: htmlDocPtr
    
    public init(data: Data) {
        
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        defer { bytes.deallocate(capacity: data.count) }
        data.copyBytes(to: bytes, count: data.count)
        let cBuffer = UnsafeRawPointer(bytes).assumingMemoryBound(to: CChar.self)
        

        let encoding = String.Encoding.utf8
        let cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
        let cfEncodingAsString: CFString = CFStringConvertEncodingToIANACharSetName(cfEncoding)
        let cEncoding: UnsafePointer<CChar>? = CFStringGetCStringPtr(cfEncodingAsString, 0)
        

        let options = CInt(HTML_PARSE_RECOVER.rawValue | HTML_PARSE_NOWARNING.rawValue | HTML_PARSE_NOERROR.rawValue)
        
        htmlDoc = htmlReadMemory(cBuffer,
                                 CInt(data.count),
                                 nil,
                                 cEncoding,
                                 options)
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

