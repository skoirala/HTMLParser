
import Foundation

func >>(operation1: NSOperation, operation2: NSOperation) -> NSOperation {
    operation2.addDependency(operation1)
    return operation2
}
