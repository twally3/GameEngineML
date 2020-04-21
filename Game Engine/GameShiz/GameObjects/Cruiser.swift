import MetalKit

class Cruiser: GameObject {
    init() {
        super.init(name: "Cruiser", meshType: .Cruiser)
        
        useBaseColourTexture(.Cruiser)
    }
}
