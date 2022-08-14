import MetalKit

class Renderer: NSObject {
    public static var screenSize = SIMD2<Float>(repeating: 0)
    public static var aspectRatio: Float {
        return screenSize.x / screenSize.y
    }
    
    init(_ mtkView: MTKView) {
        super.init()
        updateScreenSize(view: mtkView)
        SceneManager.setScene(sceneType: Preferences.startingSceneType)
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
        guard let drawable = view.currentDrawable, let sceneRenderPassDescriptor = view.currentRenderPassDescriptor else { return }
        SceneManager.update(deltaTime: 1.0 / Float(view.preferredFramesPerSecond))
        
        let commandBuffer = Engine.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Base Command Buffer"
        
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: sceneRenderPassDescriptor)
        renderCommandEncoder?.label = "Scene Render Command Encoder"
        
        renderCommandEncoder?.pushDebugGroup("Starting Scene Render")
        SceneManager.render(renderCommandEncoder: renderCommandEncoder!)
        renderCommandEncoder?.popDebugGroup()
        
        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
