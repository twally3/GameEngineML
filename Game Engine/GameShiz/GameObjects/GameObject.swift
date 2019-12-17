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
}
