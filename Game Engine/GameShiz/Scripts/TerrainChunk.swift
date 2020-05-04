import simd

class TerrainChunk {
    var onVisibilityChanged: ((TerrainChunk, Bool) -> ())?
    var sampleCentre: SIMD2<Float>
    var node: Terrain!
    var visibility: Bool = false
    var position: SIMD2<Float>
    
    var detailLevels: [LODInfo]
    var lodMeshes: [LODMesh] = []
    var previousLodIdx: Int = -1
    var mapData: HeightMap!
    
    var coord: SIMD2<Int>
    
    var heightMapSettings: HeightMapSettings
    var meshSettings: MeshSettings
    var viewer: Node
    var maxViewDistance: Float
    
    var viewerPosition: SIMD2<Float> {
        get {
            return SIMD2<Float>(viewer.getPositionX(), viewer.getPositionZ())
        }
    }
    
    init(coord: SIMD2<Int>, heightMapSettings: HeightMapSettings, meshSettings: MeshSettings, detailLevels: [LODInfo], viewer: Node) {
        self.sampleCentre = SIMD2<Float>(coord) * meshSettings.meshWorldSize / meshSettings.meshScale
        self.coord = coord
        self.viewer = viewer
        
        self.heightMapSettings = heightMapSettings
        self.meshSettings = meshSettings
        
        self.position = SIMD2<Float>(coord) * meshSettings.meshWorldSize
        
        self.detailLevels = detailLevels
        
        self.maxViewDistance = detailLevels[detailLevels.count - 1].visibleDstThreshold
        
        setVisibility(visible: false)
        
        for i in 0..<detailLevels.count {
            lodMeshes.append(LODMesh(lod: detailLevels[i].lod, callback: self.updateTerrainChunk ))
        }
    }
    
    func onMapDataRecieved(mapDataObject: Any) {
        guard let mapData = mapDataObject as? HeightMap else { return }
        self.mapData = mapData
        let positionV3 = SIMD3<Float>(x: self.position.x, y: 0, z: self.position.y)

        node = Terrain()
        node.setPosition(positionV3)
        
        updateTerrainChunk()
    }
    
    func updateTerrainChunk() {
        guard let mapData = self.mapData, let node = self.node else { return }
        
        // Get distance to nearest bound
        let viewDstFromNearestEdge = distance(sampleCentre, viewerPosition)
        let wasVisible = self.visibility
        let visible = viewDstFromNearestEdge <=  maxViewDistance
        
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
                    lodMesh.requestMesh(mapData: mapData, meshSettings: meshSettings)
                }
            }
        }
        
        if wasVisible != visible {
            setVisibility(visible: visible)
            if let onVisibilityChanged = self.onVisibilityChanged {
                onVisibilityChanged(self, visible)
            }
        }
    }
    
    func load() {
        ThreadedDataRequester.requestData(generateData: { () -> (Any) in
            HeightMapGenerator.generateHeightMap(width: self.meshSettings.numVertsPerLine,
                                                 height: self.meshSettings.numVertsPerLine,
                                                 settings: self.heightMapSettings,
                                                 sampleCentre: self.sampleCentre)
        }, callback: onMapDataRecieved(mapDataObject:))
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
    
    var hasRequestedMesh = false
    var mesh: Terrain_CustomMesh!
    
    init(lod: Int, callback: @escaping () -> ()) {
        self.lod = lod
        self.updateCallback = callback
    }
    
    public func requestMesh(mapData: HeightMap, meshSettings: MeshSettings) {
        self.hasRequestedMesh = true
        
        ThreadedDataRequester.requestData(generateData: { () -> (Any) in
            return Terrain_CustomMesh(heightMap: mapData.values, levelOfDetail: self.lod, settings: meshSettings)
        }, callback: self.onMeshRecieved(meshObject:))
    }
    
    func onMeshRecieved(meshObject: Any) {
        guard let mesh = meshObject as? Terrain_CustomMesh else { return }
        self.mesh = mesh
        self.updateCallback()
    }
}
