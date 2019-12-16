import MetalKit

class InstancedGameObject: Node {
    private var _mesh: Mesh!
    
    var material = Material()
    
    internal var _nodes: [Node] = []    
    private var _modelConstantsBuffer: MTLBuffer!
    
    init(meshType: MeshTypes, instanceCount: Int) {
        super.init(name: "Instantiated Game Object")
        
        self._mesh = Entities.meshes[meshType]
        self._mesh.setInstanceCount(instanceCount)
        self.generateInstances(instanceCount: instanceCount)
        self.createBuffers(instancCount: instanceCount)
    }
    
    func generateInstances(instanceCount: Int) {
        for _ in 0..<instanceCount {
            _nodes.append(Node())
        }
    }
    
    func createBuffers(instancCount: Int) {
        _modelConstantsBuffer = Engine.device.makeBuffer(length: ModelConstants.stride(instancCount), options: [])
    }
    
    private func updateModelConstantsBuffer() {
        var pointer = _modelConstantsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _nodes.count)
        
        for node in _nodes {
            pointer.pointee.modelMatrix = matrix_multiply(self.modelMatrix, node.modelMatrix)
            pointer = pointer.advanced(by: 1)
        }
    }
    
    override func update() {
        updateModelConstantsBuffer()
        super.update()
    }
}

extension InstancedGameObject: Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Instanced])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
    
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
