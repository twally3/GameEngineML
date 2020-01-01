class MapGenerator {
    let mapWidth: Int = 100
    let mapHeight: Int = 100
    let noiseScale: Float = 0.3
    
    func generateMap() {
//        let noiseMap: [[Float]] = Noise.generateNoiseMap(mapWidth: mapWidth, mapHeight: mapHeight, scale: noiseScale)
        
        
    }
}

struct TerrainType: sizeable {
//    var name: String
    var height: Float
    var colour: SIMD4<Float>
}
