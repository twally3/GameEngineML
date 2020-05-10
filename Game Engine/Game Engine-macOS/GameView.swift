import MetalKit
import GameController
import CoreGraphics

class GameView: MTKView {
    
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.device = MTLCreateSystemDefaultDevice()
//        self.device = MTLCopyAllDevices()[1]
        
        Engine.ignite(device: device!)
        
        self.clearColor = Preferences.clearColour
        self.colorPixelFormat = Preferences.mainPixelFormat
        self.depthStencilPixelFormat = Preferences.mainDepthPixelFormat
        
        self.renderer = Renderer(self)
        self.delegate = renderer
        
        Controller.ignite()
    }
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func keyDown(with event: NSEvent) {
        Keyboard.setKeyPressed(event.keyCode, isOn: true)
    }
    
    override func keyUp(with event: NSEvent) {
        Keyboard.setKeyPressed(event.keyCode, isOn: false)
    }
    
    override func mouseDown(with event: NSEvent) {
        Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: true)
        
        let view = self
        
        var location = view.convert(event.locationInWindow, from: nil)
        location.y = view.bounds.height - location.y // Flip from AppKit default window coordinates to Metal viewport coordinates
        handleInteraction(at: location)
    }
    
    override func mouseUp(with event: NSEvent) {
        Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }
    
    override func rightMouseUp(with event: NSEvent) {
        Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
    override func otherMouseDown(with event: NSEvent) {
        Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }
    
    override func otherMouseUp(with event: NSEvent) {
        Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
    override func mouseMoved(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        Mouse.scrollMouse(deltaY: Float(event.deltaY))
    }
    
    override func mouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    override func rightMouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    override func otherMouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    private func setMousePositionChanged(event: NSEvent) {
        let overallLocation = SIMD2<Float>(Float(event.locationInWindow.x), Float(event.locationInWindow.y))
        let deltaChange = SIMD2<Float>(Float(event.deltaX), Float(event.deltaY))
        
        Mouse.setMousePositionChange(overallPosition: overallLocation, deltaPosition: deltaChange)
    }
    
    override func updateTrackingAreas() {
        let area = NSTrackingArea(
            rect: self.bounds,
            options: [
                NSTrackingArea.Options.activeAlways,
                NSTrackingArea.Options.mouseMoved,
                NSTrackingArea.Options.enabledDuringMouseDrag
            ],
            owner: self,
            userInfo: nil
        )
        
        self.addTrackingArea(area)
    }
    
    func handleInteraction(at point: CGPoint) {
        let currentScene = SceneManager.getCurrentScene()
        guard let currentCamera = currentScene.getCameraManager().currentCamera else { return }
        
        let viewport = self.bounds
        let width = Float(viewport.size.width)
        let height = Float(viewport.size.height)
                
        let projectionMatrix = currentCamera.projectionMatrix
        let inverseProjectionMatrix = projectionMatrix.inverse
        
        let viewMatrix = currentCamera.viewMatrix
        let inverseViewMatrix = viewMatrix.inverse
        
        let clipX = (2 * Float(point.x)) / width - 1
        let clipY = 1 - (2 * Float(point.y)) / height
        let clipCoords = SIMD4<Float>(clipX, clipY, 0, 1)
        
        var eyeRayDir = inverseProjectionMatrix * clipCoords
        eyeRayDir.z = -1
        eyeRayDir.w = 0

        let _worldRayDir = inverseViewMatrix * eyeRayDir
        var worldRayDir = SIMD3<Float>(_worldRayDir.x, _worldRayDir.y, _worldRayDir.z)
        worldRayDir = normalize(worldRayDir)

        let eyeRayOrigin = SIMD4<Float>(x: 0, y: 0, z: 0, w: 1)
        let _worldRayOrigin = inverseViewMatrix * eyeRayOrigin
        let worldRayOrigin = SIMD3<Float>(_worldRayOrigin.x, _worldRayOrigin.y, _worldRayOrigin.z)
        
        let ray = Ray(origin: worldRayOrigin, direction: worldRayDir)
        
        if let hit = currentScene.hitTest(ray) {
            let obj = hit.node as! GameObject
            if let mat = obj.getMaterial() {
                let colour = mat.colour.z == 1 ? SIMD4<Float>(0, 1, 0, 0) : SIMD4<Float>(0, 0, 1, 0)
                let newMat = Material(colour: colour,
                                      isLit: mat.isLit,
                                      ambient: mat.ambient,
                                      diffuse: mat.diffuse,
                                      specular: mat.specular,
                                      shininess: mat.shininess)
                
                obj.useMaterial(newMat)
            }
            
            print("Hit \(hit.node)")
        }
    }
}
