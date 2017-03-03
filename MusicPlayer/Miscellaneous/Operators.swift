
import Foundation

@discardableResult
func >>(operation1: Operation, operation2: Operation) -> Operation {
    operation2.addDependency(operation1)
    return operation2
}
