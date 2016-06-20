
import UIKit

public class ImageDownloader {
    
    @discardableResult
    public func imageForURL(_ URL: String, onDownloadCompletion completion: (UIImage) -> Void) -> UIImage? {
        let image = downloadedImages[URL]
        
        if image == nil {
            downloadImageForURL(URL, completion: completion)
        }
        return image
    }
    
    public func downloadImageForURL(_ URL: String, completion: (UIImage) -> Void) {
        precondition(downloadedImages[URL] == nil, "already downloaded image")
        
        if  downloadingImages.contains(URL) {
            return
        }
        
        downloadingImages.append(URL)
        
        imageDownloadQueue.async { [weak self] in
            if let data = try? Data(contentsOf: Foundation.URL(string: URL)!),
                image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let indexOfDownloading = self?.downloadingImages.index(of: URL) {
                        self?.downloadingImages.remove(at: indexOfDownloading)
                    }
                    completion(image)
                    self?.downloadedImages[URL] = image
                }
                
            }
        }
    }
    
    private let imageDownloadQueue = DispatchQueue(label: "com.imagerepository.queue", attributes: DispatchQueueAttributes.serial)
    private var downloadedImages: [String: UIImage] = [:]
    private var downloadingImages:[String] = []
}
