import GameplayKit
import simd

class TerrainScene: Scene {
    let camera = FPSCameraQuaternion()
    let sun = Sun()
    let waterQuad: WaterQuad = {
        let waterQuad = WaterQuad()
        waterQuad.rotateX(-Float.pi / 2)
        waterQuad.setScale(SIMD3<Float>(repeating: 120 * 2))
        waterQuad.setPositionY(0.4*110)
        return waterQuad
    }()

    let terrain: Terrain = {
        let terrain = Terrain()
        let meshSettings = MeshSettings()
        let heightMapSettings = HeightMapSettings()

        let mapData = HeightMapGenerator.generateHeightMap(width: meshSettings.numVertsPerLine,
                                                           height: meshSettings.numVertsPerLine,
                                                           settings: heightMapSettings,
                                                           sampleCentre: SIMD2<Float>(repeating: 0))
        
        let terrainMesh = Terrain_CustomMesh(heightMap: mapData.values, levelOfDetail: 0, settings: meshSettings)

        terrain.setMesh(terrainMesh)
        terrain.setScaleX(2)
        terrain.setScaleZ(2)
        return terrain
    }()
    
    let skybox: SkyBox = {
        let skybox = SkyBox()
        skybox.setScale(SIMD3<Float>(repeating: 1000))
        return skybox
    }()
    
    override func buildScene() {
        camera.setPosition(0, 50, 10)
        addCamera(camera)
        
        sun.setPosition(0, 150, 0)
        addLight(sun)
        
        addChild(skybox)

        addChild(terrain)

        addWater(waterQuad)
    }
    
    override func doUpdate() {
        skybox.setPosition(camera.getPosition())
        
        sun.setPositionX(cos(GameTime.totalGameTime) * 500)
        sun.setPositionZ(sin(GameTime.totalGameTime) * 500)
    }
}
