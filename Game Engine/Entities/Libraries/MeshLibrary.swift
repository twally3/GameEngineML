import MetalKit

enum MeshTypes {
    case None
    case Triangle_Custom
    case Quad_Custom
    case Cube_Custom
    case Cruiser
    case Sphere
}

class MeshLibrary: Library<MeshTypes, Mesh> {
    private var _library: [MeshTypes: Mesh] = [:]
    
    override func fillLibrary() {
        _library.updateValue(NoMesh(), forKey: .None)
        _library.updateValue(Triangle_CustomMesh(), forKey: .Triangle_Custom)
        _library.updateValue(Quad_CustomMesh(), forKey: .Quad_Custom)
        _library.updateValue(Cube_CustomMesh(), forKey: .Cube_Custom)
        _library.updateValue(ModelMesh(modelName: "cruiser"), forKey: .Cruiser)
        _library.updateValue(ModelMesh(modelName: "sphere"), forKey: .Sphere)
    }
    
    override subscript(_ type: MeshTypes) -> Mesh {
        return _library[type]!
    }
}

protocol Mesh {
    func setInstanceCount(_ count: Int)
    func drawPrimitives(renderCommandEncoder: MTLRenderCommandEncoder)
}

class NoMesh: Mesh {
    func setInstanceCount(_ count: Int) {}
    func drawPrimitives(renderCommandEncoder: MTLRenderCommandEncoder) {}
}

class ModelMesh: Mesh {
    private var _meshes: [Any]!
    private var _instanceCount: Int = 1
    
    init(modelName: String) {
        loadModel(modelName: modelName)
    }
    
    func loadModel(modelName: String) {
        guard let assetURL = Bundle.main.url(forResource: modelName, withExtension: "obj") else {
            fatalError("Asset \(modelName) does not exist.")
        }
        
        let descriptor = MTKModelIOVertexDescriptorFromMetal(Graphics.vertexDescriptors[.Basic])
        (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeColor
        (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        (descriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        
        let bufferAllocator = MTKMeshBufferAllocator(device: Engine.device)
        let asset = MDLAsset(url: assetURL, vertexDescriptor: descriptor, bufferAllocator: bufferAllocator)
        
        do {
            self._meshes = try MTKMesh.newMeshes(asset: asset, device: Engine.device).metalKitMeshes
        } catch let error as NSError {
            print("ERROR::LOADING_MESH::__\(modelName)__::\(error)")
        }
    }
    
    func setInstanceCount(_ count: Int) {
        self._instanceCount = count
    }
    
    func drawPrimitives(renderCommandEncoder: MTLRenderCommandEncoder) {
        guard let meshes = self._meshes as? [MTKMesh] else { return }
        for mesh in meshes {
            for vertexBuffer in mesh.vertexBuffers {
                renderCommandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
                
                for submesh in mesh.submeshes {
                    renderCommandEncoder.drawIndexedPrimitives(
                        type: submesh.primitiveType,
                        indexCount: submesh.indexCount,
                        indexType: submesh.indexType,
                        indexBuffer: submesh.indexBuffer.buffer,
                        indexBufferOffset: submesh.indexBuffer.offset,
                        instanceCount: self._instanceCount
                    )
                }
            }
        }
    }
}

class CustomMesh: Mesh {
    private var _vertices: [Vertex] = []
    private var _indices: [UInt32] = []
    private var _vertexBuffer: MTLBuffer!
    private var _indexBuffer: MTLBuffer!
    private var _instanceCount: Int = 1
    var vertexCount: Int! {
        return _vertices.count
    }
    var indexCount: Int! {
        return _indices.count
    }
    
    init() {
        createMesh()
        createBuffers()
    }
    
    func createMesh() {}
    
    func createBuffers() {
        if (vertexCount > 0) {
            _vertexBuffer = Engine.device.makeBuffer(bytes: _vertices, length: Vertex.stride(vertexCount), options: [])
        }
        
        if (indexCount > 0) {
            _indexBuffer = Engine.device.makeBuffer(bytes: _indices, length: UInt32.stride(indexCount), options: [])
        }
    }
    
    func addVertex(position: SIMD3<Float>, colour: SIMD4<Float>, textureCoordinate: SIMD2<Float> = SIMD2<Float>(repeating: 0), normal: SIMD3<Float> = SIMD3<Float>(0, 1, 0)) {
        _vertices.append(Vertex(position: position, colour: colour, textureCoordinate: textureCoordinate, normal: normal))
    }
    
    func addIndices(_ indices: [UInt32]) {
        _indices.append(contentsOf: indices)
    }
    
    func setInstanceCount(_ count: Int) {
        _instanceCount = count
    }
    
    func drawPrimitives(renderCommandEncoder: MTLRenderCommandEncoder) {
        if (vertexCount > 0) {
            renderCommandEncoder.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)
            
            if (indexCount > 0) {
                renderCommandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indexCount, indexType: .uint32, indexBuffer: _indexBuffer, indexBufferOffset: 0, instanceCount: _instanceCount)
            }
            else {
                renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: _instanceCount)
            }
        }
    }
}

class Triangle_CustomMesh: CustomMesh {
    override func createMesh() {
        addVertex(position: SIMD3<Float>(0, 1, 0), colour: SIMD4<Float>(1, 0, 0, 1))
        addVertex(position: SIMD3<Float>(-1, -1, 0), colour: SIMD4<Float>(0, 1, 0, 1))
        addVertex(position: SIMD3<Float>(1, -1, 0), colour: SIMD4<Float>(0, 0, 1, 1))
    }
}

class Quad_CustomMesh: CustomMesh {
    override func createMesh() {
        addVertex(position: SIMD3<Float>(1, 1, 0), colour: SIMD4<Float>(1, 0, 0, 1), textureCoordinate: SIMD2<Float>(1, 0), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>(-1, 1, 0), colour: SIMD4<Float>(0, 1, 0, 1), textureCoordinate: SIMD2<Float>(0, 0), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>(-1, -1, 0), colour: SIMD4<Float>(0, 0, 1, 1), textureCoordinate: SIMD2<Float>(0, 1), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>(1, -1, 0), colour: SIMD4<Float>(1, 0, 1, 1), textureCoordinate: SIMD2<Float>(1, 1), normal: SIMD3<Float>(0, 0, 1))
        
        addIndices([0, 1, 2, 0, 2 ,3])
    }
}

class Cube_CustomMesh: CustomMesh {
    override func createMesh() {
        //Left
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 0.5, 0.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 0.5, 1.0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(0.0, 0.5, 1.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 1.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0,-1.0), colour: SIMD4<Float>(1.0, 0.0, 1.0, 1.0))
        
        //RIGHT
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 0.0, 0.5, 1.0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0,-1.0), colour: SIMD4<Float>(0.0, 1.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0,-1.0), colour: SIMD4<Float>(0.0, 0.5, 1.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 1.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(1.0, 0.5, 1.0, 1.0))
        
        //TOP
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 0.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0,-1.0), colour: SIMD4<Float>(0.0, 1.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0,-1.0), colour: SIMD4<Float>(0.0, 0.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 1.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0,-1.0), colour: SIMD4<Float>(0.5, 1.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 0.0, 1.0, 1.0))
        
        //BOTTOM
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(1.0, 0.5, 0.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(0.5, 1.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0,-1.0), colour: SIMD4<Float>(0.0, 0.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(1.0, 1.0, 0.5, 1.0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 0.5, 1.0, 1.0))
        
        //BACK
        addVertex(position: SIMD3<Float>( 1.0, 1.0,-1.0), colour: SIMD4<Float>(1.0, 0.5, 0.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(0.5, 1.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0,-1.0), colour: SIMD4<Float>(0.0, 0.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0,-1.0), colour: SIMD4<Float>(1.0, 1.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0,-1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 0.5, 1.0, 1.0))
        
        //FRONT
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 0.5, 0.0, 1.0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 0.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(0.5, 0.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 1.0, 0.5, 1.0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(1.0, 0.0, 1.0, 1.0))
    }
}
