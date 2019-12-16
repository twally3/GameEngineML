import MetalKit

class SandboxScene: Scene {
    let camera = DebugCamera()
    var quad = Quad()
    
    override func buildScene() {
        addCamera(camera)
        
        camera.setPositionZ(5)
        
        addChild(quad)
    }
    
    override func doUpdate() {
        quad.setPositionX(cos(GameTime.totalGameTime))
    }
}
