import MetalKit

enum MeshTypes {
    case None
    case Triangle_Custom
    case Quad_Custom
    case Cube_Custom
    case Cruiser
    case Sphere
    case Chest
    case TheSuzannes
    case Quad
    case Well
    
    // Terrain pack stuff
    case GroundGrass
    case TreePineA
    case TreePineB
    case TreePineC
    case FlowerRed
    case FlowerYellow
    case FlowerPurple
}

class MeshLibrary: Library<MeshTypes, Mesh> {
    private var _library: [MeshTypes: Mesh] = [:]
    
    override func fillLibrary() {
        _library.updateValue(NoMesh(), forKey: .None)
        _library.updateValue(Triangle_CustomMesh(), forKey: .Triangle_Custom)
        _library.updateValue(Quad_CustomMesh(), forKey: .Quad_Custom)
        _library.updateValue(Mesh(modelName: "quad"), forKey: .Quad)
        _library.updateValue(Cube_CustomMesh(), forKey: .Cube_Custom)
        _library.updateValue(Mesh(modelName: "cruiser"), forKey: .Cruiser)
        _library.updateValue(Mesh(modelName: "sphere"), forKey: .Sphere)
        _library.updateValue(Mesh(modelName: "chest"), forKey: .Chest)
        _library.updateValue(Mesh(modelName: "TheSuzannes"), forKey: .TheSuzannes)
        _library.updateValue(Mesh(modelName: "well"), forKey: .Well)
        
        // Terrain pack stuff
        _library.updateValue(Mesh(modelName: "ground_grass"), forKey: .GroundGrass)
        _library.updateValue(Mesh(modelName: "tree_pineTallA_detailed"), forKey: .TreePineA)
        _library.updateValue(Mesh(modelName: "tree_pineDefaultB"), forKey: .TreePineB)
        _library.updateValue(Mesh(modelName: "tree_pineRoundC"), forKey: .TreePineC)
        _library.updateValue(Mesh(modelName: "flower_redA"), forKey: .FlowerRed)
        _library.updateValue(Mesh(modelName: "flower_yellowA"), forKey: .FlowerYellow)
        _library.updateValue(Mesh(modelName: "flower_purpleA"), forKey: .FlowerPurple)
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
        (descriptor.attributes[4] as! MDLVertexAttribute).name = MDLVertexAttributeTangent
        (descriptor.attributes[5] as! MDLVertexAttribute).name = MDLVertexAttributeBitangent
        
        let bufferAllocator = MTKMeshBufferAllocator(device: Engine.device)
        let asset: MDLAsset = MDLAsset(url: assetURL,
                                       vertexDescriptor: descriptor,
                                       bufferAllocator: bufferAllocator,
                                       preserveTopology: true,
                                       error: nil)
        
        asset.loadTextures()
        
        var mdlMeshes: [MDLMesh] = []
        do {
            mdlMeshes = try MTKMesh.newMeshes(asset: asset, device: Engine.device).modelIOMeshes
        } catch {
            print("ERROR::LOADING_MESH::__\(modelName)__::\(error)")
        }
        
        var mtkMeshes: [MTKMesh] = []
        for mdlMesh in mdlMeshes {
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                    tangentAttributeNamed: MDLVertexAttributeTangent,
                                    bitangentAttributeNamed: MDLVertexAttributeTangent)
            
            mdlMesh.vertexDescriptor = descriptor
            
            do {
                let mtkMesh = try MTKMesh(mesh: mdlMesh, device: Engine.device)
                mtkMeshes.append(mtkMesh)
            } catch {
                print("ERROR::LOADING_MDLMESH::__\(modelName)__::\(error)")
            }
        }
        
        let mtkMesh = mtkMeshes[0]
        let mdlMesh = mdlMeshes[0]
        self._vertexBuffer = mtkMesh.vertexBuffers[0].buffer
        self._vertexCount = mtkMesh.vertexCount
        for i in 0..<mtkMesh.submeshes.count {
            let mtkSubmesh = mtkMesh.submeshes[i]
            let mdlSubmesh = mdlMesh.submeshes![i] as! MDLSubmesh
            let submesh = Submesh(mtkSubmesh: mtkSubmesh, mdlSubmesh: mdlSubmesh)
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
                   normal: SIMD3<Float> = SIMD3<Float>(0, 1, 0),
                   tangent: SIMD3<Float> = SIMD3<Float>(1, 0, 0),
                   bitangent: SIMD3<Float> = SIMD3<Float>(0, 0, 1)) {
        _vertices.append(Vertex(position: position,
                                colour: colour,
                                textureCoordinate: textureCoordinate,
                                normal: normal,
                                tangent: tangent,
                                bitangent: bitangent))
    }
    
    func drawPrimitives(renderCommandEncoder: MTLRenderCommandEncoder,
                        material: Material? = nil,
                        baseColourTextureType: TextureTypes = .None,
                        baseNormalMapTextureType: TextureTypes = .None) {
        if _vertexBuffer != nil {
            renderCommandEncoder.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)
            
            if _submeshes.count > 0 {
                for submesh in _submeshes {
                    submesh.applyTextures(renderCommandEncoder: renderCommandEncoder, customBaseColourTextureType: baseColourTextureType, customBaseNormalMapTextureType: baseNormalMapTextureType)
                    submesh.applyMaterials(renderCommandEncoder: renderCommandEncoder, customMaterial: material)
                    
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
    
    private var _baseColourTexture: MTLTexture!
    private var _baseNormalMapTexture: MTLTexture!
    
    private var _material = Material()
    
    init(indices: [UInt32]) {
        self._indices = indices
        self._indexCount = indices.count
        createIndexBuffer()
    }
    
    init(mtkSubmesh: MTKSubmesh, mdlSubmesh: MDLSubmesh) {
        _indexBuffer = mtkSubmesh.indexBuffer.buffer
        _indexCount = mtkSubmesh.indexCount
        _indexType = mtkSubmesh.indexType
        _primitiveType = mtkSubmesh.primitiveType
        
        createTexture(mdlMaterial: mdlSubmesh.material!)
        createMaterial(mdlMaterial: mdlSubmesh.material!)
    }
    
    func createTexture(mdlMaterial: MDLMaterial) {
        _baseColourTexture = texture(for: .baseColor, in: mdlMaterial, textureOrigin: .bottomLeft)
        _baseNormalMapTexture = texture(for: .tangentSpaceNormal, in: mdlMaterial, textureOrigin: .bottomLeft)
    }
    
    func createMaterial(mdlMaterial: MDLMaterial) {
        if let ambient = mdlMaterial.property(with: .emission)?.float3Value { _material.ambient = ambient }
        if let diffuse = mdlMaterial.property(with: .baseColor)?.float3Value { _material.diffuse = diffuse }
        if let specular = mdlMaterial.property(with: .specular)?.float3Value { _material.specular = specular }
        if let shininess = mdlMaterial.property(with: .specularExponent)?.floatValue { _material.shininess = shininess }
    }
    
    private func texture(for semantic: MDLMaterialSemantic,
                         in material: MDLMaterial?,
                         textureOrigin: MTKTextureLoader.Origin) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: Engine.device)
        guard let materialProperty = material?.property(with: semantic) else { return nil }
        guard let sourceTexture = materialProperty.textureSamplerValue?.texture else { return nil }

        let options: [MTKTextureLoader.Option : Any] = [
            MTKTextureLoader.Option.origin : textureOrigin as Any,
            MTKTextureLoader.Option.generateMipmaps : true
        ]
        
        let tex = try? textureLoader.newTexture(texture: sourceTexture, options: options)
        return tex
    }
    
    func applyTextures(renderCommandEncoder: MTLRenderCommandEncoder, customBaseColourTextureType: TextureTypes, customBaseNormalMapTextureType: TextureTypes) {
        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Linear], index: 0)
        
        let baseColourTex = customBaseColourTextureType == .None ? _baseColourTexture : Entities.textures[customBaseColourTextureType]
        renderCommandEncoder.setFragmentTexture(baseColourTex, index: 0)
        
        let baseNormalMapTex = customBaseNormalMapTextureType == .None ? _baseNormalMapTexture : Entities.textures[customBaseNormalMapTextureType]
        renderCommandEncoder.setFragmentTexture(baseNormalMapTex, index: 1)
    }
    
    func applyMaterials(renderCommandEncoder: MTLRenderCommandEncoder, customMaterial: Material?) {
        var mat = customMaterial == nil ? _material : customMaterial
        renderCommandEncoder.setFragmentBytes(&mat, length: Material.stride, index: 1)
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
