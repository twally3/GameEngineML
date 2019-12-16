import MetalKit

enum RenderPipelineDescriptorTypes {
    case Basic
    case Instanced
}

class RenderPipelineDescriptorLibrary: Library<RenderPipelineDescriptorTypes, MTLRenderPipelineDescriptor> {
    private var _library: [RenderPipelineDescriptorTypes: RenderPipelineDescriptor] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Basic_RenderPipelineDescriptor(), forKey: .Basic)
        _library.updateValue(Instanced_RenderPipelineDescriptor(), forKey: .Instanced)
    }
    
    override subscript(_ type: RenderPipelineDescriptorTypes) -> MTLRenderPipelineDescriptor {
        return _library[type]!.renderPipelineDescriptor
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
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
        renderPipelineDescriptor.vertexFunction = Graphics.vertexShaders[.Basic]
        renderPipelineDescriptor.fragmentFunction = Graphics.fragmentShaders[.Basic]
        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.Basic]
    }
}

public struct Instanced_RenderPipelineDescriptor: RenderPipelineDescriptor {
    var name: String = "Instanced Render Pipeline Descriptor"
    
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    
    init() {
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
        renderPipelineDescriptor.vertexFunction = Graphics.vertexShaders[.Instanced]
        renderPipelineDescriptor.fragmentFunction = Graphics.fragmentShaders[.Basic]
        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.Basic]
    }
}
