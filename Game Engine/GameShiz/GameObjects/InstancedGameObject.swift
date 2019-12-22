import MetalKit

class InstancedGameObject: Node {
    private var _material = Material()
    private var _mesh: Mesh!
    
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
            _nodes.append(Node(name: "\(getName())_InstancedNode"))
        }
    }
    
    func createBuffers(instancCount: Int) {
        _modelConstantsBuffer = Engine.device.makeBuffer(length: ModelConstants.stride(instancCount), options: [])
    }
    
    override func update() {
        var pointer = _modelConstantsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _nodes.count)
        
        for node in _nodes {
            pointer.pointee.modelMatrix = matrix_multiply(self.modelMatrix, node.modelMatrix)
            pointer = pointer.advanced(by: 1)
        }
        
        super.update()
    }
}

extension InstancedGameObject: Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Instanced])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
    
        renderCommandEncoder.setVertexBuffer(_modelConstantsBuffer, offset: 0, index: 2)
        
        renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)
        
        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder)
    }
}

extension InstancedGameObject {
    public func setColour(_ colour: SIMD4<Float>) {
        self._material.colour = colour
        self._material.useMaterialColour = true
    }
    
    public func setColour(_ r: Float, _ g: Float, _ b: Float, _ a: Float) {
        setColour(SIMD4<Float>(r, g, b, a))
    }
}
