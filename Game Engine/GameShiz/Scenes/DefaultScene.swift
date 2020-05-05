import GameplayKit
import simd

class DefaultScene: Scene {
    let camera = FPSCameraQuaternion()
    let sun = Sun()

    var endlessTerrain: TerrainGenerator!
    
    override func buildScene() {
        camera.setPosition(0, 50, 10)
        camera.setRotationX(Float.pi / 2)
        addCamera(camera)
        
        sun.setPosition(0, 5, 0)
//        sun.setMaterialIsLit(false)
        addLight(sun)
        
        addPlane()
    }
    
    func addPlane() {
        endlessTerrain = TerrainGenerator(meshSettings: MeshSettings(), heightMapSettings: HeightMapSettings())
        endlessTerrain.viewer = camera
        endlessTerrain.updateVisibleChunks()
    }
    
    override func doUpdate() {
        // TODO: Move this into the endless terrain game object
        if let endlessTerrain = self.endlessTerrain {
            for terrainChunk in endlessTerrain.visibleTerrainChunks {
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

class Terrain_CustomMesh: Mesh {
    var heightMap: [[Float]]!
    var levelOfDetail: Int!
    var meshSettings: MeshSettings
    
    private var _indices: [UInt32] = []
    
    init(heightMap: [[Float]], levelOfDetail: Int, settings: MeshSettings) {
        self.heightMap = heightMap
        self.levelOfDetail = levelOfDetail
        self.meshSettings = settings
        super.init()
    }
    
    // TODO: add curve support
    override func createMesh() {
        let skipIncrement = levelOfDetail == 0 ? 1 : (levelOfDetail * 2)
        let numVertsPerLine = meshSettings.numVertsPerLine
        
        var vertexIndicesMap: [[Int]] = Array(repeating: Array(repeating: Int(0), count: numVertsPerLine), count: numVertsPerLine)
        var meshVertexIndex = 0;
        var outOfMeshVertexIndex = -1;
        
        for y in stride(from: 0, to: numVertsPerLine, by: 1) {
            for x in stride(from: 0, to: numVertsPerLine, by: 1) {
                let isOutOfMeshVertex = y == 0 || y == numVertsPerLine - 1 || x == 0 || x == numVertsPerLine - 1;
                let isSkippedVertex = x > 2 && x < numVertsPerLine - 3 && y > 2 && y < numVertsPerLine - 3 && ((x - 2) % skipIncrement != 0 || (y - 2) % skipIncrement != 0);
                if (isOutOfMeshVertex) {
                    vertexIndicesMap [x][y] = outOfMeshVertexIndex;
                    outOfMeshVertexIndex -= 1;
                } else if (!isSkippedVertex) {
                    vertexIndicesMap [x][y] = meshVertexIndex;
                    meshVertexIndex += 1;
                }
            }
        }
                        
        for y in stride(from: 0, to: numVertsPerLine, by: 1) {
            for x in stride(from: 0, to: numVertsPerLine, by: 1) {
                let isOutOfMeshVertex = x == 0 || x == numVertsPerLine - 1 || y == 0 || y == numVertsPerLine - 1
                let isSkippedVertex = x > 2 && x < numVertsPerLine - 3 && y > 2 && y < numVertsPerLine - 3 && ((x - 2) % skipIncrement != 0 || (y - 2) % skipIncrement != 0)
                
                if isOutOfMeshVertex || isSkippedVertex {
                    continue
                }
                
                let isMeshEdgeVertex = (y == 1 || y == numVertsPerLine - 2 || x == 1 || x == numVertsPerLine - 2) && !isOutOfMeshVertex;
                let isMainVertex = (x - 2) % skipIncrement == 0 && (y - 2) % skipIncrement == 0 && !isOutOfMeshVertex && !isMeshEdgeVertex;
                let isEdgeConnectionVertex = (y == 2 || y == numVertsPerLine - 3 || x == 2 || x == numVertsPerLine - 3) && !isOutOfMeshVertex && !isMeshEdgeVertex && !isMainVertex;
                                
                let percent = SIMD2<Float>(Float(x - 1), Float(y - 1)) / Float(numVertsPerLine - 3)
                var height = heightMap[x][y]
                
                if (isEdgeConnectionVertex) {
                    let isVertical = x == 2 || x == numVertsPerLine - 3
                    let dstToMainVertexA = (isVertical ? y - 2 : x - 2) % skipIncrement
                    let dstToMainVertexB = skipIncrement - dstToMainVertexA
                    let dstPercentFromAToB = Float(dstToMainVertexA) / Float(skipIncrement)

                    let heightMainVertexA = heightMap [isVertical ? x : x - dstToMainVertexA][isVertical ? y - dstToMainVertexA : y]
                    let heightMainVertexB = heightMap [isVertical ? x : x + dstToMainVertexB][isVertical ? y + dstToMainVertexB : y]

                    height = heightMainVertexA * (1 - dstPercentFromAToB) + heightMainVertexB * dstPercentFromAToB;
                }
                                
                let position = SIMD3<Float>(percent.x * self.meshSettings.meshWorldSize - self.meshSettings.meshWorldSize / 2,
                                            height,
                                            percent.y * self.meshSettings.meshWorldSize - self.meshSettings.meshWorldSize / 2)
                
                addVertex(position: position,
                          colour: SIMD4<Float>(1,0,0,1),
                          textureCoordinate: percent,
                          normal: calculateNormal(x: x, z: y))
                
                let createTriangle = x < numVertsPerLine - 2 && y < numVertsPerLine - 2 && (!isEdgeConnectionVertex || (x != 2 && y != 2));
                
                if createTriangle {
                    let currentIncrement = (isMainVertex && x != numVertsPerLine - 3 && y != numVertsPerLine - 3) ? skipIncrement : 1;
                    
                    let a = vertexIndicesMap [x][y]
                    let b = vertexIndicesMap [x + currentIncrement][y]
                    let c = vertexIndicesMap [x][y + currentIncrement]
                    let d = vertexIndicesMap [x + currentIncrement][y + currentIncrement]

                    let idxs = [b, a, c, b, c, d]
                    
                    let idxs2: [UInt32] = idxs.map { (x) -> UInt32 in
                        UInt32(x)
                    }

                    _indices.append(contentsOf: idxs2)
                }
            }
        }
        
        addSubmesh(Submesh(indices: _indices))
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
