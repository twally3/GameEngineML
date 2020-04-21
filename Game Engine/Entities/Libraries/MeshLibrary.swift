import MetalKit

enum MeshTypes {
    case None
    case Triangle_Custom
    case Quad_Custom
    case Cube_Custom
    case Cruiser
    case Sphere
    case SkyBox_Custom
    case Chest
    case TheSuzannes
}

class MeshLibrary: Library<MeshTypes, Mesh> {
    private var _library: [MeshTypes: Mesh] = [:]
    
    override func fillLibrary() {
        _library.updateValue(NoMesh(), forKey: .None)
        _library.updateValue(Triangle_CustomMesh(), forKey: .Triangle_Custom)
        _library.updateValue(Quad_CustomMesh(), forKey: .Quad_Custom)
        _library.updateValue(Cube_CustomMesh(), forKey: .Cube_Custom)
        _library.updateValue(Skybox_CustomMesh(), forKey: .SkyBox_Custom)
        _library.updateValue(Mesh(modelName: "cruiser"), forKey: .Cruiser)
        _library.updateValue(Mesh(modelName: "sphere"), forKey: .Sphere)
        _library.updateValue(Mesh(modelName: "chest"), forKey: .Chest)
        _library.updateValue(Mesh(modelName: "TheSuzannes"), forKey: .TheSuzannes)
    }
    
    override subscript(_ type: MeshTypes) -> Mesh {
        return _library[type]!
    }
}

class Mesh {
    private var _vertices: [Vertex] = []
    private var _vertexBuffer: MTLBuffer!
    private var _vertexCount: Int = 0
    private var _instanceCount: Int = 1
    private var _submeshes: [Submesh] = []
    
    init() {
        createMesh()
        createBuffer()
    }
    
    init(modelName: String) {
        createMeshFromModel(modelName: modelName)
    }
    
    func createMesh() {}
    
    private func createBuffer() {
        if _vertices.count > 0 {
            _vertexBuffer = Engine.device.makeBuffer(bytes: _vertices,
                                                     length: Vertex.stride(_vertices.count),
                                                     options: [])
        }
    }
    
    private func createMeshFromModel(modelName: String, ext: String = "obj") {
        guard let assetURL = Bundle.main.url(forResource: modelName, withExtension: ext) else {
            fatalError("Asset \(modelName) does not exist.")
        }
        
        let descriptor = MTKModelIOVertexDescriptorFromMetal(Graphics.vertexDescriptors[.Basic])
        (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeColor
        (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        (descriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        
        let bufferAllocator = MTKMeshBufferAllocator(device: Engine.device)
        let asset: MDLAsset = MDLAsset(url: assetURL,
                                       vertexDescriptor: descriptor,
                                       bufferAllocator: bufferAllocator,
                                       preserveTopology: true,
                                       error: nil)
        
        var mtkMeshes: [MTKMesh] = []
        do {
            mtkMeshes = try MTKMesh.newMeshes(asset: asset, device: Engine.device).metalKitMeshes
        } catch {
            print("ERROR::LOADING_MESH::__\(modelName)__::\(error)")
        }
        
        let mtkMesh = mtkMeshes[0]
        self._vertexBuffer = mtkMesh.vertexBuffers[0].buffer
        self._vertexCount = mtkMesh.vertexCount
        for i in 0..<mtkMesh.submeshes.count {
            let mtkSubmesh = mtkMesh.submeshes[i]
            let submesh = Submesh(mtkSubmesh: mtkSubmesh)
            addSubmesh(submesh)
        }
    }
    
    func setInstanceCount(_ count: Int) {
        self._instanceCount = count
    }
    
    func addSubmesh(_ submesh: Submesh) {
        _submeshes.append(submesh)
    }
    
    func addVertex(position: SIMD3<Float>,
                   colour: SIMD4<Float> = SIMD4<Float>(1, 0, 1, 1),
                   textureCoordinate: SIMD2<Float> = SIMD2<Float>(0, 0),
                   normal: SIMD3<Float> = SIMD3<Float>(0, 1, 0)) {
        _vertices.append(Vertex(position: position,
                                colour: colour,
                                textureCoordinate: textureCoordinate,
                                normal: normal))
    }
    
    func drawPrimitives(renderCommandEncoder: MTLRenderCommandEncoder) {
        if _vertexBuffer != nil {
            renderCommandEncoder.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)
            
            if _submeshes.count > 0 {
                for submesh in _submeshes {
                    renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                               indexCount: submesh.indexCount,
                                                               indexType: submesh.indexType,
                                                               indexBuffer: submesh.indexBuffer,
                                                               indexBufferOffset: submesh.indexBufferOffset)
                }
            } else {
                renderCommandEncoder.drawPrimitives(type: .triangle,
                                                    vertexStart: 0,
                                                    vertexCount: _vertices.count,
                                                    instanceCount: _instanceCount)
            }
        }
    }
}

class Submesh {
    private var _indices: [UInt32] = []
    
    private var _indexCount: Int = 0
    public var indexCount: Int { return _indexCount }
    
    private var _indexBuffer: MTLBuffer!
    public var indexBuffer: MTLBuffer { return _indexBuffer }
    
    private var _primitiveType: MTLPrimitiveType = .triangle
    public var primitiveType: MTLPrimitiveType { return _primitiveType }
    
    private var _indexType: MTLIndexType = .uint32
    public var indexType: MTLIndexType { return _indexType }
    
    private var _indexBufferOffset: Int = 0
    public var indexBufferOffset: Int { return _indexBufferOffset }
    
    init(indices: [UInt32]) {
        self._indices = indices
        self._indexCount = indices.count
        createIndexBuffer()
    }
    
    init(mtkSubmesh: MTKSubmesh) {
        _indexBuffer = mtkSubmesh.indexBuffer.buffer
        _indexCount = mtkSubmesh.indexCount
        _indexType = mtkSubmesh.indexType
        _primitiveType = mtkSubmesh.primitiveType
    }
    
    private func createIndexBuffer() {
        if _indices.count > 0 {
            _indexBuffer = Engine.device.makeBuffer(bytes: _indices,
                                                    length: UInt32.stride(_indices.count),
                                                    options: [])
        }
    }
}

class NoMesh: Mesh { }

class Triangle_CustomMesh: Mesh {
    override func createMesh() {
        addVertex(position: SIMD3<Float>(0, 1, 0), colour: SIMD4<Float>(1, 0, 0, 1))
        addVertex(position: SIMD3<Float>(-1, -1, 0), colour: SIMD4<Float>(0, 1, 0, 1))
        addVertex(position: SIMD3<Float>(1, -1, 0), colour: SIMD4<Float>(0, 0, 1, 1))
    }
}

class Quad_CustomMesh: Mesh {
    override func createMesh() {
        addVertex(position: SIMD3<Float>(1, 1, 0), colour: SIMD4<Float>(1, 0, 0, 1), textureCoordinate: SIMD2<Float>(1, 0), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>(-1, 1, 0), colour: SIMD4<Float>(0, 1, 0, 1), textureCoordinate: SIMD2<Float>(0, 0), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>(-1, -1, 0), colour: SIMD4<Float>(0, 0, 1, 1), textureCoordinate: SIMD2<Float>(0, 1), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>(1, -1, 0), colour: SIMD4<Float>(1, 0, 1, 1), textureCoordinate: SIMD2<Float>(1, 1), normal: SIMD3<Float>(0, 0, 1))
        
        addSubmesh(Submesh(indices: [0, 1, 2, 0, 2, 3]))
    }
}

class Cube_CustomMesh: Mesh {
    override func createMesh() {
        //Left
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 0.5, 0.0, 1.0), normal: SIMD3<Float>(-1, 0, 0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 0.5, 1.0), normal: SIMD3<Float>(-1, 0, 0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(0.0, 0.5, 1.0, 1.0), normal: SIMD3<Float>(-1, 0, 0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 1.0, 0.0, 1.0), normal: SIMD3<Float>(-1, 0, 0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0), normal: SIMD3<Float>(-1, 0, 0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0,-1.0), colour: SIMD4<Float>(1.0, 0.0, 1.0, 1.0), normal: SIMD3<Float>(-1, 0, 0))
        
        //RIGHT
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 0.0, 0.5, 1.0), normal: SIMD3<Float>(1, 0, 0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0,-1.0), colour: SIMD4<Float>(0.0, 1.0, 0.0, 1.0), normal: SIMD3<Float>(1, 0, 0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0,-1.0), colour: SIMD4<Float>(0.0, 0.5, 1.0, 1.0), normal: SIMD3<Float>(1, 0, 0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 1.0, 0.0, 1.0), normal: SIMD3<Float>(1, 0, 0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0), normal: SIMD3<Float>(1, 0, 0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(1.0, 0.5, 1.0, 1.0), normal: SIMD3<Float>(1, 0, 0))
        
        //TOP
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 0.0, 0.0, 1.0), normal: SIMD3<Float>(0, 1, 0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0,-1.0), colour: SIMD4<Float>(0.0, 1.0, 0.0, 1.0), normal: SIMD3<Float>(0, 1, 0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0,-1.0), colour: SIMD4<Float>(0.0, 0.0, 1.0, 1.0), normal: SIMD3<Float>(0, 1, 0))
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 1.0, 0.0, 1.0), normal: SIMD3<Float>(0, 1, 0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0,-1.0), colour: SIMD4<Float>(0.5, 1.0, 1.0, 1.0), normal: SIMD3<Float>(0, 1, 0))
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 0.0, 1.0, 1.0), normal: SIMD3<Float>(0, 1, 0))
        
        //BOTTOM
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(1.0, 0.5, 0.0, 1.0), normal: SIMD3<Float>(0, -1, 0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(0.5, 1.0, 0.0, 1.0), normal: SIMD3<Float>(0, -1, 0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0,-1.0), colour: SIMD4<Float>(0.0, 0.0, 1.0, 1.0), normal: SIMD3<Float>(0, -1, 0))
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(1.0, 1.0, 0.5, 1.0), normal: SIMD3<Float>(0, -1, 0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0), normal: SIMD3<Float>(0, -1, 0))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 0.5, 1.0, 1.0), normal: SIMD3<Float>(0, -1, 0))
        
        //BACK
        addVertex(position: SIMD3<Float>( 1.0, 1.0,-1.0), colour: SIMD4<Float>(1.0, 0.5, 0.0, 1.0), normal: SIMD3<Float>(0, 0, -1))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(0.5, 1.0, 0.0, 1.0), normal: SIMD3<Float>(0, 0, -1))
        addVertex(position: SIMD3<Float>(-1.0, 1.0,-1.0), colour: SIMD4<Float>(0.0, 0.0, 1.0, 1.0), normal: SIMD3<Float>(0, 0, -1))
        addVertex(position: SIMD3<Float>( 1.0, 1.0,-1.0), colour: SIMD4<Float>(1.0, 1.0, 0.0, 1.0), normal: SIMD3<Float>(0, 0, -1))
        addVertex(position: SIMD3<Float>( 1.0,-1.0,-1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0), normal: SIMD3<Float>(0, 0, -1))
        addVertex(position: SIMD3<Float>(-1.0,-1.0,-1.0), colour: SIMD4<Float>(1.0, 0.5, 1.0, 1.0), normal: SIMD3<Float>(0, 0, -1))
        
        //FRONT
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 0.5, 0.0, 1.0), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>(-1.0,-1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 0.0, 1.0), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(0.5, 0.0, 1.0, 1.0), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>( 1.0, 1.0, 1.0), colour: SIMD4<Float>(1.0, 1.0, 0.5, 1.0), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>(-1.0, 1.0, 1.0), colour: SIMD4<Float>(0.0, 1.0, 1.0, 1.0), normal: SIMD3<Float>(0, 0, 1))
        addVertex(position: SIMD3<Float>( 1.0,-1.0, 1.0), colour: SIMD4<Float>(1.0, 0.0, 1.0, 1.0), normal: SIMD3<Float>(0, 0, 1))
    }
}

class Skybox_CustomMesh: CustomMesh {
    override func createMesh() {
        // + Y
        addVertex(position: SIMD3<Float>(-0.5,  0.5,  0.5), normal: SIMD3<Float>(0.0, -1.0,  0.0))
        addVertex(position: SIMD3<Float>( 0.5,  0.5,  0.5), normal: SIMD3<Float>(0.0, -1.0,  0.0))
        addVertex(position: SIMD3<Float>( 0.5,  0.5, -0.5), normal: SIMD3<Float>(0.0, -1.0,  0.0))
        addVertex(position: SIMD3<Float>(-0.5,  0.5, -0.5), normal: SIMD3<Float>(0.0, -1.0,  0.0))

        // -Y
        addVertex(position: SIMD3<Float>(-0.5, -0.5, -0.5), normal: SIMD3<Float>(0.0,  1.0,  0.0))
        addVertex(position: SIMD3<Float>( 0.5, -0.5, -0.5), normal: SIMD3<Float>(0.0,  1.0,  0.0))
        addVertex(position: SIMD3<Float>( 0.5, -0.5,  0.5), normal: SIMD3<Float>(0.0,  1.0,  0.0))
        addVertex(position: SIMD3<Float>(-0.5, -0.5,  0.5), normal: SIMD3<Float>(0.0,  1.0,  0.0))

        // +Z
        addVertex(position: SIMD3<Float>(-0.5, -0.5,  0.5), normal: SIMD3<Float>(0.0,  0.0, -1.0))
        addVertex(position: SIMD3<Float>( 0.5, -0.5,  0.5), normal: SIMD3<Float>(0.0,  0.0, -1.0))
        addVertex(position: SIMD3<Float>( 0.5,  0.5,  0.5), normal: SIMD3<Float>(0.0,  0.0, -1.0))
        addVertex(position: SIMD3<Float>(-0.5,  0.5,  0.5), normal: SIMD3<Float>(0.0,  0.0, -1.0))

        // -Z
        addVertex(position: SIMD3<Float>( 0.5, -0.5, -0.5), normal: SIMD3<Float>(0.0,  0.0,  1.0))
        addVertex(position: SIMD3<Float>(-0.5, -0.5, -0.5), normal: SIMD3<Float>(0.0,  0.0,  1.0))
        addVertex(position: SIMD3<Float>(-0.5,  0.5, -0.5), normal: SIMD3<Float>(0.0,  0.0,  1.0))
        addVertex(position: SIMD3<Float>( 0.5,  0.5, -0.5), normal: SIMD3<Float>(0.0,  0.0,  1.0))

        // -X
        addVertex(position: SIMD3<Float>(-0.5, -0.5, -0.5), normal: SIMD3<Float>(1.0,  0.0,  0.0))
        addVertex(position: SIMD3<Float>(-0.5, -0.5,  0.5), normal: SIMD3<Float>(1.0,  0.0,  0.0))
        addVertex(position: SIMD3<Float>(-0.5,  0.5,  0.5), normal: SIMD3<Float>(1.0,  0.0,  0.0))
        addVertex(position: SIMD3<Float>(-0.5,  0.5, -0.5), normal: SIMD3<Float>(1.0,  0.0,  0.0))

        // +X
        addVertex(position: SIMD3<Float>( 0.5, -0.5,  0.5), normal: SIMD3<Float>(-1.0,  0.0,  0.0))
        addVertex(position: SIMD3<Float>( 0.5, -0.5, -0.5), normal: SIMD3<Float>(-1.0,  0.0,  0.0))
        addVertex(position: SIMD3<Float>( 0.5,  0.5, -0.5), normal: SIMD3<Float>(-1.0,  0.0,  0.0))
        addVertex(position: SIMD3<Float>( 0.5,  0.5,  0.5), normal: SIMD3<Float>(-1.0,  0.0,  0.0))

        addIndices([
            0,  3,  2,  2,  1,  0,
            4,  7,  6,  6,  5,  4,
            8, 11, 10, 10,  9,  8,
            12, 15, 14, 14, 13, 12,
            16, 19, 18, 18, 17, 16,
            20, 23, 22, 22, 21, 20
        ])
    }
}
