import MetalKit

class SandboxScene: Scene {
    
    override func buildScene() {
        let count = 5
        
        for y in -count..<count {
            for x in -count..<count {
                let player = Player()
                player.position.y = Float(Float(y) + 0.5) / Float(count)
                player.position.x = Float(Float(x) + 0.5) / Float(count)
                player.scale = SIMD3<Float>(repeating: 0.1)
                addChild(player)
            }
        }
    }
}
