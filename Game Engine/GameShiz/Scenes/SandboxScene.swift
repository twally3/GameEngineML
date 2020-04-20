class SandboxScene: Scene {
    let camera = DebugCamera()
    let theSuzannes = TheSuzannes()
    let sun = Sun()
    
    override func buildScene() {
        camera.setPosition(0, 0, 10)
        addCamera(camera)
        
        sun.setPosition(SIMD3<Float>(0, 2, 2))
        sun.setMaterialIsLit(false)
        sun.setLightBrightness(0.3)
        sun.setMaterialColour(1,1,1,1)
        sun.setLightColour(1,1,1)
        addLight(sun)
        
        theSuzannes.setMaterialShininess(100)
        
        addChild(theSuzannes)
    }
    
    override func doUpdate() {
        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
            theSuzannes.rotateX(Mouse.getDY() * GameTime.deltaTime)
            theSuzannes.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
    }
}
