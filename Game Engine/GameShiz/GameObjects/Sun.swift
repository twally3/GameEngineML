import simd

class Sun: LightObject {
    init() {
//        super.init(name: "Sun")
        super.init(name: "Sun", meshType: .Sphere)
        self.setMaterialColour(SIMD4<Float>(0.5, 0.5, 0.0, 1.0))
        self.setScale(SIMD3<Float>(repeating: 0.3))
        self.setMaterialIsLit(false)
    }
}
