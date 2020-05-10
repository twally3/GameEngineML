import MetalKit

class Sphere: GameObject {
    init() {
        super.init(name: "Sphere", meshType: .Sphere)
        
        self.boundingSphere.radius = 0.5
    }
}
