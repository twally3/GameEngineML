import MetalKit

class SandboxScene: Scene {
    let camera = DebugCamera()
    let cruiser = Cruiser()
    
    let leftSun = Sun()
    let middleSun = Sun()
    let rightSun = Sun()
    
    override func buildScene() {
        camera.setPositionZ(6)
        addCamera(camera)
        
        leftSun.setPosition(SIMD3<Float>(-1, 1, 0))
        leftSun.setMaterialIsLit(false)
        leftSun.setMaterialColour(SIMD4<Float>(1, 0, 0, 1))
        leftSun.setLightColour(SIMD3<Float>(1, 0, 0))
        addLight(leftSun)
        
        middleSun.setPosition(SIMD3<Float>(0, 1, 0))
        middleSun.setMaterialIsLit(false)
        middleSun.setMaterialColour(SIMD4<Float>(1, 1, 1, 1))
        middleSun.setLightColour(SIMD3<Float>(1, 1, 1))
        addLight(middleSun)
        
        rightSun.setPosition(SIMD3<Float>(1, 1, 0))
        rightSun.setMaterialIsLit(false)
        rightSun.setMaterialColour(SIMD4<Float>(0, 0, 1, 1))
        rightSun.setLightColour(SIMD3<Float>(0, 0, 1))
        addLight(rightSun)
        
        cruiser.setRotation(SIMD3<Float>(repeating: 0.3))
        addChild(cruiser)
    }
    
    override func doUpdate() {
        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
            cruiser.rotateX(Mouse.getDY() * GameTime.deltaTime)
            cruiser.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
    }
}
