import GameplayKit

class Noise {
//    public static func generateNoiseMap(mapWidth: Int, mapHeight: Int, scale: Float) -> [[Float]] {
//        let perlinNoiseSource = GKPerlinNoiseSource.init()
//        perlinNoiseSource.seed = Int32(arc4random_uniform(1000000))
//        let noise = GKNoise(perlinNoiseSource)
//        let perlinNoise = GKNoiseMap(noise)
//
//        var noiseMap: [[Float]] = Array(repeating: Array(repeating: Float(0), count: mapHeight), count: mapWidth)
//
//        var minHeightValue: Float = Float.greatestFiniteMagnitude
//        var maxHeightValue: Float = -Float.greatestFiniteMagnitude
//
//        for y in 0..<mapHeight {
//            for x in 0..<mapWidth {
//                let sampleX = Int32(Double(x) / Double(scale))
//                let sampleY = Int32(Double(y) / Double(scale))
//
//                let perlinValue = perlinNoise.value(at: vector_int2(sampleX, sampleY))
//                print(perlinValue)
//                noiseMap[x][y] = map(x: perlinValue, in_min: -1.0, in_max: 1.0, out_min: 0.0, out_max: 1.0)
//
//                if (perlinValue > maxHeightValue) {
//                    maxHeightValue = perlinValue
//                }
//                if (perlinValue < minHeightValue) {
//                    minHeightValue = perlinValue
//                }
//            }
//        }
//
//        print("---")
//        print(minHeightValue)
//        print(maxHeightValue)
//        print("---")
//        print(map(x: minHeightValue, in_min: -1.0, in_max: 1.0, out_min: 0.0, out_max: 1.0))
//        print(map(x: maxHeightValue, in_min: -1.0, in_max: 1.0, out_min: 0.0, out_max: 1.0))
//        print("---")
//        print(perlinNoiseSource.seed)
//        print("---")
//
//        return noiseMap
//    }
    
    public static func generateNoiseMap(mapWidth: Int, mapHeight: Int, scale: Float) -> [[Float]] {
        var noiseMap: [[Float]] = Array(repeating: Array(repeating: Float(0), count: mapHeight), count: mapWidth)
        
        let min = -sqrt(Double(3) / Double(4))
        let max = sqrt(Double(3) / Double(4))
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                let sampleX = Float(x) / scale
                let sampleY = Float(y) / scale
                let sampleZ = 0 / scale

                
                let perlinValue = ImprovedNoise.noise(x: Double(sampleX), y: Double(sampleY), z: Double(sampleZ))
                noiseMap[x][y] = map(x: Float(perlinValue), in_min: Float(min), in_max: Float(max), out_min: 0.0, out_max: 1.0)
            }
        }
        
        return noiseMap
    }
    
    private static func map(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float) -> Float {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }
}
