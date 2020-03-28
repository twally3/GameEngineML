import UIKit
import MetalKit

class GameView: MTKView {
    
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        print("Hello")
        try! print(FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath))
        
        self.device = MTLCreateSystemDefaultDevice()
//        self.device = MTLCopyAllDevices()[1]
        
        Engine.ignite(device: device!)
        
        self.clearColor = Preferences.clearColour
        self.colorPixelFormat = Preferences.mainPixelFormat
        self.depthStencilPixelFormat = Preferences.mainDepthPixelFormat
        
        self.renderer = Renderer(self)
        self.delegate = renderer
    }
}
