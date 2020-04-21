import MetalKit

class Water: Node {
    private var _modelConstants = ModelConstants()
    private var _mesh: Mesh!
    
    private var _material: Material? = nil
    
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
        
        renderCommandEncoder.setFragmentTextures([Entities.textures[.WaterReflectionTexture],
                                                  Entities.textures[.WaterRefractionTexture],
                                                  Entities.textures[.WaterDUDV],
                                                  Entities.textures[.WaterNormalMap],
                                                  Entities.textures[.WaterRefractionDepthTexture]], range: 1..<6)

        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
                             material: _material,
                             baseColourSamplerStateType: .Water)
    }
}

extension Water {
    public func useMaterial(_ material: Material) {
        _material = material
    }
}
