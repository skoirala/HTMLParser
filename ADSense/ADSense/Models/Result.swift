
internal enum Result<T> {
    case Success(T)
    case Failure(ResultError)
}
