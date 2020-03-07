import GameplayKit

class Noise {
    
    enum NormaliseMode {
        case global
        case local
    }
    
    static let normaliseMode: NormaliseMode = .global
    
    public static func generateNoiseMap(mapWidth: Int, mapHeight: Int, seed: UInt64, scale: Float, octaves: Int, persistance: Float, lacunarity: Float, offset: SIMD2<Int>) -> [[Float]] {
        var noiseMap: [[Float]] = Array(repeating: Array(repeating: Float(0), count: mapHeight), count: mapWidth)
        
        var prng = SeededRandom(seed: seed)
        
        var maxPossibleHeight: Float = 0
        var amplitude: Float = 1
        
        let octaveOffsets: [SIMD2<Int>] = {
            var x: [SIMD2<Int>] = []

            for _ in 0..<octaves {
                x.append(SIMD2<Int>(x: Int.random(in: -100000...100000, using: &prng) + offset.x,
                                    y: Int.random(in: -100000...100000, using: &prng) + offset.y))
                
                maxPossibleHeight += amplitude
                amplitude *= persistance
            }

            return x
        }()
        
        let _scale = scale <= 0 ? 0.0001 : scale
        
        var minLocalNoiseHeight: Float = Float.greatestFiniteMagnitude
        var maxLocalNoiseHeight: Float = -minLocalNoiseHeight
        
        let halfHeight: Float = Float(mapHeight) / 2.0
        let halfWidth: Float = Float(mapWidth) / 2.0
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                
                var amplitude: Float = 1
                var frequency: Float = 1
                var noiseHeight: Float = 0
                
                for i in 0..<octaves {
                    let sampleX = (Float(x) - halfWidth + Float(octaveOffsets[i].x)) / _scale * frequency
                    let sampleY = (Float(y) - halfHeight + Float(octaveOffsets[i].y)) / _scale * frequency
                    let sampleZ = 0 / _scale * frequency
                    
                    let perlinValue = map(x: Float(ImprovedNoise.noise(x: Double(sampleX), y: Double(sampleY), z: Double(sampleZ))),
                                          in_min: -sqrt(3/4), in_max: sqrt(3/4), out_min: -1, out_max: 1)
                    
                    noiseHeight += Float(perlinValue) * amplitude
                    
                    amplitude *= persistance
                    frequency *= lacunarity
                }
                
                if noiseHeight > maxLocalNoiseHeight {
                    maxLocalNoiseHeight = noiseHeight
                }
                if noiseHeight < minLocalNoiseHeight {
                    minLocalNoiseHeight = noiseHeight
                }
                
                noiseMap[x][y] = noiseHeight
            }
        }
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                if self.normaliseMode == .local {
                    noiseMap[x][y] = map(x: noiseMap[x][y], in_min: minLocalNoiseHeight, in_max: maxLocalNoiseHeight, out_min: 0, out_max: 1)
                } else if self.normaliseMode == .global {
                    let normalisedHeight: Float = (noiseMap[x][y] + 1) / (2 * maxPossibleHeight / 2)
                    noiseMap[x][y] =  max(0, normalisedHeight)
                    if (noiseMap[x][y] < 0) {
                        print(normalisedHeight)
                    }
                }
            }
        }
        
        print(maxPossibleHeight);
        
        return noiseMap
    }
    
    private static func map(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float) -> Float {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }
}
