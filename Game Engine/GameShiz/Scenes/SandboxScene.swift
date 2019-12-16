import MetalKit

class SandboxScene: Scene {
    let camera = DebugCamera()
    let cruiser = Cruiser()
    let sun = Sun()
    
    override func buildScene() {
        addCamera(camera)
        
        sun.setPosition(SIMD3<Float>(0, 2, 2))
        addLight(sun)
        
        camera.setPositionZ(5)
        
        addChild(cruiser)
    }
    
    override func doUpdate() {
        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
            cruiser.rotateX(Mouse.getDY() * GameTime.deltaTime)
            cruiser.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
    }
}
