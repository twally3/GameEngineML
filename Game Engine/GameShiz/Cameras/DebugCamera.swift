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
            self.moveY(GameTime.deltaTime)
        }
        
        if Keyboard.isKeyPressed(.downArrow) {
            self.moveY(-GameTime.deltaTime)
        }
        
        if Keyboard.isKeyPressed(.a) {
            self.moveX(-GameTime.deltaTime * speed)
        }
        
        if Keyboard.isKeyPressed(.d) {
            self.moveX(GameTime.deltaTime * speed)
        }
        
        if Keyboard.isKeyPressed(.w) {
            self.moveZ(-GameTime.deltaTime * speed)
        }
        
        if Keyboard.isKeyPressed(.s) {
            self.moveZ(GameTime.deltaTime * speed)
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
