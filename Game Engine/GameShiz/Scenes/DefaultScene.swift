import GameplayKit
import simd

class DefaultScene: Scene {
    let camera = DebugCamera()
    let sun = Sun()
    let plane = Plane()
    
    var terrain: Terrain!
    
    // TODO: Clamp between (0,6)
    let levelOfDetail: Int = 0
    var endlessTerrain: EndlessTerrain!
    
    var i: Int = 0
    
    let mapGenerator = MapGenerator()
    
    override func buildScene() {
        camera.setPosition(0, 50, 10)
//        camera.setPosition(0, 10, 10)
        camera.setRotationX(Float.pi / 2)
        addCamera(camera)
        
        sun.setPosition(0, 5, 0)
        sun.setMaterialIsLit(false)
        addLight(sun)
        
        addPlane()
    }
    
    func addPlane() {
        endlessTerrain = EndlessTerrain(chunkSize: 240)
        endlessTerrain.viewer = camera
        endlessTerrain.updateVisibleChunks()
    }
    
    override func doUpdate() {
//        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
//            terrain!.rotateX(Mouse.getDY() * GameTime.deltaTime)
//            terrain!.rotateY(Mouse.getDX() * GameTime.deltaTime)
//        }
        
        // TODO: Move this into the endless terrain game object
        if let endlessTerrain = self.endlessTerrain {
            for terrainChunk in endlessTerrain.terrainChunksVisibleLastUpdate {
                guard let go = terrainChunk.node else { continue }
                
                removeChild(go)
            }
            
            endlessTerrain.update()
            
            for (_, terrainChunk) in endlessTerrain.terrainChunkDict {
                guard let go = terrainChunk.node else { continue }
                
                if terrainChunk.getVisibility() == true {
                    addChild(go)
                } else {
                    removeChild(go)
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
    let queue = DispatchQueue(label: "Terrain Mesh")
    
    init(heightMap: [[Float]], levelOfDetail: Int) {
        super.init(name: "Terrain", meshType: .None)
        
        queue.async {
            let mesh = Terrain_CustomMesh(heightMap: heightMap, levelOfDetail: levelOfDetail)
            
            DispatchQueue.main.async {
                self.setMesh(mesh)
            }
        }
        
        setMaterialIsLit(false)
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
    
    let mapGenerator = MapGenerator()
    
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
        var size: Int!
        
        init(parent: EndlessTerrain, coord: SIMD2<Int>, size: Int) {
            self.position = coord &* size
            self.parent = parent
            self.size = size
            
            parent.mapGenerator.requestMapData(callback: onMapDataRecieved(mapData:))

            setVisibility(visible: false)
        }
        
        func onMapDataRecieved(mapData: MapData) {
            let noise = mapData.noiseMap
            let texture = mapData.texture
            let positionV3 = SIMD3<Int>(x: self.position.x, y: 0, z: self.position.y)

            node = Terrain(heightMap: noise, levelOfDetail: 0)
            node.setPosition(SIMD3<Float>(positionV3))
            node.setTexture(texture)
        }
        
        func updateTerrainChunk() {
            // Get distance to nearest bound
            let viewDstFromNearestEdge = distance(SIMD2<Float>(position) - (240.0 / 2.0), parent.viewerPosition!)
            let visible = viewDstFromNearestEdge <= parent.maxViewDistance
            setVisibility(visible: visible)
        }
        
        public func setVisibility(visible: Bool) {
            self.visibility = visible
        }
        
        public func getVisibility() -> Bool {
            return self.visibility
        }
    }
}
