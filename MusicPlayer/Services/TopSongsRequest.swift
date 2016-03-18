
import Foundation

public class TopSongsRequest {
    private lazy var iTunesTopSongsRequestURL: NSURL = {
        return NSURL(string: "https://itunes.apple.com/fi/rss/topsongs/limit=\(self.limit)/json")!
    }()
    
    private let limit: Int
    
    private var jsonRequest: JSONNetworkRequest!
        
    public init(limit: Int) {
        self.limit = limit
        jsonRequest = JSONNetworkRequest(url:iTunesTopSongsRequestURL)
    }
    
    public func startWithCompletion(completion: Result<[Song]> -> Void) {
        jsonRequest.startWithCompletion { result in
            self.handleResult(result, completion: completion)
        }
    }
}


extension TopSongsRequest {
    
    private func handleResult(result: Result<JSON>, completion: Result<[Song]> -> Void) {
        switch result {
        case .Failure(let message):
            completion(Result.Failure(message))
        case .Success(let json):
            let entry = json["feed"]?["entry"]
            if let entry = entry {
                let songs = entry.map(createSong)
                completion(Result.Success(songs))
                return
            }
            completion(Result.Failure("Unknown error occurred"))
        }
    }
    
    private func createSong(value: JSON) -> Song {
        let identifier = value["id"]?["attributes"]?["im:id"]?.string
        let identifierLink = value["id"]?["label"]?.string
        let artistName = value["im:artist"]?["label"]?.string
        let artistLink = value["im:artist"]?["attributes"]?["href"]?.string
        let smallImageURL = value["im:image"]?[0]["label"]?.string
        let mediumImageURL = value["im:image"]?[1]["label"]?.string
        let bigImageURL = value["im:image"]?[2]["label"]?.string
        let title = value["title"]?["label"]?.string
        
        let links = value["link"]
        
        let previewURLContainer = links?.filter { a in
            if a["attributes"]?["type"]?.string ?? "" == "audio/x-m4a" {
                return true
            }
            return false
            }.last
        
        
        return Song(identifier: identifier!,
                    identifierLink: identifierLink!,
                    title: title!,
                    artistName: artistName!,
                    artistLink: artistLink,
                    smallImageURL: smallImageURL,
                    mediumImageURL: mediumImageURL,
                    bigImageURL: bigImageURL,
                    previewURL: previewURLContainer?["attributes"]?["href"]?.string)
    }
}