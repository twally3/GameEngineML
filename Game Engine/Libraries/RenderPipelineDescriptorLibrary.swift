import MetalKit

enum RenderPipelineDescriptorTypes {
    case Basic
}

class RenderPipelineDescriptorLibrary {
    
    private static var renderPipelineDescriptor: [RenderPipelineDescriptorTypes: RenderPipelineDescriptor] = [:]
    
    public static func initialize() {
        createDefaultRenderPipelineDescriptor()
    }
    
    private static func createDefaultRenderPipelineDescriptor() {
        renderPipelineDescriptor.updateValue(Basic_RenderPipelineDescriptor(), forKey: .Basic)
    }
    
    public static func descriptor(_ renderPipelineDescriptorType: RenderPipelineDescriptorTypes) -> MTLRenderPipelineDescriptor {
        return renderPipelineDescriptor[renderPipelineDescriptorType]!.renderPipelineDescriptor
    }
}

protocol RenderPipelineDescriptor {
    var name: String { get }
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor! { get }
}

public struct Basic_RenderPipelineDescriptor: RenderPipelineDescriptor {
    var name: String = "Basic Render Pipeline Descriptor"
    
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    
    init() {
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.vertexFunction = ShaderLibrary.vertex(.Basic)
        renderPipelineDescriptor.fragmentFunction = ShaderLibrary.fragment(.Basic)
        renderPipelineDescriptor.vertexDescriptor = VertexDescriptorLibrary.descriptor(.Basic)
    }
}
