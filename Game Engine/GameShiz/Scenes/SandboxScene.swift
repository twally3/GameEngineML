import MetalKit

class SandboxScene: Scene {
    let camera = DebugCamera()
//    var quad = Quad()
    let cruiser = Cruiser()
    
    override func buildScene() {
        addCamera(camera)
        
        camera.setPositionZ(5)
        
//        quad.setTexture(.PartyPirateParot)
        
        addChild(cruiser)
    }
    
    override func doUpdate() {
//        cruiser.rotateY(GameTime.deltaTime)
        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
            cruiser.rotateX(Mouse.getDY() * GameTime.deltaTime)
            cruiser.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
    }
}
