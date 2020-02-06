class SandboxScene: Scene {
    let camera = DebugCamera()
    let quad = Quad()
    let sun = Sun()
    
    override func buildScene() {
        camera.setPosition(0, 0, 4)
        addCamera(camera)
        
        sun.setPosition(SIMD3<Float>(0, 2, 0))
        sun.setMaterialIsLit(false)
        sun.setLightBrightness(0.3)
        sun.setMaterialColour(1,1,1,1)
        sun.setLightColour(1,1,1)
        addLight(sun)
        
        quad.setMaterialAmbient(0.01)
        quad.setMaterialShininess(10)
        quad.setMaterialSpecular(5)
//        quad.setMaterialIsLit(false)
        quad.setTexture(.PartyPirateParot)
        
        addChild(quad)
    }
    
    override func doUpdate() {
        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
            quad.rotateX(Mouse.getDY() * GameTime.deltaTime)
            quad.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
    }
}
