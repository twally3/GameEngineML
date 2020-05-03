import GameplayKit

class Noise {
    
    enum NormaliseMode {
        case global
        case local
    }
        
    public static func generateNoiseMap(mapWidth: Int, mapHeight: Int, settings: NoiseSettings, sampleCentre: SIMD2<Float>) -> [[Float]] {
        var noiseMap: [[Float]] = Array(repeating: Array(repeating: Float(0), count: mapHeight), count: mapWidth)
        
        var prng = SeededRandom(seed: settings.seed)
        
        var maxPossibleHeight: Float = 0
        var amplitude: Float = 1
        
        let octaveOffsets: [SIMD2<Float>] = {
            var x: [SIMD2<Float>] = []

            for _ in 0..<settings.octaves {
                x.append(SIMD2<Float>(x: Float(Int.random(in: -100000...100000, using: &prng)) + Float(settings.offset.x) + sampleCentre.x,
                                      y: Float(Int.random(in: -100000...100000, using: &prng)) + Float(settings.offset.y) + sampleCentre.y))
                
                maxPossibleHeight += amplitude
                amplitude *= settings.persistance
            }

            return x
        }()
                
        var minLocalNoiseHeight: Float = Float.greatestFiniteMagnitude
        var maxLocalNoiseHeight: Float = -minLocalNoiseHeight
        
        let halfHeight: Float = Float(mapHeight) / 2.0
        let halfWidth: Float = Float(mapWidth) / 2.0
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                
                var amplitude: Float = 1
                var frequency: Float = 1
                var noiseHeight: Float = 0
                
                for i in 0..<settings.octaves {
                    let sampleX = (Float(x) - halfWidth + octaveOffsets[i].x) / settings.scale * frequency
                    let sampleY = (Float(y) - halfHeight + octaveOffsets[i].y) / settings.scale * frequency
                    let sampleZ = 0 / settings.scale * frequency
                    
                    let perlinValue = map(x: Float(ImprovedNoise.noise(x: Double(sampleX), y: Double(sampleY), z: Double(sampleZ))),
                                          in_min: -sqrt(3/4), in_max: sqrt(3/4), out_min: -1, out_max: 1)
                    
                    noiseHeight += Float(perlinValue) * amplitude
                    
                    amplitude *= settings.persistance
                    frequency *= settings.lacunarity
                }
                
                if noiseHeight > maxLocalNoiseHeight {
                    maxLocalNoiseHeight = noiseHeight
                }
                if noiseHeight < minLocalNoiseHeight {
                    minLocalNoiseHeight = noiseHeight
                }
                
                noiseMap[x][y] = noiseHeight
                
                if settings.normaliseMode == .global {
                    let normalisedHeight: Float = (noiseMap[x][y] + 1) / (2 * maxPossibleHeight / 2)
                    noiseMap[x][y] =  max(0, normalisedHeight)
                }
            }
        }
        
        if settings.normaliseMode == .local {
            for y in 0..<mapHeight {
                for x in 0..<mapWidth {
                    noiseMap[x][y] = map(x: noiseMap[x][y], in_min: minLocalNoiseHeight, in_max: maxLocalNoiseHeight, out_min: 0, out_max: 1)
                }
            }
        }
        
        return noiseMap
    }
    
    private static func map(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float) -> Float {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }
}

class NoiseSettings {
    let normaliseMode: Noise.NormaliseMode = .global
    var scale: Float = 80
    
    // min 0
    var octaves: Int = 4
    var persistance: Float = 0.5
    
    // max 1
    var lacunarity: Float = 2
    
    let seed: UInt64 = 1
    let offset = SIMD2<Int>(x: 0, y: 0)
    
    public func validateValues() {
        scale = max(scale, 0.01)
        octaves = max(octaves, 1)
        lacunarity = max(lacunarity, 1)
        persistance = min(max(persistance, 0), 1)
    }
}
