import MetalKit

class MapGenerator {  
    var falloffMap: [[Float]]?
    
    // TODO: Change these to structs and eventually make a components system
    let heightMapSettings: HeightMapSettings = HeightMapSettings()
    let meshSettings: MeshSettings = MeshSettings()
    
    let queue = DispatchQueue(label: "Map Generator")
       
    func requestMapData(centre: SIMD2<Float>, callback: @escaping (HeightMap) -> ()) {
        queue.async {
//            let mapData = self.generateMapData(centre: centre)
            let mapData = HeightMapGenerator.generateHeightMap(width: self.meshSettings.numVertsPerLine,
                                                               height: self.meshSettings.numVertsPerLine,
                                                               settings: self.heightMapSettings,
                                                               sampleCentre: centre)
            
            DispatchQueue.main.async {
                callback(mapData)
            }
        }
    }
}
