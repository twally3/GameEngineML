class HeightMapGenerator {
    public static func generateHeightMap(width: Int, height: Int, settings: HeightMapSettings, sampleCentre: SIMD2<Float>) -> HeightMap {
        var values: [[Float]] = Noise.generateNoiseMap(mapWidth: width, mapHeight: height, settings: settings.noiseSettings, sampleCentre: sampleCentre)
        
        var minValue: Float = Float.greatestFiniteMagnitude
        var maxValue: Float = -minValue
        
        for i in 0..<width {
            for j in 0..<height {
                values[i][j] *= settings.heightMultiplier
                
                if values[i][j] > maxValue {
                    maxValue = values[i][j]
                }
                
                if values[i][j] < minValue {
                    minValue = values[i][j]
                }
            }
        }
        
        return HeightMap(values: values, minValue: minValue, maxValue: maxValue)
    }
}

struct HeightMap {
    var values: [[Float]]
    var minValue: Float
    var maxValue: Float
}
