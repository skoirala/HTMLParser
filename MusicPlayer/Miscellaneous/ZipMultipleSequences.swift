

public func zip3<T1: SequenceType,
                 T2: SequenceType,
                 T3: SequenceType>(a: T1, _ b: T2, _ c: T3) ->
    [(T1.Generator.Element, T2.Generator.Element, T3.Generator.Element)] {
        return zip(zip(a, b), c).flatMap { a, b in return (a.0, a.1, b) }
}
