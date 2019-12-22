class Graphics {
    private static var _shaderLibrary: ShaderLibrary!
    public static var shaders: ShaderLibrary { return _shaderLibrary }
    
    private static var _vertexDescriptorLibrary: VertexDescriptorLibrary!
    public static var vertexDescriptors: VertexDescriptorLibrary { return _vertexDescriptorLibrary}
    
    private static var _renderPipelineStateLibrary: RenderPipelineStateLibrary!
    public static var renderPipelineStates: RenderPipelineStateLibrary { return _renderPipelineStateLibrary}
    
    private static var _depthStencilStateLibrary: DepthStencilStateLibrary!
    public static var depthStencilStates: DepthStencilStateLibrary { return _depthStencilStateLibrary}
    
    private static var _samplerStateLibrary: SamplerStateLibrary!
    public static var samplerStates: SamplerStateLibrary { return _samplerStateLibrary}
    
    public static func initialize() {
        self._shaderLibrary = ShaderLibrary()
        self._vertexDescriptorLibrary = VertexDescriptorLibrary()
        self._renderPipelineStateLibrary = RenderPipelineStateLibrary()
        self._depthStencilStateLibrary = DepthStencilStateLibrary()
        self._samplerStateLibrary = SamplerStateLibrary()
    }
}
