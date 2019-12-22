import MetalKit

enum RenderPipelineStateTypes {
    case Basic
    case Instanced
}

class RenderPipelineStateLibrary: Library<RenderPipelineStateTypes, MTLRenderPipelineState> {
    private var _library: [RenderPipelineStateTypes: RenderPipelineState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Basic_RenderPipelineState(), forKey: .Basic)
        _library.updateValue(Instanced_RenderPipelineState() , forKey: .Instanced)
    }
    
    override subscript(_ type: RenderPipelineStateTypes) -> MTLRenderPipelineState {
        return _library[type]!.renderPipelineState
    }
}

class RenderPipelineState {
    var renderPipelineState: MTLRenderPipelineState!
    
    init(renderPipelineDescriptor: MTLRenderPipelineDescriptor) {
        do {
            renderPipelineState = try Engine.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__::\(error)")
        }
    }
}

class Basic_RenderPipelineState: RenderPipelineState {
    init() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = "Basic Render Pipeline Descriptor"

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.Basic]
        
        renderPipelineDescriptor.vertexFunction = Graphics.shaders[.Basic_Vertex]
        renderPipelineDescriptor.fragmentFunction = Graphics.shaders[.Basic_Fragment]
        
        super.init(renderPipelineDescriptor: renderPipelineDescriptor)
    }
}

class Instanced_RenderPipelineState: RenderPipelineState {
    init() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = "Instanced Render Pipeline Descriptor"

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.Basic]
        
        renderPipelineDescriptor.vertexFunction = Graphics.shaders[.Instanced_Vertex]
        renderPipelineDescriptor.fragmentFunction = Graphics.shaders[.Basic_Fragment]
        
        super.init(renderPipelineDescriptor: renderPipelineDescriptor)
    }
}
