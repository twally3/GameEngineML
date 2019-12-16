import MetalKit

class SandboxScene: Scene {
    
    let camera = DebugCamera()
    
    override func buildScene() {
        addCamera(camera)
        
        let count = 5
        for y in -count..<count {
            for x in -count..<count {
                let pointer = Pointer(camera: camera)
                pointer.position.y = Float(Float(y) + 0.5) / Float(count)
                pointer.position.x = Float(Float(x) + 0.5) / Float(count)
                pointer.scale = SIMD3<Float>(repeating: 0.1)
                addChild(pointer)
            }
        }
    }
}
