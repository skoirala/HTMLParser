
import Foundation

public enum Result<T> {
    case Success(T)
    case Failure(String)
}

extension Result {
    public func flatMap<U>(f: T -> ( result: U?, failure: String?)) -> Result<U> {
        if case .Success(let t) = self {
            let out = f(t)
            
            guard let outU = out.result else {
                return Result<U>.Failure(out.failure!)
            }
            return Result<U>.Success(outU)
        }
        
        if case .Failure(let error) = self {
            return Result<U>.Failure(error)
        }
        fatalError("invalid state detected")
    }
}

