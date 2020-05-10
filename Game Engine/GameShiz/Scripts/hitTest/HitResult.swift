struct HitResult {
    var node: Node
    var parameter: Float
    
    static func < (_ lhs: HitResult, _ rhs: HitResult) -> Bool {
        return lhs.parameter < rhs.parameter
    }
}
