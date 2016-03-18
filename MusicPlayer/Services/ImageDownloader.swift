
import UIKit

public class ImageDownloader {
    
    public func imageForURL(URL: String, onDownloadCompletion completion: UIImage -> Void) -> UIImage? {
        let image = downloadedImages[URL]
        
        if image == nil {
            downloadImageForURL(URL, completion: completion)
        }
        return image
    }
    
    public func downloadImageForURL(URL: String, completion: UIImage -> Void) {
        precondition(downloadedImages[URL] == nil, "already downloaded image")
        
        if  downloadingImages.contains(URL) {
            return
        }
        
        downloadingImages.append(URL)
        
        dispatch_async(imageDownloadQueue) { [weak self] in
            if let data = NSData(contentsOfURL: NSURL(string: URL)!),
                image = UIImage(data: data) {
                dispatch_async(dispatch_get_main_queue()) {
                    if let indexOfDownloading = self?.downloadingImages.indexOf(URL) {
                        self?.downloadingImages.removeAtIndex(indexOfDownloading)
                    }
                    completion(image)
                    self?.downloadedImages[URL] = image
                }
                
            }
        }
    }
    
    private let imageDownloadQueue = dispatch_queue_create("com.imagerepository.queue", DISPATCH_QUEUE_SERIAL)
    private var downloadedImages: [String: UIImage] = [:]
    private var downloadingImages:[String] = []
}
