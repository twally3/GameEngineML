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
//    let queue = DispatchQueue(label: "Terrain Mesh")
    
    init(heightMap: [[Float]], levelOfDetail: Int) {
        super.init(name: "Terrain", meshType: .None)

//        queue.async {
//            let mesh = Terrain_CustomMesh(heightMap: heightMap, levelOfDetail: levelOfDetail)
//
//            DispatchQueue.main.async {
//                self.setMesh(mesh)
//            }
//        }
        
        setMaterialIsLit(false)
    }
}
