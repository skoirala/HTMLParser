
internal protocol ADSpaceConcreteRequest {
    
    associatedtype T = ADSpaceViewContentType
    
    func request(path: String,
                 useBasePath: Bool,
                 completion: @escaping (Result<Self.T>) -> ())
}


internal struct ADSpaceImageRequest: ADSpaceConcreteRequest {
    typealias T = UIImage
}

internal struct ADSpaceJSONRequest: ADSpaceConcreteRequest {
    typealias T = JSON
}

internal struct ADSpaceHTMLRequest: ADSpaceConcreteRequest {
    typealias T = String
}
