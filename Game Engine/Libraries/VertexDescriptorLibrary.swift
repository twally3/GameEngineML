import MetalKit

enum VertexDescriptorTypes {
    case Basic
}

class VertexDescriptorLibrary {
    
    private static var vertexDescriptors: [VertexDescriptorTypes: VertexDescriptor] = [:]
    
    public static func initialize() {
        createDefaultVertexDescriptors()
    }
    
    private static func createDefaultVertexDescriptors() {
        vertexDescriptors.updateValue(Basic_VertexDescriptor(), forKey: .Basic)
    }
    
    public static func descriptor(_ vertexDescriptorType: VertexDescriptorTypes) -> MTLVertexDescriptor {
        return vertexDescriptors[vertexDescriptorType]!.vertexDescriptor
    }
    
}

protocol VertexDescriptor {
    var name: String { get }
    var vertexDescriptor: MTLVertexDescriptor { get }
}

public struct Basic_VertexDescriptor: VertexDescriptor {
    var name: String = "Basic Vertex Descriptor"
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vd = MTLVertexDescriptor()
        
        // Position
        vd.attributes[0].format = .float3
        vd.attributes[0].bufferIndex = 0
        vd.attributes[0].offset = 0
        
        // Colour
        vd.attributes[1].format = .float4
        vd.attributes[1].bufferIndex = 0
        vd.attributes[1].offset = SIMD3<Float>.size
        
        vd.layouts[0].stride = Vertex.stride
        
        
        return vd
    }
}
