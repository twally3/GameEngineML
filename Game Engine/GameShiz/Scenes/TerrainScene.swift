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
//        camera.setRotationX(Float.pi / 2)
        addCamera(camera)
        
        sun.setPosition(0, 100, 0)
        sun.setMaterialIsLit(false)
        addLight(sun)
        
//        waterQuad.setMaterialColour(SIMD4<Float>(x: 1, y: 0, z: 0, w: 0))
//        waterQuad.setMaterialIsLit(false)
        waterQuad.setMaterialIsLit(true)
        waterQuad.setMaterialDiffuse(0)
        waterQuad.setMaterialSpecular(0.3)
        waterQuad.setMaterialShininess(2)
        waterQuad.setMaterialAmbient(1)
        waterQuad.rotateX(-Float.pi / 2)
        waterQuad.setScale(SIMD3<Float>(repeating: 119))
        waterQuad.setPositionY(0.35*80)
        
        addWater(waterQuad)
        addChild(terrain)
    }
}
