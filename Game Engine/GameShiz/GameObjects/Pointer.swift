import MetalKit

class Pointer: GameObject {
    private var camera: Camera!
    
    init(camera: Camera) {
        super.init(meshType: .Triangle_Custom)
        self.setName("Pointer")
        
        self.camera = camera
    }
    
    override func doUpdate() {
        self.rotateZ(-atan2f(
            Mouse.GetMouseViewportPosition().x - getPositionX() + camera.getPositionX(),
            Mouse.GetMouseViewportPosition().y - getPositionY() + camera.getPositionY()
        ))
    }
}
