
import Foundation

public class TopSongsRequest {
    let URLFormat = "https://itunes.apple.com/%@/rss/topsongs/limit=%d/json"
    
    
    private var jsonRequest: JSONNetworkRequest!
        
    public init(countryIdentifier: String, limit: Int) {
        let url = URL(string:String(format: URLFormat, countryIdentifier, limit))!
        jsonRequest = JSONNetworkRequest(url:url)
    }
    
    public func startWithCompletion(_ completion: @escaping (Result<[Song]>) -> Void) {
        jsonRequest.startWithCompletion { result in
            self.handleResult(result, completion: completion)
        }
    }
}


extension TopSongsRequest {
    
    internal func handleResult(_ result: Result<JSON>, completion: (Result<[Song]>) -> Void) {
        switch result {
        case .failure(let message):
            completion(Result.failure(message))
        case .success(let json):
            let entry = json["feed"]?["entry"]
            if let entry = entry {
                let songs = entry.map(createSong)
                completion(Result.success(songs))
                return
            }
            completion(Result.failure("Unknown error occurred"))
        }
    }
    
    private func createSong(_ value: JSON) -> Song {
        let identifier = value["id"]?["attributes"]?["im:id"]?.string
        let identifierLink = value["id"]?["label"]?.string
        let artistName = value["im:artist"]?["label"]?.string
        let artistLink = value["im:artist"]?["attributes"]?["href"]?.string
        let smallImageURL = value["im:image"]?[0]["label"]?.string
        let mediumImageURL = value["im:image"]?[1]["label"]?.string
        let bigImageURL = value["im:image"]?[2]["label"]?.string
        let title = value["title"]?["label"]?.string
        
        let links = value["link"]
        
        var previewURL: String? = nil
        
        if let links = links, links.isArray() == true {
            let previewURLContainer = links.filter { a in
                return (a["attributes"]?["type"]?.string)! == "audio/x-m4a" }.flatMap {
                    return $0["attributes"]?["href"]
            }
            previewURL = previewURLContainer.last!.string
        }
        
        
        
        return Song(identifier: identifier!,
                    identifierLink: identifierLink!,
                    title: title!,
                    artistName: artistName!,
                    artistLink: artistLink,
                    smallImageURL: smallImageURL,
                    mediumImageURL: mediumImageURL,
                    bigImageURL: bigImageURL,
                    previewURL: previewURL)
    }
}
