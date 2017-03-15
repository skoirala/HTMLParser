
import Foundation

internal extension Array {
    internal func random() -> Element {
        let count = self.count
        let randomIndex = Int(arc4random_uniform(UInt32(count)))
        return self[randomIndex]
    }
}
