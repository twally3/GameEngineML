import simd

class DebugCamera: Camera {
    private var _projectionMatrix = matrix_identity_float4x4
    override var projectionMatrix: matrix_float4x4 {
        return _projectionMatrix
    }
    
    private var _moveSpeed: Float = 4.0
    private var _turnSpeed: Float = 1.0
    
    init() {
        super.init(name: "Debug", cameraType: .Debug)
        
        print("INIT")
        
        _projectionMatrix = matrix_float4x4.perspective(degreesFov: 45.0,
                                                        aspectRatio: Renderer.aspectRatio,
                                                        near: 0.1,
                                                        far: 1000)
    }
    
    override func doUpdate() {
        if Keyboard.isKeyPressed(.leftArrow) {
            self.moveX(-GameTime.deltaTime * _moveSpeed)
        }
        
        if Keyboard.isKeyPressed(.rightArrow) {
            self.moveX(GameTime.deltaTime * _moveSpeed)
        }
        
        if Keyboard.isKeyPressed(.upArrow) {
            self.moveY(GameTime.deltaTime * _moveSpeed)
        }
        
        if Keyboard.isKeyPressed(.downArrow) {
            self.moveY(-GameTime.deltaTime * _moveSpeed)
        }
        
        if Mouse.isMouseButtonPressed(button: .RIGHT) {
            self.rotate(x: Mouse.getDY() * GameTime.deltaTime * _turnSpeed,
                        y: Mouse.getDX() * GameTime.deltaTime * _turnSpeed,
                        z: 0)
        }
        
        if Mouse.isMouseButtonPressed(button: .CENTER) {
            self.moveX(-Mouse.getDX() * GameTime.deltaTime * _moveSpeed)
            self.moveY(Mouse.getDY() * GameTime.deltaTime * _moveSpeed)
        }
        
        let x = -Mouse.getDWheel() * 0.1
        
        self.moveZ(x)
    }
}
