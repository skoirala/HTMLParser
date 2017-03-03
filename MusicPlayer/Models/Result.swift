
import Foundation

public enum Result<T> {
    case success(T)
    case failure(String)
}

extension Result {
    public func flatMap<U>(_ f: (T) -> ( result: U?, failure: String?)) -> Result<U> {
        if case .success(let t) = self {
            let out = f(t)
            
            guard let outU = out.result else {
                return Result<U>.failure(out.failure!)
            }
            return Result<U>.success(outU)
        }
        
        if case .failure(let error) = self {
            return Result<U>.failure(error)
        }
        fatalError("invalid state detected")
    }
}

