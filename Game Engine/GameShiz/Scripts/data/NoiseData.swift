class NoiseData {
    var noiseScale: Float = 80
    
    // min 0
    let octaves: Int = 4
    let persistance: Float = 0.5
    
    // max 1
    let lacunarity: Float = 2
    
    let seed: UInt64 = 1
    let offset = SIMD2<Int>(x: 0, y: 0)
    
    let normaliseMode: Noise.NormaliseMode = .global
}
