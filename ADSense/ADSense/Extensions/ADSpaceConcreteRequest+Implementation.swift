

internal extension ADSpaceConcreteRequest where T == JSON {
    
    func request(path: String,
                 useBasePath: Bool = true,
                 completion: @escaping (Result<JSON>) -> ()) {
        
        var url: URL
        
        if (useBasePath) {
            url  = ADSpaceApiBaseURL.appendingPathComponent(path)
        } else {
            url = URL(string: path)!
        }
        
        ADSpaceURLRequest.default.request(url: url) { (result: Result<Data>) in
            
            switch result {
            case let .Success(data):
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data,
                                                                      options: .allowFragments)
                    completion(.Success(JSON(jsonObject)))
                } catch {
                    completion(.Failure(.UnderlyingError(error)))
                }
            case let .Failure(error):
                completion(.Failure(error))
                
            }
        }
    }
}


internal extension ADSpaceConcreteRequest where T == UIImage {
    
    func request(path: String,
                 useBasePath: Bool = true,
                 completion: @escaping (Result<UIImage>) -> ()) {
        
        
        var url: URL
        
        if (useBasePath) {
            url  = ADSpaceApiBaseURL.appendingPathComponent(path)
        } else {
            url = URL(string: path)!
        }
        
        ADSpaceURLRequest.default.request(url: url) { (result: Result<Data>) in
            switch result {
            case let .Success(data):
                guard let image = UIImage(data: data) else { completion(.Failure(.InvalidImage)); return }
                completion(.Success(image))
                
            case let .Failure(error):
                completion(.Failure(error))
            }
        }
    }
}


internal extension ADSpaceConcreteRequest where T == String {
    
    func request(path: String,
                 useBasePath: Bool = true,
                 completion: @escaping (Result<String>) -> ()) {
        
        
        var url: URL
        
        if (useBasePath) {
            url  = ADSpaceApiBaseURL.appendingPathComponent(path)
        } else {
            url = URL(string: path)!
        }
        
        ADSpaceURLRequest.default.request(url: url) { (result: Result<Data>) in
            
            
            switch result {
            case let .Success(data):
                
                guard let outputString = String(data: data, encoding: .utf8)
                    else { completion(.Failure(.InvalidHTMLEncoding)); return  }
                completion(.Success(outputString))
                
            case let .Failure(error):
                completion(.Failure(error))
            }
            
        }
    }
}
