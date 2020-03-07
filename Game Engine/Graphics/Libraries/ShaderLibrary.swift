import MetalKit

enum ShaderTypes {
    // Vertex
    case Basic_Vertex
    case Instanced_Vertex

    // Fragment
    case Basic_Fragment
    
    // Compute
    case CreateHeightMap_Compute
    
    case Water_Vertex
    case Water_Fragment
    
    case SkyBox_Vertex
    case SkyBox_Fragment
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
            Shader(name: "Create Height Map Compute Shader", functionName: "create_height_map"),
            forKey: .CreateHeightMap_Compute
        )
        
        _library.updateValue(
            Shader(name: "Water Vertex Shader", functionName: "water_vertex_shader"),
            forKey: .Water_Vertex
        )
        _library.updateValue(
            Shader(name: "Water Fragment Shader", functionName: "water_fragment_shader"),
            forKey: .Water_Fragment
        )
        
        _library.updateValue(
            Shader(name: "SkyBox Vertex Shader", functionName: "skybox_vertex_shader"),
            forKey: .SkyBox_Vertex
        )
        _library.updateValue(
            Shader(name: "SkyBox Fragment Shader", functionName: "skybox_fragment_shader"),
            forKey: .SkyBox_Fragment
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
