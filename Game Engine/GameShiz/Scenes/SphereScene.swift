class SphereScene: Scene {
    let camera = FPSCameraQuaternion()
    let chest = Chest()
    let sun = Sun()
    
    let gridSize = 2
    
    override func buildScene() {
        camera.setPosition(0, 0, 3)
        addCamera(camera)
        
        sun.setPosition(SIMD3<Float>(0, 5, 5))
        addLight(sun)
        
        addSpheres()
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
                addChild(sphere)
            }
        }
    }
}
