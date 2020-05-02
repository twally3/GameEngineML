class TerrainData {
    // meshHeightCurve
    // useFlatShading
    
    let meshHeightMultiplier: Float = 110
    
    var useFalloffMap: Bool = false
    
    let uniformScale: Float = 1
    
    var minHeight: Float {
        get {
            return uniformScale * meshHeightMultiplier * 1 // This would be the height curve
        }
    }
    
    var maxHeight: Float {
        get {
            return uniformScale * meshHeightMultiplier * 0 // This would be the height curve
        }
    }
}
