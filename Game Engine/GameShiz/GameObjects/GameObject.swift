import MetalKit

class GameObject: Node {
    
    var modelConstants = ModelConstants()
    private var material = Material()
    private var _textureType: TextureTypes = .None
    
    var mesh: Mesh!
    
    init(meshType: MeshTypes) {
        mesh = Entities.meshes[meshType]
    }
    
    override func update() {
        updateModelConstants()
        super.update()
    }
    
    private func updateModelConstants() {
        modelConstants.modelMatrix = self.modelMatrix
    }
}

extension GameObject: Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Basic])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
        
        renderCommandEncoder.setFragmentBytes(&material, length: Material.stride, index: 1)
        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Linear], index: 0)
        if (material.useTexture) {
            renderCommandEncoder.setFragmentTexture(Entities.textures[_textureType], index: 0)
        }
        
        mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder)
    }
}


extension GameObject {
    public func setMaterialColour(_ colour: SIMD4<Float>) {
        self.material.colour = colour
        self.material.useMaterialColour = true
        self.material.useTexture = false
    }
    
    public func setTexture(_ textureType: TextureTypes) {
        self._textureType = textureType
        self.material.useTexture = true
        self.material.useMaterialColour = false
    }
    
    
    public func setMaterialIsLit(_ isLit: Bool) { self.material.isLit = isLit }
    public func getMaterialIsLit() -> Bool { return self.material.isLit }
    
    public func setMaterialAmbient(_ ambient: SIMD3<Float>) { self.material.ambient = ambient }
    public func setMaterialAmbient(_ ambient: Float) { self.material.ambient = SIMD3<Float>(repeating: ambient) }
    public func addMaterialAmbient(_ value: Float) { self.material.ambient += value }
    public func getMaterialAmbient() -> SIMD3<Float> { return self.material.ambient }
    
    public func setMaterialDiffuse(_ diffuse: SIMD3<Float>) { self.material.diffuse = diffuse }
    public func setMaterialDiffuse(_ diffuse: Float) { self.material.diffuse = SIMD3<Float>(repeating: diffuse) }
    public func addMaterialDiffuse(_ value: Float) { self.material.diffuse += value }
    public func getMaterialDiffuse() -> SIMD3<Float> { return self.material.diffuse }
    
    public func setMaterialSpecular(_ specular: SIMD3<Float>) { self.material.specular = specular }
    public func setMaterialSpecular(_ specular: Float) { self.material.specular = SIMD3<Float>(repeating: specular) }
    public func addMaterialSpecular(_ value: Float) { self.material.specular += value }
    public func getMaterialSpecular() -> SIMD3<Float> { return self.material.specular }
    
    public func setMaterialShininess(_ shininess: Float) { self.material.shininess = shininess }
    public func getMaterialShininess() -> Float { return self.material.shininess }
}
