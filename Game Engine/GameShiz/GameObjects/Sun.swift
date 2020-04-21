import simd

class Sun: LightObject {
    init() {
        super.init(name: "Sun", meshType: .Sphere)
        self.setScale(SIMD3<Float>(repeating: 0.3))
        self.setMaterialIsLit(false)
    }
}
