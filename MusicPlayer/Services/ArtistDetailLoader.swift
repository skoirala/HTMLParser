
import Foundation

precedencegroup OperationPrecendence {
    associativity: left
}

infix operator >> : OperationPrecedence

class ArtistDetailLoader {
    
    let queue = OperationQueue()
    
    let song: Song
    var parser: HTMLParser!
    
    init(song: Song) {
        self.song = song
    }
    
    
    func loadArtistDetail(_ completion: @escaping (ArtistDetail) -> Void) {
        
        var data: Data?
        var biographyText: String!
        var albums = [Album]()
        
        let dataOperation = BlockOperation { [weak self] in
            guard let artistURLString = self?.song.artistLink,
                let artistURL = URL(string: artistURLString),
                let artistLinkData = try? Data(contentsOf: artistURL)  else {
                    return
            }
            data = artistLinkData
        }
        
        
        let parseBiographyOperation = BlockOperation { [weak self] in
            
            guard let data = data else {
                self?.queue.cancelAllOperations()
                return
            }
            
            self?.parser = HTMLParser(data: data)
            
            let biography = self?.parser.queryXPath("//div[@id='biography']/div//p[@class='extra']/text()")
            
            guard let text = biography?.first?.text else {
                return
            }
            
            
            biographyText = text
        }
        
        let parseAlbumNamesOperation = BlockOperation { [weak self] in
            guard let xPathResult = self?.parser.queryXPath("//div[@class='swoosh lockup-container album music large']//div[@itemprop='album']") else { return }
            
            let albumNamePredicate = { (element: HTMLElement) in
                return element.name == "span" && element.attributes["itemprop"] == "name"
            }
            
            let albumLinkPredicate = { (element: HTMLElement) in
                return element.name == "a" && element.attributes["itemprop"] == "url" && element.attributes["class"] == "name"
            }
            
            let albumImageURLPredicate = { (element: HTMLElement) in
                element.name == "img" && element.attributes["class"] == "artwork"
            }
            
            let allChildElements = xPathResult
                .flatMap { $0.allNestedChildElements() }
            
            
            let albumNames = allChildElements
                .filter(albumNamePredicate)
                .flatMap { $0.childNodeText() }
            
            
            let albumLinks = allChildElements
                .filter(albumLinkPredicate)
                .flatMap { $0.attributes["href"] }
            
            let albumImageURLS = allChildElements
                .filter(albumImageURLPredicate)
                .flatMap { $0.attributes["src-swap-high-dpi"] }
            
            
            for (albumName, albumLink, albumImageURL) in zip3(albumNames,albumLinks, albumImageURLS) {
                albums.append(Album(name: albumName, albumLink:albumLink, imageURL: albumImageURL))
            }
        }
        
        let createArtistOperation = BlockOperation {
            let artistDetail = ArtistDetail(biography: biographyText, albums: albums)
            completion(artistDetail)
        }
        
        dataOperation >> parseBiographyOperation >> parseAlbumNamesOperation >> createArtistOperation
        queue.addOperations([dataOperation, parseBiographyOperation, parseAlbumNamesOperation], waitUntilFinished: false)
        OperationQueue.main.addOperation(createArtistOperation)
        
    }
}

