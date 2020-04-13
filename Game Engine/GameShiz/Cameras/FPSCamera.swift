import simd

class FPSCamera: Camera {
    var _viewMatrix: matrix_float4x4 = matrix_identity_float4x4
    
    override var viewMatrix: matrix_float4x4 {
        self.updateView()
        return _viewMatrix
    }
    
    override var projectionMatrix: matrix_float4x4 {
        return matrix_float4x4.perspective(degreesFov: 45.0, aspectRatio: Renderer.aspectRatio, near: 0.1, far: 1000)
    }
    
    init() {
        super.init(name: "FPS", cameraType: .FPS)
    }
    
    override func doUpdate() {
        self.keyPressed()
        self.mouseMove()
    }
    
    func updateView() {
        var matPitch = matrix_identity_float4x4
        var matYaw = matrix_identity_float4x4
        var matRoll = matrix_identity_float4x4
        
        matPitch.rotate(angle: self.pitch, axis: SIMD3<Float>(x: 1, y: 0, z: 0))
        matYaw.rotate(angle: self.yaw, axis: SIMD3<Float>(x: 0, y: 1, z: 0))
        matRoll.rotate(angle: self.roll, axis: SIMD3<Float>(x: 0, y: 0, z: 1))
        
        let rotate = matRoll * matPitch * matYaw
                
        var translate = matrix_identity_float4x4
        translate.translate(direction: -self.getPosition())
        
        _viewMatrix = rotate * translate
    }
    
    func keyPressed() {
        var dx: Float = 0
        var dz: Float = 0
        
        if (Keyboard.isKeyPressed(.w)) {
            dz = 2
        } else if (Keyboard.isKeyPressed(.s)) {
            dz = -2
        } else if (Keyboard.isKeyPressed(.a)) {
            dx = -2
        } else if (Keyboard.isKeyPressed(.d)) {
            dx = 2
        }
        
        let mat = _viewMatrix
        
        let forward = SIMD3<Float>(x: mat[0][2], y: mat[1][2], z: mat[2][2])
        let strafe = SIMD3<Float>(x: mat[0][0], y: mat[1][0], z: mat[2][0])
        
        
        let speed: Float = 0.32

        self.move(delta: (-dz * forward + dx * strafe) * speed)
    }
    
    func mouseMove() {
        let mousePos = SIMD2<Float>(x: Mouse.getDX(), y: Mouse.getDY())
        let mouseDelta = mousePos
        
        let mouseXSensitivity: Float = 0.025
        let mouseYSensitivity: Float = 0.025
        
        yaw += mouseXSensitivity * mouseDelta.x
        pitch += mouseYSensitivity * mouseDelta.y
    }
}
