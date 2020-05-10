class SphereScene: Scene {
    let camera = FPSCameraQuaternion()
    let chest = Chest()
    let sun = Sun()
    
    let searchSphere: Sphere = {
        let sphere = Sphere()
        sphere.useBaseColourTexture(.PartyPirateParot)
        var mat = Material()
        mat.isLit = true
        sphere.useMaterial(mat)
        return sphere
    }()
    
    let querySphere: Sphere = {
        let sphere = Sphere()
//        sphere.useBaseColourTexture(.PartyPirateParot)
        var mat = Material()
        mat.isLit = true
        mat.colour = SIMD4<Float>(1, 0, 0, 1)
        sphere.useMaterial(mat)
        sphere.boundingSphere.radius = 0.5
        sphere.setPosition(0, 0, 5)
        return sphere
    }()
    
    let sphere: Sphere = {
        let sphere = Sphere()
        sphere.setScale(SIMD3<Float>(0.1, 0.1, 0.1))
        return sphere
    }()
    
    let isClickTest = false
    
    let gridSize = 2
    
    override func buildScene() {
        camera.setPosition(0, 0, 3)
        addCamera(camera)
        
        sun.setPosition(SIMD3<Float>(0, 5, 5))
        addLight(sun)
        
        if isClickTest {
            addSpheres()
        } else {
            addChild(searchSphere)
            addChild(querySphere)

            addChild(sphere)
        }
    }
    
    override func doUpdate() {
        if isClickTest { return }
        let forward = getModelForward(searchSphere)
        let origin = searchSphere.getPosition()

        sphere.setPosition(forward * SIMD3<Float>(-1, 1, 1))
        
        var mat = querySphere.getMaterial()
        mat?.colour = SIMD4<Float>(1, 0, 0, 1)
        
        let ray = Ray(origin: origin, direction: forward)
        if let hit = self.hitTest(ray) {
            print(hit)
            mat?.colour = SIMD4<Float>(0, 0, 1, 1)
        }
        
        querySphere.useMaterial(mat!)

        searchSphere.rotateY(GameTime.deltaTime * 0.5)
    }
    
    private func getModelForward(_ model: GameObject) -> SIMD3<Float> {
        let mat = model.modelMatrix
        return SIMD3<Float>(x: mat[0][2], y: mat[1][2], z: mat[2][2])
    }
    
    private func addSpheres() {
        for i in -gridSize...gridSize {
            for j in -gridSize...gridSize {
                let sphere = Sphere()
                var mat = Material()
                mat.isLit = true
                mat.colour = SIMD4<Float>(0, 0, 1, 1)
                sphere.useMaterial(mat)
                sphere.setPosition(SIMD3<Float>(Float(i) * 1.1, Float(j) * 1.1, 0))
                sphere.boundingSphere.radius = 0.5
                addChild(sphere)
            }
        }
    }
}
