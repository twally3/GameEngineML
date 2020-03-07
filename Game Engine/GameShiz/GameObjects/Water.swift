import MetalKit

class Water: Node {
    private var _modelConstants = ModelConstants()
    private var _material = Material()
    private var _mesh: Mesh!
    
    var moveFactor: Float = 1;

    init(name: String, meshType: MeshTypes) {
        super.init(name: name)
        _mesh = Entities.meshes[meshType]
    }
    
    override func update() {
        _modelConstants.modelMatrix = self.modelMatrix
        
        super.update()
    }
}

extension Water: Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        moveFactor += 0.03 * GameTime.deltaTime
        moveFactor = moveFactor.truncatingRemainder(dividingBy: 1)
        renderCommandEncoder.setFragmentBytes(&moveFactor, length: Float.size, index: 4)
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Water])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])

        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)

        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Nearest], index: 0)
        renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)
        
        renderCommandEncoder.setFragmentTextures([Entities.textures[.WaterReflectionTexture],
                                                  Entities.textures[.WaterRefractionTexture],
                                                  Entities.textures[.WaterDUDV],
                                                  Entities.textures[.WaterNormalMap],
                                                  Entities.textures[.WaterRefractionDepthTexture]], range: 0..<5)

        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder)
    }
}

extension Water {
    public func setMaterialIsLit(_ isLit: Bool) { self._material.isLit = isLit }
    public func getMaterialIsLit() -> Bool { return self._material.isLit }
    
    public func setMaterialAmbient(_ ambient: SIMD3<Float>) { self._material.ambient = ambient }
    public func setMaterialAmbient(_ ambient: Float) { self._material.ambient = SIMD3<Float>(repeating: ambient) }
    public func addMaterialAmbient(_ value: Float) { self._material.ambient += value }
    public func getMaterialAmbient() -> SIMD3<Float> { return self._material.ambient }
    
    public func setMaterialDiffuse(_ diffuse: SIMD3<Float>) { self._material.diffuse = diffuse }
    public func setMaterialDiffuse(_ diffuse: Float) { self._material.diffuse = SIMD3<Float>(repeating: diffuse) }
    public func addMaterialDiffuse(_ value: Float) { self._material.diffuse += value }
    public func getMaterialDiffuse() -> SIMD3<Float> { return self._material.diffuse }
    
    public func setMaterialSpecular(_ specular: SIMD3<Float>) { self._material.specular = specular }
    public func setMaterialSpecular(_ specular: Float) { self._material.specular = SIMD3<Float>(repeating: specular) }
    public func addMaterialSpecular(_ value: Float) { self._material.specular += value }
    public func getMaterialSpecular() -> SIMD3<Float> { return self._material.specular }
    
    public func setMaterialShininess(_ shininess: Float) { self._material.shininess = shininess }
    public func getMaterialShininess() -> Float { return self._material.shininess }
}
