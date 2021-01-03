import MetalKit

enum ShaderTypes {
    // Vertex
    case Basic_Vertex
    case Instanced_Vertex
    case SkySphere_Vertex

    // Fragment
    case Basic_Fragment
    case SkySphere_Fragment
}

class ShaderLibrary: Library<ShaderTypes, MTLFunction> {
    private var _library: [ShaderTypes: Shader] = [:]
    
    override func fillLibrary() {
        _library.updateValue(
            Shader(name: "Basic Vertex Shader", functionName: "basic_vertex_shader"),
            forKey: .Basic_Vertex
        )
        
        _library.updateValue(
            Shader(name: "Instanced Vertex Shader", functionName: "instanced_vertex_shader"),
            forKey: .Instanced_Vertex
        )
        
        _library.updateValue(
            Shader(name: "Basic Fragment Shader", functionName: "basic_fragment_shader"),
            forKey: .Basic_Fragment
        )
        
        _library.updateValue(
            Shader(name: "SkySphere Vertex Shader", functionName: "skysphere_vertex_shader"),
            forKey: .SkySphere_Vertex
        )
        
        _library.updateValue(
            Shader(name: "SkySphere Fragment Shader", functionName: "skysphere_fragment_shader"),
            forKey: .SkySphere_Fragment
        )
    }
    
    override subscript(_ type: ShaderTypes)->MTLFunction {
        return (_library[type]?.function)!
    }
}


class Shader {
    var function: MTLFunction!
    
    init(name: String, functionName: String) {
        self.function = Engine.defaultLibrary.makeFunction(name: functionName)
        self.function.label = name
    }
}
