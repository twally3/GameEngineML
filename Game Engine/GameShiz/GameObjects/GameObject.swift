import MetalKit

class GameObject: Node {
    var renderPipelineStateType: RenderPipelineStateTypes { .Basic }

    private var _modelConstants = ModelConstants()
    private var _mesh: Mesh!
    
    private var _material: Material? = nil
    private var _baseColourTextureType: TextureTypes = .None
    private var _baseNormalMapTextureType: TextureTypes = .None
    
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
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[self.renderPipelineStateType])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)
        
        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
                             material: _material,
                             baseColourTextureType: _baseColourTextureType,
                             baseNormalMapTextureType: _baseNormalMapTextureType)
    }
}


extension GameObject {
    public func useBaseColourTexture(_ textureType: TextureTypes) {
        self._baseColourTextureType = textureType
    }
    
    public func useBaseNormalMapTexture(_ textureType: TextureTypes) {
        self._baseNormalMapTextureType = textureType
    }
    
    public func useMaterial(_ material: Material) {
        _material = material
    }
}
