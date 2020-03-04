import GameplayKit
import simd

class TerrainScene: Scene {
    let camera = DebugCamera()
    let sun = Sun()
    let waterQuad = WaterQuad()

    let terrain: Terrain = {
        let terrain = Terrain()
        let mapGenerator = MapGenerator()
        let mapData = mapGenerator.generateMapData(centre: SIMD2<Int>(repeating: 0))
        let terrainMesh = Terrain_CustomMesh(heightMap: mapData.noiseMap, levelOfDetail: 0)
        terrain.setTexture(mapData.texture)
        terrain.setMesh(terrainMesh)
        return terrain
    }()
    
    override func buildScene() {
        camera.setPosition(0, 50, 10)
        addCamera(camera)
        
        sun.setPosition(0, 100, 0)
        sun.setMaterialIsLit(false)
        addLight(sun)
        
        waterQuad.setMaterialIsLit(true)
        waterQuad.setMaterialDiffuse(0)
        waterQuad.setMaterialSpecular(0.3)
        waterQuad.setMaterialShininess(40)
        waterQuad.setMaterialAmbient(1)
        waterQuad.rotateX(-Float.pi / 2)
        waterQuad.setScale(SIMD3<Float>(repeating: 120))
        waterQuad.setPositionY(0.38*80)
        
        addWater(waterQuad)
        addChild(terrain)
    }
}
