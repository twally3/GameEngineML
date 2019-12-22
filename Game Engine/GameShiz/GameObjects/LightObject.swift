import MetalKit

class LightObject: GameObject {
    var lightData = LightData()
    
    init(name: String) {
        super.init(name: name, meshType: .None)
    }
    
    override init(name: String, meshType: MeshTypes) {
        super.init(name: name, meshType: meshType)
    }
    
    override func update() {
        self.lightData.position = self.getPosition()
        super.update()
    }
}

extension LightObject {
    public func setLightColour(_ colour: SIMD3<Float>) { self.lightData.colour = colour }
    public func setLightColour(_ r: Float, _ g: Float, _ b: Float) { self.lightData.colour = SIMD3<Float>(r, g, b) }
    public func getLightColour() -> SIMD3<Float> { return self.lightData.colour }
    
    public func setLightBrightness(_ brightness: Float) { self.lightData.brightness = brightness }
    public func getLightBrightness() -> Float { return self.lightData.brightness }
    
    public func setLightAmbientIntensity(_ intensity: Float) { self.lightData.ambientIntensity = intensity }
    public func getLightAmbientIntensity() -> Float { return self.lightData.ambientIntensity }
    
    public func setLightDiffuseIntensity(_ intensity: Float) { self.lightData.diffuseIntensity = intensity }
    public func getLightDiffuseIntensity() -> Float { return self.lightData.diffuseIntensity }
    
    public func setLightSpecularIntensity(_ intensity: Float) { self.lightData.specularIntensity = intensity }
    public func getLightSpecularIntensity() -> Float { return self.lightData.specularIntensity }
}
