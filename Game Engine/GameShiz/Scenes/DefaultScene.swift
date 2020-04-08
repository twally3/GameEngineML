import GameplayKit
import simd

class DefaultScene: Scene {
    let camera = DebugCamera()
    let sun = Sun()

    var endlessTerrain: EndlessTerrain!
    
    override func buildScene() {
        camera.setPosition(0, 50, 10)
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
        let heightMultiplier: Float = 110
        
        let _w = Float(width)
        let _h = Float(height)
        
        let meshSimplificationIncrement = levelOfDetail == 0 ? 1 : (levelOfDetail * 2)
        let verticesPerLine = (width - 1) / meshSimplificationIncrement + 1
        
        var vertexIndex = 0
        
        var max: Float = 0
        
        for y in stride(from: 0, to: height, by: meshSimplificationIncrement) {
            for x in stride(from: 0, to: width, by: meshSimplificationIncrement) {
                let xf = Float(x)
                let yf = Float(y)
                
                let _x = xf - (_w / 2)
                let _y = yf - (_h / 2)
                
                if (max < heightMap[x][y] * heightMultiplier) {
                    max = heightMap[x][y] * heightMultiplier
                }
                
                
                addVertex(position: SIMD3<Float>(_x, heightMap[x][y] * heightMultiplier, _y),
                          colour: SIMD4<Float>(1,0,0,1),
                          textureCoordinate: SIMD2<Float>(xf / (_w - 1), yf / (_h - 1)),
                          normal: calculateNormal(x: x, z: y))
                
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
    
    private func calculateNormal(x: Int, z: Int) -> SIMD3<Float> {
        let heightL: Float = getHeight(x: x - 1, z: z)
        let heightR: Float = getHeight(x: x + 1, z: z)
        let heightD: Float = getHeight(x: x, z: z - 1)
        let heightU: Float = getHeight(x: x, z: z + 1)
        
        return normalize(SIMD3<Float>(x: heightL - heightR, y: 2.0, z: heightD - heightU))
    }
    
    private func getHeight(x: Int, z: Int) -> Float {
        if (x < 0 || x >= self.heightMap.count || z < 0 || z >= self.heightMap[0].count) {
            return 0
        }
        return self.heightMap[x][z] * 110
    }
}
