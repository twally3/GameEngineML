class MeshSettings {
    // useFlatShading
    let meshScale: Float = 1
    
    let numSupportedLODs = 5
    let numSupportedChunkSizes = 9
    
    public static let supportedChunkSizes: [Int] = [48, 72, 96, 120, 144, 168, 192, 216, 240]
    
    let chunkSizeIndex: Int = 8
    
    // The num verts of a mesh at highest LOD (0).
    //    Number includes padding for normals (that arent in the mesh)
    var numVertsPerLine: Int {
        get {
            return MeshSettings.supportedChunkSizes[chunkSizeIndex] + 5
        }
    }
    
    var meshWorldSize: Float {
        get {
            return Float(numVertsPerLine - 3) * meshScale
        }
    }
}
