import GameplayKit

class Noise {
    public static func generateNoiseMap(mapWidth: Int, mapHeight: Int, seed: UInt64, scale: Float, octaves: Int, persistance: Float, lacunarity: Float, offset: SIMD2<Int>) -> [[Float]] {
        var noiseMap: [[Float]] = Array(repeating: Array(repeating: Float(0), count: mapHeight), count: mapWidth)
        
        var prng = SeededRandom(seed: seed)
        let octaveOffsets: [SIMD2<Int>] = {
            var x: [SIMD2<Int>] = []

            for _ in 0..<octaves {
                x.append(SIMD2<Int>(x: Int.random(in: -100000...100000, using: &prng) + offset.x,
                                    y: Int.random(in: -100000...100000, using: &prng) + offset.y))
            }

            return x
        }()
        
        let _scale = scale <= 0 ? 0.0001 : scale
        
        var minNoiseHeight: Float = Float.greatestFiniteMagnitude
        var maxNoiseHeight: Float = -minNoiseHeight
        
        let halfHeight: Float = Float(mapHeight) / 2.0
        let halfWidth: Float = Float(mapWidth) / 2.0
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                
                var amplitude: Float = 1
                var frequency: Float = 1
                var noiseHeight: Float = 0
                
                for i in 0..<octaves {
                    let sampleX = (Float(x) - halfWidth) / _scale * frequency + Float(octaveOffsets[i].x)
                    let sampleY = (Float(y) - halfHeight) / _scale * frequency + Float(octaveOffsets[i].y)
                    let sampleZ = 0 / _scale * frequency
                    
                    let perlinValue = map(x: Float(ImprovedNoise.noise(x: Double(sampleX), y: Double(sampleY), z: Double(sampleZ))),
                                          in_min: -sqrt(3/4), in_max: sqrt(3/4), out_min: -1, out_max: 1)
                    
                    noiseHeight += Float(perlinValue) * amplitude
                    
                    amplitude *= persistance
                    frequency *= lacunarity
                }
                
                if noiseHeight > maxNoiseHeight {
                    maxNoiseHeight = noiseHeight
                }
                if noiseHeight < minNoiseHeight {
                    minNoiseHeight = noiseHeight
                }
                
                noiseMap[x][y] = noiseHeight
            }
        }
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                noiseMap[x][y] = map(x: noiseMap[x][y], in_min: minNoiseHeight, in_max: maxNoiseHeight, out_min: 0, out_max: 1)
            }
        }
        
        return noiseMap
    }
    
    private static func map(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float) -> Float {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }
}
