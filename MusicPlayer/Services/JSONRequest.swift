
import Foundation

public class JSONNetworkRequest {
    
    private let url: NSURL
    private var task: NSURLSessionTask!
    
    public init(url: NSURL) {
        self.url = url
    }
    
    func convertToJSON(data: NSData) -> (JSON?, String?) {
        guard let jsonObject = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) else {
            return (nil, "JSON conversion failed")
        }
        return (JSON(jsonObject), nil)
    }
    
    public func startWithCompletion(completion: Result<JSON> -> Void) {
        let session = NSURLSession.sharedSession()
        task = session.dataTaskWithURL(url) { data, response, error in
            
            guard let data = data else {
                completion(Result.Failure(error!.localizedDescription))
                return
            }
            
            if  let response = response as? NSHTTPURLResponse where response.statusCode > 200 {
                completion(Result.Failure("Unexpected status code"))
                return
            }
            
            
            dispatch_async(dispatch_get_main_queue()) {
                if let object = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
                completion(Result.Success(JSON(object)))
                } else {
                    completion(Result.Failure("Unexpected error occurred"))
                }
            }
        }
        task.resume()
    }
    
   
    deinit {
        task.cancel()
    }
    
}