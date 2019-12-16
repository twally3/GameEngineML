import MetalKit

class Cube: GameObject {
    
    init() {
        super.init(meshType: .Cube_Custom)
        self.setName("Cube")
    }
    
    override func doUpdate() {
        self.rotateX(GameTime.deltaTime)
        self.rotateZ(GameTime.deltaTime)
    }
    
}
