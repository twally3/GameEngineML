class SandboxScene: Scene {
    let camera = DebugCamera()
    let chest = Well()
    let sun = Sun()
    
    override func buildScene() {
        camera.setPosition(0, 0, 3)
        addCamera(camera)
        
        sun.setPosition(SIMD3<Float>(0, 5, 5))
        addLight(sun)
//        
//        chest.useBaseColourTexture(.MetalPlate_Diffuse)
//        chest.useBaseNormalMapTexture(.MetalPlate_Normal)
        
        chest.moveY(-0.5)
        addChild(chest)
    }
    
    override func doUpdate() {
        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
            chest.rotateX(Mouse.getDY() * GameTime.deltaTime)
            chest.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
    }
}
