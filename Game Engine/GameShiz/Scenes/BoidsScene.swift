import simd

class BoidsScene: Scene {
    let camera = FPSCameraQuaternion()
    let sun = Sun()
        
    let cube2: Cube = {
        let x = Cube()
        x.setPosition(SIMD3<Float>(repeating: -40))
        x.setScale(SIMD3<Float>(repeating: 80))
        var mat = Material()
        mat.isLit = false
        mat.colour = SIMD4<Float>(0, 0, 1, 1)
        x.useMaterial(mat)
        return x
    }()
    
    let boidManager = BoidManager()

    override func buildScene() {
        camera.setPosition(-80, 100, 80)
        camera.rotateX(Float.pi / 4)
        camera.rotateY(Float.pi / 4)
        addCamera(camera)
        
        sun.setPosition(0, 150, 0)
        addLight(sun)
                
        addChild(boidManager)
    }
    
    override func doUpdate() {
        boidManager.updateBoids()
    }
}
