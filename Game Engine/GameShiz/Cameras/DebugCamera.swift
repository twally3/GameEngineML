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
        
        checkController()
                
        let xRotation = self.getRotationX()
        if xRotation > Float.pi / 2 {
            self.setRotationX(Float.pi / 2)
        }
        
        if xRotation < -Float.pi / 2 {
            self.setRotationX(-Float.pi / 2)
        }
    }
    
    private func checkController() {
        guard let controller = Controller.getController() else { return }
        
        var rot: SIMD3<Float> = SIMD3<Float>(repeating: 0)
        var rotIsDirty = false
        
        if let leftThumbstick = controller.extendedGamepad?.leftThumbstick {
            if leftThumbstick.yAxis.value != 0 {
                rot += normalize(SIMD3<Float>(x: -viewMatrix[0,2], y: 0, z: -viewMatrix[0,0])) * leftThumbstick.yAxis.value
                rotIsDirty = true
            }
            
            if leftThumbstick.xAxis.value != 0 {
                var copy = viewMatrix
                copy.rotate(angle: Float.pi / 2, axis: Y_AXIS)
                rot += normalize(SIMD3<Float>(x: -copy[0,2], y: 0, z: -copy[0,0])) * leftThumbstick.xAxis.value
                rotIsDirty = true
            }
        }
        
        if rotIsDirty {
            self.move(delta: normalize(rot) * GameTime.deltaTime * speed)
        }
        
        if let rightThumbstick = controller.extendedGamepad?.rightThumbstick {
            if rightThumbstick.yAxis.value != 0 {
                self.rotate(x: -rightThumbstick.yAxis.value * GameTime.deltaTime * 5, y: 0, z: 0)
            }
            
            if rightThumbstick.xAxis.value != 0 {
                self.rotate(x: 0, y: rightThumbstick.xAxis.value * GameTime.deltaTime * 5, z: 0)
            }
        }
        
        if let dpad = controller.extendedGamepad?.dpad {
            if dpad.up.isPressed == true {
                self.moveY(GameTime.deltaTime * speed)
            }
            
            if dpad.down.isPressed {
                self.moveY(-GameTime.deltaTime * speed)
            }
        }
    }
}
