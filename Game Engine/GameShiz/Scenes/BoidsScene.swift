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
    
    var boids: [Boid] = []
    
    override func buildScene() {
        addCamera(camera)
        
        sun.setPosition(0, 150, 0)
        addLight(sun)
        
        addChild(cube2)
        
        for _ in 0..<50 {
            let boid = Boid(perceptionRadius: 10)
            boids.append(boid)
            addChild(boid)
        }
    }
    
    override func doUpdate() {
        let qt = QuadTree(capacity: 4, boundary: Boundary(pos: SIMD3<Float>(repeating: -20), size: SIMD3<Float>(40, 40, 40)))
        for boid in boids {
            _ = qt.insert(node: boid)
        }
        
        for boid in boids {
            boid.update(boids: boids)
            
//            let pos = boid.getPosition()
//            let boundary = Boundary(pos: pos - SIMD3<Float>(10, 10, 10), size: SIMD3<Float>(20, 20, 20))
//            let _boids = qt.queryRange(boundary: boundary) as! [Boid]
//            print(_boids.count)
//            boid.update(boids: _boids)
        }
    }
}
