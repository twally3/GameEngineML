import simd
import Dispatch

class TerrainGenerator {
    var viewer: Node!
    
    var viewerPosition: SIMD2<Float>!
    var viewerPositionOld: SIMD2<Float>!
    var meshWorldSize: Float!
    var chunksVisibleInViewDst: Int!
    
    let viewerMoveThresholdForChunkUpdate: Float = 25;
    
    var terrainChunkDict: [SIMD2<Int> : TerrainChunk] = [:]
    var visibleTerrainChunks: [TerrainChunk] = []
    
    let mapGenerator = MapGenerator()
    
    var maxViewDistance: Float!
    let detailLevels: [LODInfo] = [
        LODInfo(lod: 0, visibleDstThreshold: 400),
        LODInfo(lod: 1, visibleDstThreshold: 500),
        LODInfo(lod: 4, visibleDstThreshold: 600)
    ]
        
    init() {
        self.maxViewDistance = detailLevels.last?.visibleDstThreshold
        self.meshWorldSize = mapGenerator.meshSettings.meshWorldSize
        self.chunksVisibleInViewDst = Int((maxViewDistance / Float(meshWorldSize)).rounded(.toNearestOrEven))
    }
    
    func update() {
        self.viewerPosition = SIMD2<Float>(x: self.viewer.getPositionX(), y: self.viewer.getPositionZ())
        
        if viewerPositionOld == nil || simd_distance(viewerPositionOld, viewerPosition) > viewerMoveThresholdForChunkUpdate {
            viewerPositionOld = viewerPosition;
            updateVisibleChunks();
        }
    }
    
    func updateVisibleChunks() {
        guard let viewerPosition = self.viewerPosition else { return }
        
        var alreadyUpdatedChunkCoords = Set<SIMD2<Int>>()
        
        for i in stride(from: visibleTerrainChunks.count - 1, to: 0, by: -1) {
            alreadyUpdatedChunkCoords.insert(visibleTerrainChunks[i].coord)
            visibleTerrainChunks[i].updateTerrainChunk()
        }
                
        let currentChunkX: Int = Int((viewerPosition.x / Float(meshWorldSize)).rounded(.toNearestOrEven))
        let currentChunkY: Int = Int((viewerPosition.y / Float(meshWorldSize)).rounded(.toNearestOrEven))
        
        for yOffset in stride(from: -chunksVisibleInViewDst, to: chunksVisibleInViewDst, by: 1) {
            for xOffset in stride(from: -chunksVisibleInViewDst, to: chunksVisibleInViewDst, by: 1) {
                let viewedChunkCoord = SIMD2<Int>(x: currentChunkX + xOffset, y: currentChunkY + yOffset)
                
                if !alreadyUpdatedChunkCoords.contains(viewedChunkCoord) {
                    if let terrainChunk = terrainChunkDict[viewedChunkCoord] {
                        terrainChunk.updateTerrainChunk()
                    } else {
                        // Create chunk
                        terrainChunkDict[viewedChunkCoord] = TerrainChunk(coord: viewedChunkCoord, heightMapSettings: self.mapGenerator.heightMapSettings, meshSettings: self.mapGenerator.meshSettings, detailLevels: detailLevels)
                    }
                }
            }
        }
    }
}

struct LODInfo {
    var lod: Int
    var visibleDstThreshold: Float
}
