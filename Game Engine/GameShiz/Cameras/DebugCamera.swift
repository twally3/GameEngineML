import simd

class DebugCamera: Camera {
    let speed: Float = 100
    
    override var projectionMatrix: matrix_float4x4 {
        return matrix_float4x4.perspective(degreesFov: 45.0, aspectRatio: Renderer.aspectRatio, near: 0.1, far: 1000)
    }
    
    init() {
        super.init(name: "Debug", cameraType: .Debug)
    }
    
    override func doUpdate() {
        if Keyboard.isKeyPressed(.leftArrow) {
            self.moveX(-GameTime.deltaTime)
        }
        
        if Keyboard.isKeyPressed(.rightArrow) {
            self.moveX(GameTime.deltaTime)
        }
        
        if Keyboard.isKeyPressed(.upArrow) {
            self.moveY(GameTime.deltaTime * speed)
        }
        
        if Keyboard.isKeyPressed(.downArrow) {
            self.moveY(-GameTime.deltaTime * speed)
        }
        
        var rot: SIMD3<Float> = SIMD3<Float>(repeating: 0)
        var rotIsDirty = false
        
        if Keyboard.isKeyPressed(.a) {
            var copy = viewMatrix
            copy.rotate(angle: Float.pi / 2, axis: Y_AXIS)
            let _rotation = -normalize(SIMD3<Float>(x: -copy[0,2], y: 0, z: -copy[0,0]))
            rot += _rotation
            rotIsDirty = true
        }
        
        if Keyboard.isKeyPressed(.d) {
            var copy = viewMatrix
            copy.rotate(angle: Float.pi / 2, axis: Y_AXIS)
            let _rotation = normalize(SIMD3<Float>(x: -copy[0,2], y: 0, z: -copy[0,0]))
            rot += _rotation
            rotIsDirty = true
        }
        
        if Keyboard.isKeyPressed(.w) {
            let _rotation = normalize(SIMD3<Float>(x: -viewMatrix[0,2], y: 0, z: -viewMatrix[0,0]))
            rot += _rotation
            rotIsDirty = true
        }
        
        if Keyboard.isKeyPressed(.s) {
            let _rotation = -normalize(SIMD3<Float>(x: -viewMatrix[0,2], y: 0, z: -viewMatrix[0,0]))
            rot += _rotation
            rotIsDirty = true
        }
        
        if rotIsDirty {
            self.move(delta: normalize(rot) * GameTime.deltaTime * speed)
        }
        
        if Mouse.isMouseButtonPressed(button: .RIGHT) {
            self.rotate(x: Mouse.getDY() * GameTime.deltaTime, y: Mouse.getDX() * GameTime.deltaTime, z: 0)
        }
        
        if Mouse.isMouseButtonPressed(button: .CENTER) {
            self.moveX(-Mouse.getDX() * GameTime.deltaTime)
            self.moveY(Mouse.getDY() * GameTime.deltaTime)
        }
        
        self.moveZ(-Mouse.getDWheel() * 0.1)
    }
}
