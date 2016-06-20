
import Foundation

class AlbumDetailLoader {
    
    let album: Album
    
    let queue = OperationQueue()
    
    init(album: Album) {
        self.album = album
    }
    
    func loadAlbumDetail(_ completion: ([AlbumDetail]) -> Void) {
        
        var albumSongs: [AlbumDetail] = []
        
        var data: Data?
        
        let downloadData = BlockOperation { [weak self] in
            guard let album = self?.album , let albumURL  = URL(string:album.albumLink), let responseData = try? Data(contentsOf: albumURL) else {
                self?.queue.cancelAllOperations()
                return
            }
            data = responseData
        }
        
        let parseDataOperation = BlockOperation {
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
        
        let notifyOperation = BlockOperation {
            completion(albumSongs)
        }
        
        downloadData >> parseDataOperation >> notifyOperation
        queue.addOperations([downloadData, parseDataOperation], waitUntilFinished: false)
        OperationQueue.main().addOperation(notifyOperation)
    }
    
}

infix operator >> { associativity left precedence 200 }
