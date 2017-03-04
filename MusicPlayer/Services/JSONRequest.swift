
import Foundation

public class JSONNetworkRequest {
    
    private let url: URL
    private var task: URLSessionTask!
    
    public init(url: URL) {
        self.url = url
    }
    
    private var cancelled = false
    
    func convertToJSON(_ data: Data) -> (JSON?, String?) {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            return (nil, "JSON conversion failed")
        }
        return (JSON(jsonObject as AnyObject), nil)
    }
    
    public func startWithCompletion(_ completion: @escaping (Result<JSON>) -> Void) {
        let session = URLSession.shared
        cancelled = false
        
        task = session.dataTask(with: url) { [weak self] data, response, error in
            if (self == nil) {
                return
            }
            
            if self?.cancelled == true {
                return
            }
            
            guard let data = data else {
                completion(Result.failure(error!.localizedDescription))
                return
            }
            
            if  let response = response as? HTTPURLResponse, response.statusCode > 200 {
                completion(Result.failure("Unexpected status code"))
                return
            }
            
            
            DispatchQueue.main.async {
                
                if let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                completion(Result.success(JSON(object as AnyObject)))
                } else {
                    completion(Result.failure("Unexpected error occurred"))
                }
            }
        }
        task.resume()
    }
    
    public func cancel() {
        cancelled = true
        task.cancel()
    }
    
   
    deinit {
        task.cancel()
    }
    
}
