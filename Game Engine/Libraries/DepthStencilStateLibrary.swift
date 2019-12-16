import MetalKit

enum DepthStencilStateTypes {
    case Less
}

class DepthStencilStateLibrary {
    
    private static var _depthStencilStates: [DepthStencilStateTypes: DepthStencilState] = [:]
    
    public static func initialize() {
        createDefaultDepthStencilStates()
    }
    
    private static func createDefaultDepthStencilStates() {
        _depthStencilStates.updateValue(Less_DepthStencilState(), forKey: .Less)
    }
    
    public static func depthStencilState(_ depthStencilStateType: DepthStencilStateTypes) -> MTLDepthStencilState {
        return _depthStencilStates[depthStencilStateType]!.depthStencilState
    }
    
}

protocol DepthStencilState {
    var depthStencilState: MTLDepthStencilState! { get }
}

class Less_DepthStencilState: DepthStencilState {
    var depthStencilState: MTLDepthStencilState!
    
    init() {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilState = Engine.device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
}
