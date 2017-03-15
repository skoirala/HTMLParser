
internal struct ADSpaceURLRequest {
    private let session: URLSession
    
    private static func sharedInstance() -> ADSpaceURLRequest {
        struct __ { static let _sharedInstance = ADSpaceURLRequest() }
        return __._sharedInstance
    }
    
    
    static let `default`: ADSpaceURLRequest = {
        return ADSpaceURLRequest.sharedInstance()
    }();
    
    private init() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
    }
    
    public func request(url: URL, completion: @escaping (Result<Data>) -> ()) {
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, requestError: Error?) in
            guard let data = data else {
                defer { completion(.Failure(.UnderlyingError(requestError!))) }
                return
            }
            
            completion(.Success(data))
        }
        
        dataTask.resume()
    }
}
