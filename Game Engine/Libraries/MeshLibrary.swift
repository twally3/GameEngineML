import MetalKit

enum MeshTypes {
    case Triangle_Custom
    case Quad_Custom
}

class MeshLibrary {
    
    private static var meshes: [MeshTypes: Mesh] = [:]
    
    public static func initialize() {
        createDefaultMesh()
    }
    
    private static func createDefaultMesh() {
        meshes.updateValue(Triangle_CustomMesh(), forKey: .Triangle_Custom)
        meshes.updateValue(Quad_CustomMesh(), forKey: .Quad_Custom)
    }
    
    public static func mesh(_ meshType: MeshTypes) -> Mesh {
        return meshes[meshType]!
    }
}

protocol Mesh {
    var vertexBuffer: MTLBuffer! { get }
    var vertexCount: Int! { get }
}

class CustomMesh: Mesh {
    
    var vertices: [Vertex]!
    var vertexBuffer: MTLBuffer!
    var vertexCount: Int! {
        return vertices.count
    }
    
    init() {
        createVertices()
        createBuffers()
    }
    
    func createVertices() {}
    
    func createBuffers() {
        vertexBuffer = Engine.device.makeBuffer(bytes: vertices, length: Vertex.stride * vertices.count, options: [])
    }
    
}

class Triangle_CustomMesh: CustomMesh {
    override func createVertices() {
        vertices = [
            Vertex(position: SIMD3<Float>(0, 1, 0), colour: SIMD4<Float>(1, 0, 0, 1)),
            Vertex(position: SIMD3<Float>(-1, -1, 0), colour: SIMD4<Float>(0, 1, 0, 1)),
            Vertex(position: SIMD3<Float>(1, -1, 0), colour: SIMD4<Float>(0, 0, 1, 1)),
        ]
    }
}

class Quad_CustomMesh: CustomMesh {
    override func createVertices() {
        vertices = [
            Vertex(position: SIMD3<Float>(0.5, 0.5, 0), colour: SIMD4<Float>(1, 0, 0, 1)),
            Vertex(position: SIMD3<Float>(-0.5, 0.5, 0), colour: SIMD4<Float>(0, 1, 0, 1)),
            Vertex(position: SIMD3<Float>(-0.5, -0.5, 0), colour: SIMD4<Float>(0, 0, 1, 1)),
            
            Vertex(position: SIMD3<Float>(0.5, 0.5, 0), colour: SIMD4<Float>(1, 0, 0, 1)),
            Vertex(position: SIMD3<Float>(-0.5, -0.5, 0), colour: SIMD4<Float>(0, 0, 1, 1)),
            Vertex(position: SIMD3<Float>(0.5, -0.5, 0), colour: SIMD4<Float>(1, 0, 1, 1)),
        ]
    }
}
