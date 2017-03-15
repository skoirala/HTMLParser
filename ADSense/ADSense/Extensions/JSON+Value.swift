internal extension JSON {
    
    var string: String {
        return value as! String
    }
    
    var int: Int {
        return value as! Int
    }
    
    var cgFloat: CGFloat {
        return value as! CGFloat
    }
    
    var float: Float {
        return value as! Float
    }
}
