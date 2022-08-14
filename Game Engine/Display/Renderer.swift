import MetalKit

class Renderer: NSObject {
    public static var screenSize = SIMD2<Float>(repeating: 0)
    public static var aspectRatio: Float {
        return screenSize.x / screenSize.y
    }
    
    private var baseRenderPassDescriptor: MTLRenderPassDescriptor!
    
    init(_ mtkView: MTKView) {
        super.init()
        updateScreenSize(view: mtkView)
        SceneManager.setScene(sceneType: Preferences.startingSceneType)
        createBaseRenderPassDescriptor()
    }
    
    private func createBaseRenderPassDescriptor() {
        // BASE COLOUR 0 TEXTURE
        let base0TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.mainPixelFormat,
                                                                             width: Int(Renderer.screenSize.x),
                                                                             height: Int(Renderer.screenSize.y),
                                                                             mipmapped: false)
        
        base0TextureDescriptor.usage = [.renderTarget]
        
        Assets.textures.setTexture(textureType: .BaseColorRender_0,
                                   texture: Engine.device.makeTexture(descriptor: base0TextureDescriptor)!)
        
        // BASE COLOUR 1 TEXTURE
        let base1TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.mainPixelFormat,
                                                                             width: Int(Renderer.screenSize.x),
                                                                             height: Int(Renderer.screenSize.y),
                                                                             mipmapped: false)
        
        base1TextureDescriptor.usage = [.renderTarget]
        
        Assets.textures.setTexture(textureType: .BaseColorRender_1,
                                   texture: Engine.device.makeTexture(descriptor: base1TextureDescriptor)!)
        
        
        // BASE DEPTH TEXTURE
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.mainDepthPixelFormat,
                                                                              width: Int(Renderer.screenSize.x),
                                                                              height: Int(Renderer.screenSize.y),
                                                                              mipmapped: false)
        
        depthTextureDescriptor.usage = [.renderTarget]
        depthTextureDescriptor.storageMode = .private
        
        Assets.textures.setTexture(textureType: .BaseDepthRender,
                                   texture: Engine.device.makeTexture(descriptor: depthTextureDescriptor)!)
        
        self.baseRenderPassDescriptor = MTLRenderPassDescriptor()
        self.baseRenderPassDescriptor.colorAttachments[0].texture = Assets.textures[.BaseColorRender_0]
        self.baseRenderPassDescriptor.colorAttachments[0].storeAction = .store
        self.baseRenderPassDescriptor.colorAttachments[0].loadAction = .clear
        
        self.baseRenderPassDescriptor.colorAttachments[1].texture = Assets.textures[.BaseColorRender_1]
        self.baseRenderPassDescriptor.colorAttachments[1].storeAction = .store
        self.baseRenderPassDescriptor.colorAttachments[1].loadAction = .clear
        
        self.baseRenderPassDescriptor.depthAttachment.texture = Assets.textures[.BaseDepthRender]
    }
}

extension Renderer: MTKViewDelegate {
    
    public func updateScreenSize(view: MTKView) {
        Renderer.screenSize = SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height))
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        SceneManager.update(deltaTime: 1.0 / Float(view.preferredFramesPerSecond))
        
        let commandBuffer = Engine.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Base Command Buffer"
        
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: baseRenderPassDescriptor)
        renderCommandEncoder?.label = "Scene Render Command Encoder"
        renderCommandEncoder?.pushDebugGroup("Starting Scene Render")
        SceneManager.render(renderCommandEncoder: renderCommandEncoder!)
        renderCommandEncoder?.popDebugGroup()
        renderCommandEncoder?.endEncoding()
        
        let blitEncoder = commandBuffer?.makeBlitCommandEncoder()
        blitEncoder?.label = "View display copy encoder"
        blitEncoder?.copy(from: Assets.textures[.BaseColorRender_0]!,
                          to: view.currentDrawable!.texture)
        blitEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
