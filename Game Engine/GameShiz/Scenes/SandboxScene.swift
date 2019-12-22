class SandboxScene: Scene {
    let camera = DebugCamera()
    let cruiser = Cruiser()
    
    let leftSun = Sun()
    let middleSun = Sun()
    let rightSun = Sun()
    
    override func buildScene() {
        camera.setPosition(0, 0, 4)
        addCamera(camera)
        
        leftSun.setPosition(-1, 1, 0)
        leftSun.setMaterialIsLit(false)
        leftSun.setMaterialColour(1, 0, 0, 1)
        leftSun.setLightColour(1, 0, 0)
        addLight(leftSun)
        
        middleSun.setPosition(0, 1, 0)
        middleSun.setMaterialIsLit(false)
        middleSun.setLightBrightness(0.3)
        middleSun.setMaterialColour(1, 1, 1, 1)
        middleSun.setLightColour(1, 1, 1)
        addLight(middleSun)
        
        rightSun.setPosition(1, 1, 0)
        rightSun.setMaterialIsLit(false)
        rightSun.setMaterialColour(0, 0, 1, 1)
        rightSun.setLightColour(0, 0, 1)
        addLight(rightSun)
        
        cruiser.setMaterialAmbient(0.01)
        cruiser.setRotationX(0.5)
        cruiser.setMaterialShininess(10)
        cruiser.setMaterialSpecular(5)
        addChild(cruiser)
    }
    
    override func doUpdate() {
        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
            cruiser.rotateX(Mouse.getDY() * GameTime.deltaTime)
            cruiser.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
        
        cruiser.setMaterialShininess(cruiser.getMaterialShininess() - Mouse.getDWheel())
    }
}
