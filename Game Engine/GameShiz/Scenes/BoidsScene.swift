import simd

class BoidsScene: Scene {
    let camera = FPSCameraQuaternion()
    let sun = Sun()
        
    let cube2: Cube = {
        let x = Cube()
        x.setPosition(SIMD3<Float>(repeating: -20))
        x.setScale(SIMD3<Float>(repeating: 40))
        var mat = Material()
        mat.isLit = false
        mat.colour = SIMD4<Float>(0, 0, 1, 1)
        x.useMaterial(mat)
        return x
    }()
    
    let boidManager = BoidManager()
    
    var boids: [Boid] = []
    
    override func buildScene() {
        addCamera(camera)
        
        sun.setPosition(0, 150, 0)
        addLight(sun)
        
//        addChild(cube2)
        
        for boid in boidManager.boids {
            addChild(boid)
        }
    }
    
    override func doUpdate() {
        boidManager.update()
    }
}
