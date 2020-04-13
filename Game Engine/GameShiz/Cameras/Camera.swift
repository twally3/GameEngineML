import simd

enum CameraTypes {
    case Debug
    case Test
    case FPS
}

class Camera: Node {
    var cameraType: CameraTypes!
    
    var viewMatrix: matrix_float4x4 {
        var viewMatrix = matrix_identity_float4x4
        viewMatrix.rotate(angle: self.getRotationX(), axis: X_AXIS)
        viewMatrix.rotate(angle: self.getRotationY(), axis: Y_AXIS)
        viewMatrix.rotate(angle: self.getRotationZ(), axis: Z_AXIS)
        viewMatrix.translate(direction: -getPosition())
        return viewMatrix
    }
    
    var projectionMatrix: matrix_float4x4 {
        return matrix_identity_float4x4
    }
    
    var pitch: Float {
        get { return self.getRotationX() }
        set(x) {
            var xRotation = x
            if xRotation > Float.pi / 2 || xRotation < -Float.pi / 2 {
                xRotation = (Float.pi / 2 + 0.001) * sign(xRotation)
            }
            self.setRotationX(xRotation)
        }
    }
    
    var yaw: Float {
        get { return self.getRotationY() }
        set(x) { self.setRotationY(x) }
    }
    
    var roll: Float {
        get { return self.getRotationZ() }
        set(x) { self.setRotationZ(x) }
    }
    
    init(name: String, cameraType: CameraTypes) {
        super.init(name: name)
        self.cameraType = cameraType
    }
}
