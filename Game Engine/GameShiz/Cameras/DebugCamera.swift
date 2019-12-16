import simd

class DebugCamera: Camera {
    private var _zoom: Float = 45.0
    
    override var projectionMatrix: matrix_float4x4 {
        return matrix_float4x4.perspective(degreesFov: self._zoom, aspectRatio: Renderer.aspectRatio, near: 0.1, far: 1000)
    }
    
    init() {
        super.init(cameraType: .Debug)
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
        
        self._zoom += Mouse.getDWheel()
    }
}
