import simd

class ForestScene: Scene {
    let camera = DebugCamera()
    
    override func buildScene() {
        camera.setPosition(0, 1, 3)
        camera.setRotationX(Float(10).toRadians)
        addCamera(camera)
        
        let sunColour = SIMD4<Float>(0.7, 0.5, 0, 1)
        var sunMaterial = Material()
        sunMaterial.colour = sunColour
        sunMaterial.isLit = false
        
        let sun = LightObject(name: "Sun", meshType: .Sphere)
        sun.setScale(SIMD3<Float>(repeating: 10))
        sun.setPosition(SIMD3<Float>(0, 100, 100))
        sun.useMaterial(sunMaterial)
        addLight(sun)
        
        let light = LightObject(name: "Light")
        light.setPosition(0, 100, -100)
        light.setLightBrightness(0.5)
        addLight(light)
        
        let terrain = GameObject(name: "Terrain", meshType: .GroundGrass)
        terrain.setScale(SIMD3<Float>(repeating: 200))
        addChild(terrain)
        
        let tent = GameObject(name: "Tent", meshType: .Tent_Opened)
        tent.rotateY(Float(20).toRadians)
        addChild(tent)
        
        let trees = Trees(treeACount: 1000, treeBCount: 1000, treeCCount: 1000)
        addChild(trees)
        
        let flowers = Flowers(flowerRedCount: 1000, flowerPurpleCount: 1000, flowerYellowCount: 1000)
        addChild(flowers)   
    }
}
