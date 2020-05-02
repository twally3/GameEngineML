import MetalKit

class MapGenerator {
    // Divisble by all even numbers up to 12 (for LOD)
    let mapChunkSize = 239
    
    var falloffMap: [[Float]]?
    
    // TODO: Change these to structs and eventually make a components system
    let _noiseData: NoiseData = NoiseData()
    let _terrainData: TerrainData = TerrainData()
    
    var regions: [TerrainType] = [
        TerrainType(height: 0, colour: SIMD4<Float>(46 / 255, 90 / 255, 182 / 255, 1.0)),        // Water Deep
        TerrainType(height: 0.3, colour: SIMD4<Float>(74 / 255, 113 / 255, 206 / 255, 1.0)),        // Water Shallow
        TerrainType(height: 0.4, colour: SIMD4<Float>(216 / 255, 218 / 255, 154 / 255, 1.0)),      // Sand
        TerrainType(height: 0.45, colour: SIMD4<Float>(100 / 255, 158 / 255, 32 / 255, 1.0)),       // Grass
        TerrainType(height: 0.55, colour: SIMD4<Float>(76 / 255, 116 / 255, 28 / 255, 1.0)),         // Grass 2
        TerrainType(height: 0.6, colour: SIMD4<Float>(100 / 255, 80 / 255, 75 / 255, 1.0)),         // Rock
        TerrainType(height: 0.7, colour: SIMD4<Float>(85 / 255, 70 / 255, 70 / 255, 1.0)),          // Rock 2
        TerrainType(height: 0.9, colour: SIMD4<Float>(255 / 255, 255 / 255, 255 / 255, 1.0))          // Snow
    ];
    
    let queue = DispatchQueue(label: "Map Generator")
    let dsem = DispatchSemaphore(value: 1)
       
    func requestMapData(centre: SIMD2<Int>, callback: @escaping (MapData) -> ()) {
        queue.async {
            let mapData = self.generateMapData(centre: centre)
            
            DispatchQueue.main.async {
                callback(mapData)
            }
        }
    }
    
    func generateMapData(centre: SIMD2<Int>) -> MapData {
        var noise = Noise.generateNoiseMap(mapWidth: mapChunkSize + 2,
                                            mapHeight: mapChunkSize + 2,
                                            seed: _noiseData.seed,
                                            scale: _noiseData.noiseScale,
                                            octaves: _noiseData.octaves,
                                            persistance: _noiseData.persistance,
                                            lacunarity: _noiseData.lacunarity,
                                            offset: centre &+ _noiseData.offset,
                                            normaliseMode: _noiseData.normaliseMode)
        
        if _terrainData.useFalloffMap == true {
            if self.falloffMap == nil {
                self.falloffMap = FalloffGenerator.generateFalloffMap(size: mapChunkSize + 2)
            }
            
            
            for i in 0..<noise.count {
                for j in 0..<noise[0].count {
                    noise[i][j] = min(max(noise[i][j] - self.falloffMap![i][j], 0), 1)
                }
            }
        }
        
        let noiseMap = generateRandomTexture(noise)
        
        let mapValuesBuffer = Engine.device!.makeBuffer(bytes: noiseMap, length: MemoryLayout<Float>.size * noiseMap.count, options: [])

        let texture = loadEmptyTexture()
        
        let computePipelineState = createComputePipelineState()
        
        loadTextureWithHeights(computePipelineState: computePipelineState, mapValuesBuffer: mapValuesBuffer!, texture: texture)
        
        return MapData(noiseMap: noise, texture: texture)
    }
    
    private func generateRandomTexture(_ noise: [[Float]]) -> [Float] {
        var mapValues: [Float] = []
        
        for y in 0..<mapChunkSize {
            for x in 0..<mapChunkSize {
                mapValues.append(noise[x][y])
            }
        }
        
        return mapValues
    }
    
    private func loadEmptyTexture()->MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.width = mapChunkSize
        textureDescriptor.height = mapChunkSize
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.sampleCount = 1
//        textureDescriptor.storageMode = .managed
        textureDescriptor.usage = [.shaderWrite, .shaderRead]
        
        let texture = Engine.device!.makeTexture(descriptor: textureDescriptor)
        return texture!
    }
    
    private func createComputePipelineState() -> MTLComputePipelineState {
        do {
            return try Engine.device!.makeComputePipelineState(function: Graphics.shaders[.CreateHeightMap_Compute])
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    private func loadTextureWithHeights(computePipelineState: MTLComputePipelineState, mapValuesBuffer: MTLBuffer, texture: MTLTexture) {
        let commandQueue = Engine.commandQueue
        let commandBuffer = commandQueue!.makeCommandBuffer()
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeCommandEncoder?.setComputePipelineState(computePipelineState)
        
        computeCommandEncoder?.setTexture(texture, index: 0)
        computeCommandEncoder?.setBuffer(mapValuesBuffer, offset: 0, index: 0)
        
        var regionCount = regions.count
        computeCommandEncoder?.setBytes(&regions, length: TerrainType.stride(regions.count), index: 1)
        computeCommandEncoder?.setBytes(&regionCount, length: Int32.size, index: 2)
        
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSize(width: (texture.width + w - 1) / w,
                                          height: (texture.height + h - 1) / h,
                                          depth: 1)
        
        computeCommandEncoder!.dispatchThreadgroups(threadgroupsPerGrid,
                                                   threadsPerThreadgroup: threadsPerThreadgroup)
        computeCommandEncoder?.endEncoding()
        commandBuffer?.commit()
    }
}

struct MapData {
    var noiseMap: [[Float]]
    var texture: MTLTexture
}

struct TerrainType: sizeable {
//    var name: String
    var height: Float
    var colour: SIMD4<Float>
}
