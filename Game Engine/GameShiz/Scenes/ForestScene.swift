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
        terrain.setScale(SIMD3<Float>(repeating: 100))
        
        let treeCount = 200
        let radius: Float = 10
        
        let well = GameObject(name: "Well", meshType: .Well)
        well.setScale(SIMD3<Float>(repeating: 0.3))
        addChild(well)
        
        for i in 0..<treeCount {
            let tree = GameObject(name: "Tree", meshType: selectRandomTreeMeshType())
            let pos = SIMD3<Float>(cos(Float(i)) * radius + Float.random(in: -2...2),
                                   0,
                                   sin(Float(i)) * radius + Float.random(in: -5...5))
            tree.setPosition(pos)
            tree.setScale(SIMD3<Float>(repeating: Float.random(in: 1...2)))
            tree.rotateY(Float.random(in: 0...360))
            addChild(tree)
        }
        
        let flowerCount = 200
        for _ in 0..<flowerCount {
            let flower = GameObject(name: "Flower", meshType: selectRandomFlowerMeshType())
            let pos = SIMD3<Float>(Float.random(in: -(radius - 1)...(radius + 1)),
                                   0,
                                   Float.random(in: -(radius - 1)...(radius + 1)))
            
            flower.setPosition(pos)
            flower.rotateY(Float.random(in: 0...360))
            addChild(flower)
        }
        
        addChild(terrain)
    }
    
    private func selectRandomTreeMeshType() -> MeshTypes {
        let rand = Int.random(in: 0..<3)
        switch rand {
        case 0:
            return .TreePineA
        case 1:
            return .TreePineB
        case 2:
            return .TreePineC
        default:
            return .TreePineA
        }
    }
    
    private func selectRandomFlowerMeshType() -> MeshTypes {
        let rand = Int.random(in: 0..<3)
        switch rand {
        case 0:
            return .FlowerRed
        case 1:
            return .FlowerYellow
        case 2:
            return .FlowerPurple
        default:
            return .FlowerRed
        }
    }
}
