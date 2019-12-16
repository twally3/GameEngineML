import MetalKit

class SandboxScene: Scene {
    
    let camera = DebugCamera()
    let cube = Cube()
    
    override func buildScene() {
        addCamera(camera)
        
        camera.position.z = 5
        
        addChild(cube)
    }
    
    override func update(deltaTime: Float) {
        cube.rotation.x += deltaTime
        cube.rotation.y += deltaTime
        
        super.update(deltaTime: deltaTime)
    }
}
