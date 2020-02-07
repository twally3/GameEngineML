import GameplayKit

class DefaultScene: Scene {
    let camera = DebugCamera()
    let sun = Sun()
    let plane = Plane()
    
    var terrain: Terrain!
    
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
        camera.setPosition(0, 0, 10)
        addCamera(camera)
        
        sun.setPosition(0, 5, 0)
        sun.setMaterialIsLit(false)
        addLight(sun)
        
        addPlane()
    }
    
    func addPlane() {
        let noise = Noise.generateNoiseMap(mapWidth: mapWidth,
                                            mapHeight: mapHeight,
                                            seed: seed,
                                            scale: noiseScale,
                                            octaves: octaves,
                                            persistance: persistance,
                                            lacunarity: lacunarity,
                                            offset: offset)
        
        let noiseMap = generateRandomTexture(noise)
        
        let mapValuesBuffer = Engine.device!.makeBuffer(bytes: noiseMap, length: MemoryLayout<Float>.size * noiseMap.count, options: [])
        
        let texture = loadEmptyTexture()
        
        let computePipelineState = createComputePipelineState()
        
        loadTextureWithHeights(computePipelineState: computePipelineState, mapValuesBuffer: mapValuesBuffer!, texture: texture)
        
        terrain = Terrain(heightMap: noise)
        terrain.setTexture(texture)
        addChild(terrain)
    }
    
    func generateRandomTexture(_ noise: [[Float]]) -> [Float] {
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
            terrain!.rotateX(Mouse.getDY() * GameTime.deltaTime)
            terrain!.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
    }
}

class Terrain_CustomMesh: CustomMesh {
    var heightMap: [[Float]]!
    
    init(heightMap: [[Float]]) {
        self.heightMap = heightMap
        super.init()
    }
    
    override func createMesh() {
        let height = heightMap[0].count
        let width = heightMap.count
        
        // TODO: Delete me
        for y in 0..<height {
            for x in 0..<width {
                heightMap[x][y] *= 15
            }
        }
        
        for y in 0..<height {
            for x in 0..<width {
                let xf = Float(x)
                let yf = Float(y)
                
                let _x = xf - (Float(width) / 2)
                let _y = yf - (Float(height) / 2)
                
                let _w = Float(width)
                let _h = Float(height)
                
                if (x < width - 1 && y < height - 1) {
                    addVertex(position: SIMD3<Float>(_x + 1,    heightMap[x + 1][y],    _y),
                              colour: SIMD4<Float>(1, 0, 0, 1),
                              textureCoordinate: SIMD2<Float>((xf + 1) / _w, yf / _h))

                    addVertex(position: SIMD3<Float>(_x,        heightMap[x][y],        _y),
                              colour: SIMD4<Float>(1, 0, 0, 1),
                              textureCoordinate: SIMD2<Float>(xf / _w, yf / _h))

                    addVertex(position: SIMD3<Float>(_x,        heightMap[x][y + 1],    _y + 1),
                              colour: SIMD4<Float>(1, 0, 0, 1),
                              textureCoordinate: SIMD2<Float>(xf / _w, (yf + 1) / _h))

                    addVertex(position: SIMD3<Float>(_x + 1,    heightMap[x + 1][y + 1],_y + 1),
                              colour: SIMD4<Float>(1, 0, 0, 1),
                              textureCoordinate: SIMD2<Float>((xf + 1) / _w, (yf + 1) / _h))

                    
                    let startIndex = (y * (width - 1) + x) * 4
                    let idxs = [startIndex, startIndex + 1, startIndex + 2, startIndex, startIndex + 2, startIndex + 3]
                    let idxs2: [UInt32] = idxs.map { (x) -> UInt32 in
                        UInt32(x)
                    }

                    addIndices(idxs2)
                }
            }
        }
    }
}

class Terrain: GameObject {
    init(heightMap: [[Float]]) {
        super.init(name: "Terrain", meshType: .None)
        
        let mesh = Terrain_CustomMesh(heightMap: heightMap)
        setMesh(mesh)
        
        setMaterialIsLit(true)
        setRotationX(0.5)
        setScale(SIMD3<Float>(repeating: 0.1))
    }
}
