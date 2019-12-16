import MetalKit

class SandboxScene: Scene {
    
    let camera = DebugCamera()
    
    override func buildScene() {
        addCamera(camera)
        
        camera.position.z = 100
        
        addCubes()
    }
    
    let cubeCollection = CubeCollection(cubesWide: 20, cubesHigh: 20, cubesBack: 20)
    
    func addCubes() {
        addChild(cubeCollection)
    }
    
    override func update(deltaTime: Float) {
        cubeCollection.rotation.z += deltaTime
        super.update(deltaTime: deltaTime)
    }
}
