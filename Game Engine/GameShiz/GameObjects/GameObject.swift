import MetalKit

class GameObject: Node {
    private var _modelConstants = ModelConstants()
    private var _material = Material()
    private var _textureType: TextureTypes = .None
    private var _mesh: Mesh!
    
    private var _texture: MTLTexture!
    
    var moveFactor: Float = 0;

    init(name: String, meshType: MeshTypes) {
        super.init(name: name)
        _mesh = Entities.meshes[meshType]
    }
    
    override func update() {
        _modelConstants.modelMatrix = self.modelMatrix
        
        super.update()
    }
}

extension GameObject: Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Basic])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)
        
        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Nearest], index: 0)
        renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)
//        renderCommandEncoder.setTriangleFillMode(.lines)
        if (_material.useTexture) {
            if (_texture != nil) {
                renderCommandEncoder.setFragmentTexture(_texture, index: 0)
            } else {
                renderCommandEncoder.setFragmentTexture(Entities.textures[_textureType], index: 0)
            }
        }
        
        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder)
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, reflectionTexture: MTLTexture?, refractionTexture: MTLTexture?, refractionDepthTexture: MTLTexture?) {
        moveFactor += 0.03 * GameTime.deltaTime
        moveFactor = moveFactor.truncatingRemainder(dividingBy: 1)
        renderCommandEncoder.setFragmentBytes(&moveFactor, length: Float.size, index: 4)
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Water])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])

        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)

        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Nearest], index: 0)
        renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)

        renderCommandEncoder.setFragmentTextures([reflectionTexture,
                                                  refractionTexture,
                                                  Entities.textures[.WaterDUDV],
                                                  Entities.textures[.WaterNormalMap],
                                                  refractionDepthTexture], range: 0..<5)

        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder)
    }
}


extension GameObject {
    public func setMaterialColour(_ colour: SIMD4<Float>) {
        self._material.colour = colour
        self._material.useMaterialColour = true
        self._material.useTexture = false
    }
    
    public func setMaterialColour(_ r: Float, _ g: Float, _ b: Float, _ a: Float) {
        setMaterialColour(SIMD4<Float>(r, g, b, a))
    }
    
    public func setTexture(_ textureType: TextureTypes) {
        self._textureType = textureType
        self._material.useTexture = true
        self._material.useMaterialColour = false
    }
    
    public func setTexture(_ texture: MTLTexture) {
        self._texture = texture
        self._material.useTexture = true
        self._material.useMaterialColour = false
    }
    
    public func setMesh(_ mesh: Mesh) {
        self._mesh = mesh
    }
    
    
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
