import simd

protocol sizeable {}

extension sizeable {
    static var size: Int {
        return MemoryLayout<Self>.size
    }
    
    static var stride: Int {
        return MemoryLayout<Self>.stride
    }
    
    static func size(_ count: Int) -> Int {
        return MemoryLayout<Self>.size * count
    }
    
    static func stride(_ count: Int) -> Int {
        return MemoryLayout<Self>.stride * count
    }
}

struct Vertex: sizeable {
    var position: SIMD3<Float>
    var colour: SIMD4<Float>
    var textureCoordinate: SIMD2<Float>
    var normal: SIMD3<Float>
}

extension Int32: sizeable {}
extension Float32: sizeable {}
extension UInt32: sizeable {}
extension SIMD2: sizeable where Scalar == Float {}
extension SIMD3: sizeable where Scalar == Float {}
extension SIMD4: sizeable where Scalar == Float {}

struct ModelConstants: sizeable {
    var modelMatrix = matrix_identity_float4x4
}

struct SceneConstants: sizeable {
    var viewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
    var cameraPosition = SIMD3<Float>(repeating: 0)
    var clippingPlane = SIMD4<Float>(repeating: 0)
}

struct Material: sizeable {
    var colour = SIMD4<Float>(0.4, 0.4, 0.4, 1.0)
    var isLit: Bool = true
    var ambient: SIMD3<Float> = SIMD3<Float>(repeating: 0.1)
    var diffuse: SIMD3<Float> = SIMD3<Float>(repeating: 1)
    var specular: SIMD3<Float> = SIMD3<Float>(repeating: 1)
    var shininess: Float = 2
}

struct LightData: sizeable {
    var position: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    var colour: SIMD3<Float> = SIMD3<Float>(repeating: 1)
    var brightness: Float = 1.0
    var ambientIntensity: Float = 1.0
    var diffuseIntensity: Float = 1.0
    var specularIntensity: Float = 1.0
}

struct TerrainLayer: sizeable {
    var height: Float
    var colour: SIMD4<Float>
    var colourStrength: Float = 0
    var scale: Float
    var blend: Float = 0
    var textureId: Int32 = 0
}
