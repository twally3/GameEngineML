import MetalKit

enum MeshTypes {
    case Triangle_Custom
    case Quad_Custom
    case Cube_Custom
}

class MeshLibrary: Library<MeshTypes, Mesh> {
    
    private var _library: [MeshTypes: Mesh] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Triangle_CustomMesh(), forKey: .Triangle_Custom)
        _library.updateValue(Quad_CustomMesh(), forKey: .Quad_Custom)
        _library.updateValue(Cube_CustomMesh(), forKey: .Cube_Custom)
    }
    
    override subscript(_ type: MeshTypes) -> Mesh {
        return _library[type]!
    }
}

protocol Mesh {
    var vertexCount: Int! { get }
    func setInstanceCount(_ count: Int)
    func drawPrimitives(renderCommandEncoder: MTLRenderCommandEncoder)
}

class CustomMesh: Mesh {
    private var _vertices: [Vertex] = []
    private var _vertexBuffer: MTLBuffer!
    private var _instanceCount: Int = 1
    var vertexCount: Int! {
        return _vertices.count
    }
    
    init() {
        createVertices()
        createBuffers()
    }
    
    func createVertices() {}
    
    func createBuffers() {
        _vertexBuffer = Engine.device.makeBuffer(bytes: _vertices, length: Vertex.stride * _vertices.count, options: [])
    }
    
    func addVertex(position: SIMD3<Float>, colour: SIMD4<Float>, textureCoordinate: SIMD2<Float> = SIMD2<Float>(repeating: 0)) {
        _vertices.append(Vertex(position: position, colour: colour, textureCoordinate: textureCoordinate))
    }
    
    func setInstanceCount(_ count: Int) {
        _instanceCount = count
    }
    
    func drawPrimitives(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: _instanceCount)
    }
}

class Triangle_CustomMesh: CustomMesh {
    override func createVertices() {
        addVertex(position: SIMD3<Float>(0, 1, 0), colour: SIMD4<Float>(1, 0, 0, 1))
        addVertex(position: SIMD3<Float>(-1, -1, 0), colour: SIMD4<Float>(0, 1, 0, 1))
        addVertex(position: SIMD3<Float>(1, -1, 0), colour: SIMD4<Float>(0, 0, 1, 1))
    }
}

class Quad_CustomMesh: CustomMesh {
    override func createVertices() {
        addVertex(position: SIMD3<Float>(1, 1, 0), colour: SIMD4<Float>(1, 0, 0, 1), textureCoordinate: SIMD2<Float>(1, 0))
        addVertex(position: SIMD3<Float>(-1, 1, 0), colour: SIMD4<Float>(0, 1, 0, 1), textureCoordinate: SIMD2<Float>(0, 0))
        addVertex(position: SIMD3<Float>(-1, -1, 0), colour: SIMD4<Float>(0, 0, 1, 1), textureCoordinate: SIMD2<Float>(0, 1))
        
        addVertex(position: SIMD3<Float>(1, 1, 0), colour: SIMD4<Float>(1, 0, 0, 1), textureCoordinate: SIMD2<Float>(1, 0))
        addVertex(position: SIMD3<Float>(-1, -1, 0), colour: SIMD4<Float>(0, 0, 1, 1), textureCoordinate: SIMD2<Float>(0, 1))
        addVertex(position: SIMD3<Float>(1, -1, 0), colour: SIMD4<Float>(1, 0, 1, 1), textureCoordinate: SIMD2<Float>(1, 1))
    }
}

class Cube_CustomMesh: CustomMesh {
    override func createVertices() {
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
