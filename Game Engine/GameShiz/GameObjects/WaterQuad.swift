import simd

class WaterQuad: Water {
    init() {
        super.init(name: "Water Quad", meshType: .Quad_Custom)
        addMaterial()
    }
    
    func addMaterial() {
        var material = Material()
        
        material.isLit = true
        material.diffuse = SIMD3<Float>(0, 0, 0)
        material.specular = SIMD3<Float>(0.3, 0.3, 0.3)
        material.ambient = SIMD3<Float>(1, 1, 1)
        material.shininess = 40
        
        useMaterial(material)
    }
}
