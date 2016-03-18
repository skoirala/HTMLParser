
import HTMLParser


class AlbumDetailLoader {
    
    let album: Album
    
    let queue = NSOperationQueue()
    
    init(album: Album) {
        self.album = album
    }
    
    func loadAlbumDetail(completion: [AlbumDetail] -> Void) {
        
        var albumSongs: [AlbumDetail] = []
        
        var data: NSData?
        
        let downloadData = NSBlockOperation { [weak self] in
            guard let album = self?.album , let albumURL  = NSURL(string:album.albumLink), let responseData = NSData(contentsOfURL: albumURL) else {
                self?.queue.cancelAllOperations()
                return
            }
            data = responseData
        }
        
        let parseDataOperation = NSBlockOperation {
            guard let data = data else { return }
            let parser = HTMLParser(data: data)
            let rowElements = parser.queryXPath("//div[@class='track-list album music']//tbody//tr")
            
            let previewUrls  = rowElements.map {
                $0.attributes["audio-preview-url"]
                }.flatMap { $0 }
            
            let namePredicate = { (element: HTMLElement) in
                return element.name == "span" && element.attributes["itemprop"] == "name"
            }
            
            let names = rowElements.map {
                $0.allNestedChildElements().filter(namePredicate).first?.childNodeText()
                }.flatMap { $0 }
            
            
            albumSongs = zip(names, previewUrls).map { (a, b) in
                return AlbumDetail(name: a, previewURL: b)
            }
        }
        
        let notifyOperation = NSBlockOperation {
            completion(albumSongs)
        }
        
        downloadData >> parseDataOperation >> notifyOperation
        queue.addOperations([downloadData, parseDataOperation], waitUntilFinished: false)
        NSOperationQueue.mainQueue().addOperation(notifyOperation)
    }
    
}

infix operator >> { associativity left precedence 200 }
