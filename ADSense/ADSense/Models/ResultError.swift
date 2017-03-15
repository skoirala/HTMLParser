
internal enum ResultError: Error {
    case TransformationError
    case InvalidURL
    case InvalidImage
    case InvalidHTMLEncoding
    case UnderlyingError(Error)
}
