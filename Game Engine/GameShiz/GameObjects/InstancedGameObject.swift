import MetalKit

class InstancedGameObject: Node {
    var material = Material()
    
    private var _mesh: Mesh!
    internal var _nodes: [Node] = []
    private var _modelConstants: [ModelConstants] = []
    
    private var _modelConstantsBuffer: MTLBuffer!
    
    init(meshType: MeshTypes, instanceCount: Int) {
        super.init()
        
        self._mesh = MeshLibrary.mesh(meshType)
        self._mesh.setInstanceCount(instanceCount)
        self.generateInstances(instanceCount: instanceCount)
        self.createBuffers(instancCount: instanceCount)
    }
    
    func generateInstances(instanceCount: Int) {
        for _ in 0..<instanceCount {
            _nodes.append(Node())
            _modelConstants.append(ModelConstants())
        }
    }
    
    func createBuffers(instancCount: Int) {
        _modelConstantsBuffer = Engine.device.makeBuffer(length: ModelConstants.stride(instancCount), options: [])
    }
    
    override func update(deltaTime: Float) {
        var pointer = _modelConstantsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _modelConstants.count)
        
        for node in _nodes {
            pointer.pointee.modelMatrix = matrix_multiply(self.modelMatrix, node.modelMatrix)
            pointer = pointer.advanced(by: 1)
        }
        
        super.update(deltaTime: deltaTime)
    }
}

extension InstancedGameObject: Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(RenderPipelineStateLibrary.state(.Instanced))
        renderCommandEncoder.setDepthStencilState(DepthStencilStateLibrary.depthStencilState(.Less))
    
        renderCommandEncoder.setVertexBuffer(_modelConstantsBuffer, offset: 0, index: 2)
        
        renderCommandEncoder.setFragmentBytes(&material, length: Material.stride, index: 1)
        
        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder)
    }
}

extension InstancedGameObject {
    public func setColour(_ colour: SIMD4<Float>) {
        self.material.colour = colour
        self.material.useMaterialColour = true
    }
}
