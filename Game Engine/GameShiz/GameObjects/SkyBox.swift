import MetalKit

class SkyBox: Node {
    private var _modelConstants = ModelConstants()
    private var _mesh: Mesh!
    private var _texture: MTLTexture!
    
    init() {
        super.init(name: "Skybox")
        
        self._mesh = Entities.meshes[.SkyBox_Custom]
        self._texture = Entities.textures[.SkyBox]
//        self._texture = Entities.textures[.PartyPirateParot]
    }
    
    override func update(){
        // TODO: Set translation of view matrix to 0,0,0
        _modelConstants.modelMatrix = modelMatrix
        
        super.update()
    }
}

extension SkyBox: Renderable{
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.SkyBox])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Skybox])
        
        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)
        
        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Linear], index: 0)
        renderCommandEncoder.setFragmentTexture(_texture, index: 0)

        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder)
    }
}
