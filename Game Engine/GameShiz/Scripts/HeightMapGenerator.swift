class HeightMapGenerator {
    private static var falloffMap: [[Float]]?
    
    public static func generateHeightMap(width: Int, height: Int, settings: HeightMapSettings, sampleCentre: SIMD2<Float>) -> HeightMap {
        var values: [[Float]] = Noise.generateNoiseMap(mapWidth: width, mapHeight: height, settings: settings.noiseSettings, sampleCentre: sampleCentre)
        
        
        
        if settings.useFalloffMap == true {
             if HeightMapGenerator.falloffMap == nil {
                 HeightMapGenerator.falloffMap = FalloffGenerator.generateFalloffMap(size: width)
             }

             for i in 0..<width {
                 for j in 0..<height {
                     values[i][j] = min(max(values[i][j] - HeightMapGenerator.falloffMap![i][j], 0), 1)
                 }
             }
         }
        
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
