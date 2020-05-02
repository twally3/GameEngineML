import MetalKit

class Renderer: NSObject {
    public static var screenSize = SIMD2<Float>(repeating: 0)
    public static var aspectRatio: Float {
        return screenSize.x / screenSize.y
    }
    
    var reflectionRenderTexture: MTLTexture!
    var reflectionDepthTexture: MTLTexture!
    var refractionRenderTexture: MTLTexture!
    var refractionDepthTexture: MTLTexture!
    var reflectionRenderPassDescriptor: MTLRenderPassDescriptor!
    var refractionRenderPassDescriptor: MTLRenderPassDescriptor!
    
    init(_ mtkView: MTKView) {
        super.init()
        updateScreenSize(view: mtkView)
        
        (self.reflectionRenderTexture, self.reflectionDepthTexture) = secondRenderStuff()
        (self.refractionRenderTexture, self.refractionDepthTexture) = secondRenderStuff()
        
        Entities.textures[.WaterReflectionTexture] = reflectionRenderTexture
        Entities.textures[.WaterRefractionTexture] = refractionRenderTexture
        Entities.textures[.WaterRefractionDepthTexture] = refractionDepthTexture

        self.reflectionRenderPassDescriptor = self.renderPassDescriptor(renderTexture: reflectionRenderTexture, depthTexture: reflectionDepthTexture)
        self.refractionRenderPassDescriptor = self.renderPassDescriptor(renderTexture: refractionRenderTexture, depthTexture: refractionDepthTexture)
    }
}

extension Renderer: MTKViewDelegate {
    
    public func updateScreenSize(view: MTKView) {
        Renderer.screenSize = SIMD2<Float>(Float(view.bounds.width), Float(view.bounds.height))
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }

        SceneManager.updateScene(deltaTime: 1 / Float(view.preferredFramesPerSecond))
    
        let commandBuffer = Engine.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "My Command Buffer"
        
//        // --- REFLECTION ---
//        let reflectionRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: reflectionRenderPassDescriptor)
//        reflectionRenderCommandEncoder?.setFrontFacing(.counterClockwise)
//        reflectionRenderCommandEncoder?.setCullMode(.back)
//        reflectionRenderCommandEncoder?.label = "Reflection render command encoder"
//
//        let currentScene = SceneManager.getCurrentScene()
//        let currentCamera = currentScene.getCameraManager().currentCamera
//        
//        let distanceToWater = 2 * (currentCamera!.getPositionY() - (0.4 * 110))
//        
//        currentCamera?.moveY(-distanceToWater)
//        currentCamera?.setRotationX(-currentCamera!.getRotationX())
//        currentScene.clippingPlane = SIMD4(x: 0, y: 1, z: 0, w: (-0.4 * 110) + 1.0)
//        currentScene.updateSceneConstants()
//
//        reflectionRenderCommandEncoder?.pushDebugGroup("Starting Reflection Render")
//        SceneManager.renderScene(renderCommandEncoder: reflectionRenderCommandEncoder!)
//        reflectionRenderCommandEncoder?.popDebugGroup()
//
//        currentCamera?.moveY(distanceToWater)
//        currentCamera?.setRotationX(-currentCamera!.getRotationX())
//        currentScene.clippingPlane = SIMD4(repeating: 0)
//        currentScene.updateSceneConstants()
//
//        reflectionRenderCommandEncoder?.endEncoding()
//        // --- END REFLECTION ---
//        
//        // --- REFRACTION ---
//        let refractionRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: refractionRenderPassDescriptor)
//        refractionRenderCommandEncoder?.setFrontFacing(.counterClockwise)
//        refractionRenderCommandEncoder?.setCullMode(.back)
//        refractionRenderCommandEncoder?.label = "Refraction Render Command Encoder"
//
//        currentScene.clippingPlane = SIMD4(x: 0, y: -1, z: 0, w: 0.4 * 110)
//        currentScene.updateSceneConstants()
//        
//        refractionRenderCommandEncoder?.pushDebugGroup("Starting Refraction Render")
//        SceneManager.renderScene(renderCommandEncoder: refractionRenderCommandEncoder!)
//        refractionRenderCommandEncoder?.popDebugGroup()
//        
//        currentScene.clippingPlane = SIMD4<Float>(repeating: 0)
//        currentScene.updateSceneConstants()
//
//        refractionRenderCommandEncoder?.endEncoding()
//        // --- END REFRACTION ---

        // --- MAIN RENDER ---
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderCommandEncoder?.setFrontFacing(.counterClockwise)
        renderCommandEncoder?.setCullMode(.back)
        renderCommandEncoder?.label = "My Render Command Encoder"
        
        renderCommandEncoder?.pushDebugGroup("Starting Render")
        SceneManager.renderScene(renderCommandEncoder: renderCommandEncoder!)
        SceneManager.renderWater(renderCommandEncoder: renderCommandEncoder!)
        renderCommandEncoder?.popDebugGroup()

        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        // --- END MAIN RENDER ---
    }
    
    func secondRenderStuff() -> (MTLTexture, MTLTexture) {
        let renderTextureDescriptor = MTLTextureDescriptor()
        renderTextureDescriptor.width = 1024
        renderTextureDescriptor.height = 1024
        renderTextureDescriptor.pixelFormat = Preferences.mainPixelFormat
        renderTextureDescriptor.storageMode = .private
        renderTextureDescriptor.usage = [.renderTarget, .shaderRead]

        let depthTextureDescriptor = MTLTextureDescriptor()
        depthTextureDescriptor.width = 1024
        depthTextureDescriptor.height = 1024
        depthTextureDescriptor.pixelFormat = Preferences.mainDepthPixelFormat
        depthTextureDescriptor.storageMode = .private
        depthTextureDescriptor.usage = [.renderTarget, .shaderRead]

        let renderTexture = Engine.device.makeTexture(descriptor: renderTextureDescriptor)
        let depthTexture = Engine.device.makeTexture(descriptor: depthTextureDescriptor)

        return (renderTexture!, depthTexture!)
    }
    
    func renderPassDescriptor(renderTexture: MTLTexture, depthTexture: MTLTexture) -> MTLRenderPassDescriptor {
        let renderPassDescriptor2 = MTLRenderPassDescriptor()
        renderPassDescriptor2.colorAttachments[0].texture = renderTexture
        renderPassDescriptor2.colorAttachments[0].loadAction = .clear
        renderPassDescriptor2.colorAttachments[0].clearColor = Preferences.clearColour
        renderPassDescriptor2.colorAttachments[0].storeAction = .store

        renderPassDescriptor2.depthAttachment.texture = depthTexture
        renderPassDescriptor2.depthAttachment.loadAction = .clear
        renderPassDescriptor2.depthAttachment.storeAction = .store
        
        return renderPassDescriptor2
    }
}
