import simd
import Dispatch

class TerrainGenerator {
    var viewer: Node!
    
    var viewerPosition: SIMD2<Float>!
    var viewerPositionOld: SIMD2<Float>!
    var meshWorldSize: Float!
    var chunksVisibleInViewDst: Int!
    
    var meshSettings: MeshSettings
    var heightMapSettings: HeightMapSettings
    
    let viewerMoveThresholdForChunkUpdate: Float = 25;
    
    var terrainChunkDict: [SIMD2<Int> : TerrainChunk] = [:]
    var visibleTerrainChunks: [TerrainChunk] = []
    
    let detailLevels: [LODInfo] = [
        LODInfo(lod: 0, visibleDstThreshold: 400),
        LODInfo(lod: 1, visibleDstThreshold: 500),
        LODInfo(lod: 4, visibleDstThreshold: 600)
    ]
        
    init(meshSettings: MeshSettings, heightMapSettings: HeightMapSettings) {
        self.meshSettings = meshSettings
        self.heightMapSettings = heightMapSettings
        self.meshWorldSize = meshSettings.meshWorldSize
        
        let maxViewDistance = detailLevels.last!.visibleDstThreshold
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
                        let newChunk = TerrainChunk(coord: viewedChunkCoord,
                                                    heightMapSettings: heightMapSettings,
                                                    meshSettings: meshSettings,
                                                    detailLevels: detailLevels,
                                                    viewer: self.viewer)
                        terrainChunkDict[viewedChunkCoord] = newChunk
                        newChunk.onVisibilityChanged = onTerrainChunkVisibilityChanged(chunk:isVisible:)
                        newChunk.load()
                    }
                }
            }
        }
    }
    
    func onTerrainChunkVisibilityChanged(chunk: TerrainChunk, isVisible: Bool) {
        if isVisible {
            visibleTerrainChunks.append(chunk)
        } else {
            visibleTerrainChunks.removeAll { (terrainChunk) -> Bool in
                terrainChunk === chunk
            }
        }
    }
}

struct LODInfo {
    var lod: Int
    var visibleDstThreshold: Float
}
