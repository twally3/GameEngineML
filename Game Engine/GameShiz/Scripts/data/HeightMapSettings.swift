class HeightMapSettings {
    var noiseSettings = NoiseSettings()
    
    // meshHeightCurve
    var useFalloffMap: Bool = true
    let heightMultiplier: Float = 110
    
    var minHeight: Float {
        get {
            return heightMultiplier * 1 // This would be the height curve
        }
    }
    
    var maxHeight: Float {
        get {
            return heightMultiplier * 0 // This would be the height curve
        }
    }
    
    init() {
        noiseSettings.validateValues()
    }
}
