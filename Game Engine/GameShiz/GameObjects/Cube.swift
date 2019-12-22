import MetalKit

class Cube: GameObject {
    init() {
        super.init(name: "Cube", meshType: .Cube_Custom)
    }
    
    override func doUpdate() {
        self.rotateX(GameTime.deltaTime)
        self.rotateZ(GameTime.deltaTime)
    }
}
