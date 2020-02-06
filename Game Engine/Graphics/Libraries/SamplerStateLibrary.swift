import MetalKit

enum SamplerStateTypes {
    case None
    case Linear
}

class SamplerStateLibrary: Library<SamplerStateTypes, MTLSamplerState> {
    private var _library: [SamplerStateTypes: SamplerState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Linear_SamplerState(), forKey: .Linear)
    }
    
    override subscript(type: SamplerStateTypes) -> MTLSamplerState? {
        return _library[type]?.samplerState
    }
}

protocol SamplerState {
    var name: String { get }
    var samplerState: MTLSamplerState! { get }
}

class Linear_SamplerState: SamplerState {
    var name: String = "Linear Sampler State"
    var samplerState: MTLSamplerState!
    
    init() {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.label = name
        samplerState = Engine.device.makeSamplerState(descriptor: samplerDescriptor)
    }
}
