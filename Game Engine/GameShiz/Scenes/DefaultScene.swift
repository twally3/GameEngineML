import GameplayKit

class DefaultScene: Scene {
    let camera = DebugCamera()
    let sun = Sun()
    let plane = Plane()
    
    let mapWidth: Int = 100
    let mapHeight: Int = 100
    var noiseScale: Float = 25
    
    let octaves: Int = 4
    let persistance: Float = 0.5
    let lacunarity: Float = 2
    
    let seed: UInt64 = 1
    let offset = SIMD2<Int>(x: 0, y: 0)
    
    var regions: [TerrainType] = [
        TerrainType(height: 0.3, colour: SIMD4<Float>(66 / 255, 110 / 255, 202 / 255, 1.0)),        // Water Deep
        TerrainType(height: 0.4, colour: SIMD4<Float>(74 / 255, 113 / 255, 206 / 255, 1.0)),        // Water Shallow
        TerrainType(height: 0.45, colour: SIMD4<Float>(216 / 255, 218 / 255, 154 / 255, 1.0)),      // Sand
        TerrainType(height: 0.55, colour: SIMD4<Float>(100 / 255, 158 / 255, 32 / 255, 1.0)),       // Grass
        TerrainType(height: 0.6, colour: SIMD4<Float>(76 / 255, 116 / 255, 28 / 255, 1.0)),         // Grass 2
        TerrainType(height: 0.7, colour: SIMD4<Float>(100 / 255, 80 / 255, 75 / 255, 1.0)),         // Rock
        TerrainType(height: 0.9, colour: SIMD4<Float>(85 / 255, 70 / 255, 70 / 255, 1.0)),          // Rock 2
        TerrainType(height: 1, colour: SIMD4<Float>(255 / 255, 255 / 255, 255 / 255, 1.0))          // Snow
    ];
    
    override func buildScene() {
        camera.setPosition(0, 0, 4)
        addCamera(camera)
        
        sun.setPosition(0, 3, 0)
        addLight(sun)
        
        addPlane()
    }
    
    func addPlane() {
        let noiseMap = generateRandomTexture()
        
        let mapValuesBuffer = Engine.device!.makeBuffer(bytes: noiseMap, length: MemoryLayout<Float>.size * noiseMap.count, options: [])
        
        let texture = loadEmptyTexture()
        
        let computePipelineState = createComputePipelineState()
        
        loadTextureWithHeights(computePipelineState: computePipelineState, mapValuesBuffer: mapValuesBuffer!, texture: texture)
        
        plane.setMaterialIsLit(false)
        plane.setTexture(texture)
        addChild(plane)
    }
    
    func generateRandomTexture() -> [Float] {
        let noise = Noise.generateNoiseMap(mapWidth: mapWidth,
                                           mapHeight: mapHeight,
                                           seed: seed,
                                           scale: noiseScale,
                                           octaves: octaves,
                                           persistance: persistance,
                                           lacunarity: lacunarity,
                                           offset: offset)
        
        var mapValues: [Float] = []
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                mapValues.append(noise[x][y])
            }
        }
        
        return mapValues
    }
    
    public func loadEmptyTexture()->MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.width = mapWidth
        textureDescriptor.height = mapHeight
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.sampleCount = 1
        textureDescriptor.storageMode = .managed
        textureDescriptor.usage = [.shaderWrite, .shaderRead]
        
        let texture = Engine.device!.makeTexture(descriptor: textureDescriptor)
        return texture!
    }
    
    func createComputePipelineState() -> MTLComputePipelineState {
        do {
            return try Engine.device!.makeComputePipelineState(function: Graphics.shaders[.CreateHeightMap_Compute])
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func loadTextureWithHeights(computePipelineState: MTLComputePipelineState, mapValuesBuffer: MTLBuffer, texture: MTLTexture) {
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
    
    override func doUpdate() {
        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
            plane.rotateX(Mouse.getDY() * GameTime.deltaTime)
            plane.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
    }
}
