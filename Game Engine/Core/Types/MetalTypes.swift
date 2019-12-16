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
}

extension SIMD2: sizeable where Scalar == Float {}
extension SIMD3: sizeable where Scalar == Float {}
extension SIMD4: sizeable where Scalar == Float {}

struct ModelConstants: sizeable {
    var modelMatrix = matrix_identity_float4x4
}

struct SceneConstants: sizeable {
    var totalGameTime: Float = 0
    var viewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
}

struct Material: sizeable {
    var colour = SIMD4<Float>(0.8, 0.8, 0.8, 1.0)
    var useMaterialColour: Bool = false
}
