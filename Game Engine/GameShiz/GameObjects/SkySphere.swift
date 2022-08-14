import MetalKit

class SkySphere : GameObject {
    override var renderPipelineStateType: RenderPipelineStateTypes { return .SkySphere }
    private var skySphereTextureType: TextureTypes!
    
    init(skySphereTextureType: TextureTypes) {
        super.init(name: "SkySphere", meshType: .SkySphere)
        
        self.skySphereTextureType = skySphereTextureType
        
        setScale(SIMD3<Float>(repeating: 1000))
        
        useBaseColourTexture(skySphereTextureType)
    }
    
    override func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setFragmentTexture(Assets.textures[skySphereTextureType], index: 10)
        
        super.render(renderCommandEncoder: renderCommandEncoder)
    }
}
