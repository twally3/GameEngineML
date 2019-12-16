import MetalKit

class GameObject: Node {
    
    var modelConstants = ModelConstants()
    private var material = Material()
    
    var mesh: Mesh!
    
    init(meshType: MeshTypes) {
        mesh = MeshLibrary.mesh(meshType)
        mesh.setInstanceCount(1)
    }
    
    override func update(deltaTime: Float) {
        updateModelConstants()
    }
    
    private func updateModelConstants() {
        modelConstants.modelMatrix = self.modelMatrix
    }
}

extension GameObject: Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(RenderPipelineStateLibrary.state(.Basic))
        renderCommandEncoder.setDepthStencilState(DepthStencilStateLibrary.depthStencilState(.Less))
        
        renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
        
        renderCommandEncoder.setFragmentBytes(&material, length: Material.stride, index: 1)
        
        mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder)
    }
}


extension GameObject {
    public func setColour(_ colour: SIMD4<Float>) {
        self.material.colour = colour
        self.material.useMaterialColour = true
    }
}
