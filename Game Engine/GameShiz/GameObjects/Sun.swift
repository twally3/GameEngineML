import simd

class Sun: LightObject {
    init() {
        super.init(name: "Sun")
        self.setScale(SIMD3<Float>(repeating: 0.3))
    }
}
