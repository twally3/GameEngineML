import GameplayKit
import simd

class DefaultScene: Scene {
    let camera = DebugCamera()
    let sun = Sun()
    let plane = Plane()
    
    var terrain: Terrain!
    
    // Divisble by all even numbers up to 12 (for LOD)
    let mapChunkSize = 241
    // TODO: Clamp between (0,6)
    let levelOfDetail: Int = 0
    var noiseScale: Float = 25
    
    let octaves: Int = 4
    let persistance: Float = 0.5
    let lacunarity: Float = 2
    
    let seed: UInt64 = 1
    let offset = SIMD2<Int>(x: 0, y: 0)
    
    var endlessTerrain: EndlessTerrain!
    
    var i: Int = 0
    
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
        camera.setPosition(0, 100, 10)
        addCamera(camera)
        
        sun.setPosition(0, 5, 0)
        sun.setMaterialIsLit(false)
        addLight(sun)
        
        addPlane()
    }
    
    func addPlane() {
        let noise = Noise.generateNoiseMap(mapWidth: mapChunkSize,
                                            mapHeight: mapChunkSize,
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
        
//        terrain = Terrain(heightMap: noise, levelOfDetail: levelOfDetail)
//        terrain.setTexture(texture)
//        addChild(terrain)
        
        endlessTerrain = EndlessTerrain(chunkSize: 240)
        endlessTerrain.viewer = camera
        endlessTerrain.updateVisibleChunks()
    }
    
    func generateRandomTexture(_ noise: [[Float]]) -> [Float] {
        var mapValues: [Float] = []
        
        for y in 0..<mapChunkSize {
            for x in 0..<mapChunkSize {
                mapValues.append(noise[x][y])
            }
        }
        
        return mapValues
    }
    
    public func loadEmptyTexture()->MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.width = mapChunkSize
        textureDescriptor.height = mapChunkSize
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
//        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
//            terrain!.rotateX(Mouse.getDY() * GameTime.deltaTime)
//            terrain!.rotateY(Mouse.getDX() * GameTime.deltaTime)
//        }
        
        if let endlessTerrain = self.endlessTerrain {
            for terrainChunk in endlessTerrain.terrainChunksVisibleLastUpdate {
                removeChild(terrainChunk.node)
            }
            
            endlessTerrain.update()
            
            for (_, terrainChunk) in endlessTerrain.terrainChunkDict {
                if terrainChunk.getVisibility() == true {
                    addChild(terrainChunk.node)
                } else {
                    removeChild(terrainChunk.node)
                }
            }
        }
    }
}

class Terrain_CustomMesh: CustomMesh {
    var heightMap: [[Float]]!
    var levelOfDetail: Int!
    
    init(heightMap: [[Float]], levelOfDetail: Int) {
        self.heightMap = heightMap
        self.levelOfDetail = levelOfDetail
        super.init()
    }
    
    // TODO: Clean this up as args and add curve support
    override func createMesh() {
        let height = heightMap[0].count
        let width = heightMap.count
        let heightMultiplier: Float = 15
        
        let _w = Float(width)
        let _h = Float(height)
        
        let meshSimplificationIncrement = levelOfDetail == 0 ? 1 : (levelOfDetail * 2)
        let verticesPerLine = (width - 1) / meshSimplificationIncrement + 1
        
        var vertexIndex = 0
        
        for y in stride(from: 0, to: height, by: meshSimplificationIncrement) {
            for x in stride(from: 0, to: width, by: meshSimplificationIncrement) {
                let xf = Float(x)
                let yf = Float(y)
                
                let _x = xf - (_w / 2)
                let _y = yf - (_h / 2)
                
                addVertex(position: SIMD3<Float>(_x, heightMap[x][y] * heightMultiplier, _y),
                          colour: SIMD4<Float>(1,0,0,1),
                          textureCoordinate: SIMD2<Float>(xf / (_w - 1), yf / (_h - 1)))
                
                if (x < width - 1 && y < height - 1) {
                    let startIndex = vertexIndex
                    let idxs = [startIndex + 1, startIndex, startIndex + verticesPerLine,
                                startIndex + 1, startIndex + verticesPerLine, startIndex + verticesPerLine + 1]
                    let idxs2: [UInt32] = idxs.map { (x) -> UInt32 in
                        UInt32(x)
                    }
                    
                    addIndices(idxs2)
                }
                
                vertexIndex += 1
            }
        }
    }
}

class Terrain: GameObject {
    var endlessTerrain: EndlessTerrain!
    
    init(heightMap: [[Float]], levelOfDetail: Int) {
        super.init(name: "Terrain", meshType: .None)
        
        let mesh = Terrain_CustomMesh(heightMap: heightMap, levelOfDetail: levelOfDetail)
        setMesh(mesh)
        
        setMaterialIsLit(true)
        setRotationX(0.5)
        setScale(SIMD3<Float>(repeating: 0.1))
    }
}

class EndlessTerrain {
    let maxViewDistance: Float = 550;
    var viewer: Node!
    
    var viewerPosition: SIMD2<Float>!
    var chunkSize: Int!
    var chunksVisibleInViewDst: Int!
    
    var terrainChunkDict: [SIMD2<Int> : TerrainChunk] = [:]
    var terrainChunksVisibleLastUpdate: [TerrainChunk] = []
    
    init(chunkSize: Int) {
        self.chunkSize = chunkSize
        self.chunksVisibleInViewDst = Int((maxViewDistance / Float(chunkSize)).rounded(.toNearestOrEven))
    }
    
    func update() {
        self.viewerPosition = SIMD2<Float>(x: self.viewer.getPositionX(), y: self.viewer.getPositionZ())
        updateVisibleChunks()
    }
    
    func updateVisibleChunks() {
        guard let viewerPosition = self.viewerPosition else { return }
        
        for terrainChunk in terrainChunksVisibleLastUpdate {
            terrainChunk.setVisibility(visible: false)
        }
        
        terrainChunksVisibleLastUpdate.removeAll(keepingCapacity: false)
        
        let currentChunkX: Int = Int((viewerPosition.x / Float(chunkSize)).rounded(.toNearestOrEven))
        let currentChunkY: Int = Int((viewerPosition.y / Float(chunkSize)).rounded(.toNearestOrEven))
        
        for yOffset in stride(from: -chunksVisibleInViewDst, to: chunksVisibleInViewDst, by: 1) {
            for xOffset in stride(from: -chunksVisibleInViewDst, to: chunksVisibleInViewDst, by: 1) {
                let viewedChunkCoord = SIMD2<Int>(x: currentChunkX + xOffset, y: currentChunkY + yOffset)
                
                if let terrainChunk = terrainChunkDict[viewedChunkCoord] {
                    terrainChunk.updateTerrainChunk()
                    if terrainChunk.getVisibility() == true {
                        terrainChunksVisibleLastUpdate.append(terrainChunk)
                    }
                } else {
                    // Create chunk
                    terrainChunkDict[viewedChunkCoord] = TerrainChunk(parent: self, coord: viewedChunkCoord, size: self.chunkSize)
                }
            }
        }
    }
    
    class TerrainChunk {
        var parent: EndlessTerrain!
        var position: SIMD2<Int>!
        var node: GameObject!
        var visibility: Bool = false;
        
        init(parent: EndlessTerrain, coord: SIMD2<Int>, size: Int) {
            self.position = coord &* size
            self.parent = parent
            let positionV3 = SIMD3<Int>(x: self.position.x, y: 0, z: self.position.y)
            
            // Create mesh at given position
            node = Quad()
            node.setPosition(SIMD3<Float>(positionV3))
            node.setRotationX(1.5708)
            node.setScale(Float(size) / 2, Float(size) / 2, Float(1))
            node.setMaterialIsLit(false)
            // Set Visibility(false)
            setVisibility(visible: false)
        }
        
        func updateTerrainChunk() {
            // Get distance to nearest bound
            let viewDstFromNearestEdge = distance(SIMD2<Float>(position) - (240.0 / 2.0), parent.viewerPosition!)
            // visible = viewDistFromNearestEdge <= maxViewDist
            let visible = viewDstFromNearestEdge <= parent.maxViewDistance
            // Set Visibility(visible)
            setVisibility(visible: visible)
        }
        
        public func setVisibility(visible: Bool) {
            // Set Visibility
            self.visibility = visible
        }
        
        public func getVisibility() -> Bool {
            return self.visibility
        }
    }
}
