import MetalKit

enum RenderPipelineStateTypes {
    case Basic
    case Instanced
}

class RenderPipelineStateLibrary {
    
    private static var renderPipelineStates: [RenderPipelineStateTypes: RenderPipelineState] = [:]
    
    public static func initialize() {
        createDefaultRenderPipelineState()
    }
    
    private static func createDefaultRenderPipelineState() {
        renderPipelineStates.updateValue(Basic_RenderPipelineState(), forKey: .Basic)
        renderPipelineStates.updateValue(Instanced_RenderPipelineState(), forKey: .Instanced)
    }
    
    public static func state(_ renderPipelineStateType: RenderPipelineStateTypes) -> MTLRenderPipelineState {
        return (renderPipelineStates[renderPipelineStateType]?.renderPipelineState)!
    }
}

protocol RenderPipelineState {
    var name: String { get }
    var renderPipelineState: MTLRenderPipelineState! { get }
}

public struct Basic_RenderPipelineState: RenderPipelineState {
    var name: String = "Basic Render Pipeline State"
    
    var renderPipelineState: MTLRenderPipelineState!
    
    init() {
        do {
            renderPipelineState = try Engine.device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.descriptor(.Basic))
        } catch let error as NSError {
            print(error)
        }
    }
}

public struct Instanced_RenderPipelineState: RenderPipelineState {
    var name: String = "Instanced Render Pipeline State"
    
    var renderPipelineState: MTLRenderPipelineState!
    
    init() {
        do {
            renderPipelineState = try Engine.device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.descriptor(.Instanced))
        } catch let error as NSError {
            print(error)
        }
    }
}

