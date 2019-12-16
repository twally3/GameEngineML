import MetalKit

class SandboxScene: Scene {
    
    let camera = DebugCamera()
    
    override func buildScene() {
        addCamera(camera)
        
        camera.position.z = 13
        
        addCubes()
    }
    
    func addCubes() {
        for y in -5..<5 {
            let posY = Float(y) + 0.5
            for x in -8..<8 {
                let posX = Float(x) + 0.5
                let cube = Cube()
                cube.position.y = posY
                cube.position.x = posX
                cube.scale = SIMD3<Float>(repeating: 0.3)
                cube.setColour(ColourUtil.randomColour)
                addChild(cube)
            }
        }
    }
}
