

public func zip3<T1: Sequence,
                 T2: Sequence,
                 T3: Sequence>(_ a: T1, _ b: T2, _ c: T3) ->
    [(T1.Iterator.Element, T2.Iterator.Element, T3.Iterator.Element)] {
        return zip(zip(a, b), c).flatMap { a, b in return (a.0, a.1, b) }
}
