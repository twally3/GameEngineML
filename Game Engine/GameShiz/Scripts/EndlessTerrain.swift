import simd
import Dispatch

class EndlessTerrain {
    var viewer: Node!
    
    var viewerPosition: SIMD2<Float>!
    var viewerPositionOld: SIMD2<Float>!
    var chunkSize: Int!
    var chunksVisibleInViewDst: Int!
    
    let viewerMoveThresholdForChunkUpdate: Float = 25;
    
    var terrainChunkDict: [SIMD2<Int> : TerrainChunk] = [:]
    var terrainChunksVisibleLastUpdate: [TerrainChunk] = []
    
    let mapGenerator = MapGenerator()
    
    var maxViewDistance: Float!
    let detailLevels: [LODInfo] = [
        LODInfo(lod: 0, visibleDstThreshold: 400),
        LODInfo(lod: 4, visibleDstThreshold: 500),
        LODInfo(lod: 6, visibleDstThreshold: 600)
    ]
    
    let queue = DispatchQueue(label: "Endless Terrain")
    
    init() {
        self.maxViewDistance = detailLevels.last?.visibleDstThreshold
        self.chunkSize = mapGenerator.mapChunkSize - 1
        self.chunksVisibleInViewDst = Int((maxViewDistance / Float(chunkSize)).rounded(.toNearestOrEven))
    }
    
    func update() {
        self.viewerPosition = SIMD2<Float>(x: self.viewer.getPositionX(), y: self.viewer.getPositionZ()) / mapGenerator._terrainData.uniformScale
        
        if viewerPositionOld == nil || simd_distance(viewerPositionOld, viewerPosition) > viewerMoveThresholdForChunkUpdate {
            viewerPositionOld = viewerPosition;
            updateVisibleChunks();
        }
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
                } else {
                    // Create chunk
                    terrainChunkDict[viewedChunkCoord] = TerrainChunk(parent: self, coord: viewedChunkCoord, size: self.chunkSize, detailLevels: detailLevels)
                }
            }
        }
    }
    
    class TerrainChunk {
        var parent: EndlessTerrain!
        var position: SIMD2<Int>!
        var node: Terrain!
        var visibility: Bool = false;
        var size: Int!
        
        var detailLevels: [LODInfo]
        var lodMeshes: [LODMesh] = []
        var previousLodIdx: Int = -1
        var mapData: MapData!
        
        init(parent: EndlessTerrain, coord: SIMD2<Int>, size: Int, detailLevels: [LODInfo]) {
            self.position = coord &* size
            self.parent = parent
            self.size = size
            
            self.detailLevels = detailLevels
            
            setVisibility(visible: false)
            
            for i in 0..<detailLevels.count {
                lodMeshes.append(LODMesh(lod: detailLevels[i].lod, callback: self.updateTerrainChunk, parent: parent))
            }
            
            parent.mapGenerator.requestMapData(centre: self.position, callback: onMapDataRecieved(mapData:))
        }
        
        func onMapDataRecieved(mapData: MapData) {
            self.mapData = mapData
            let positionV3 = SIMD3<Int>(x: self.position.x, y: 0, z: self.position.y)

            node = Terrain()
            node.setPosition(SIMD3<Float>(positionV3) * self.parent.mapGenerator._terrainData.uniformScale)
            node.setScale(SIMD3<Float>(repeating: self.parent.mapGenerator._terrainData.uniformScale))
//            node.setTexture(mapData.texture)
            
            updateTerrainChunk()
        }
        
        func updateTerrainChunk() {
            guard let mapData = self.mapData, let node = self.node else { return }
            
            // Get distance to nearest bound
            let viewDstFromNearestEdge = distance(SIMD2<Float>(position), parent.viewerPosition!)
            let visible = viewDstFromNearestEdge <= parent.maxViewDistance
            
            if visible {
                var lodIdx = 0

                for i in 0..<detailLevels.count {
                    if viewDstFromNearestEdge > detailLevels[i].visibleDstThreshold {
                        lodIdx += 1
                    } else {
                        break
                    }
                }
                
                if lodIdx != previousLodIdx {
                    let lodMesh = lodMeshes[lodIdx]
                    
                    if let mesh = lodMesh.mesh {
                        previousLodIdx = lodIdx
                        node.setMesh(mesh)
                    } else if !self.lodMeshes[lodIdx].hasRequestedMesh {
                        lodMesh.requestMesh(mapData: mapData)
                    }
                }
                
                self.parent.terrainChunksVisibleLastUpdate.append(self)
            }
            
            setVisibility(visible: visible)
        }
        
        public func setVisibility(visible: Bool) {
            self.visibility = visible
        }
        
        public func getVisibility() -> Bool {
            return self.visibility
        }
    }
    
    class LODMesh {
        var lod: Int
        var updateCallback: () -> ()
        var parent: EndlessTerrain
        
        var hasRequestedMesh = false
        var mesh: Terrain_CustomMesh!
        
        init(lod: Int, callback: @escaping () -> (), parent: EndlessTerrain) {
            self.lod = lod
            self.updateCallback = callback
            self.parent = parent
        }
        
        public func requestMesh(mapData: MapData) {
            self.hasRequestedMesh = true
            
            self.parent.queue.async {
                self.mesh = Terrain_CustomMesh(heightMap: mapData.noiseMap, levelOfDetail: self.lod, heightMultiplier: self.parent.mapGenerator._terrainData.meshHeightMultiplier)
                
                DispatchQueue.main.async {
                    self.updateCallback()
                }
            }
        }
    }
    
    struct LODInfo {
        var lod: Int
        var visibleDstThreshold: Float
    }
}
