import MetalKit

class SandboxScene: Scene {
    let camera = DebugCamera()
    var quad = Quad()
    
    override func buildScene() {
        addCamera(camera)
        
        camera.setPositionZ(5)
        
        quad.setTexture(.PartyPirateParot)
        
        addChild(quad)
    }
    
    override func doUpdate() {
        quad.rotateY(GameTime.deltaTime)
    }
}
