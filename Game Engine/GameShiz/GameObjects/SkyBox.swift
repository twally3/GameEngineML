import MetalKit

class SkyBox: Node {
    private var _modelConstants = ModelConstants()
    private var _mesh: Mesh!
    
    init() {
        super.init(name: "Skybox")
        
        self._mesh = Entities.meshes[.SkyBox_Custom]
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
        
        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder, baseColourTextureType: .SkyBox)
    }
}
