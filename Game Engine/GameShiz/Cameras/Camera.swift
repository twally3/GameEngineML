import simd

enum CameraTypes {
    case Debug
}

protocol Camera {
    var cameraType: CameraTypes { get set }
    var position: SIMD3<Float> { get set }
    
    func update(deltaTime: Float)
}

extension Camera {
    var viewMatrix: matrix_float4x4 {
        var viewMatrix = matrix_identity_float4x4
        viewMatrix.translate(direction: -position)
        return viewMatrix
    }
}
