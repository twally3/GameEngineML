import MetalKit

class Terrain: Node {
    private var _modelConstants = ModelConstants()
    private var _material = Material()
    private var _textureType: TextureTypes = .None
    private var _mesh: Mesh!
    
    private var _texture: MTLTexture!
        
    var _baseColours: [TerrainLayer] = [
        // Water Deep
        TerrainLayer(height: 0,
                     colour: SIMD4<Float>(46 / 255, 90 / 255, 182 / 255, 1.0),
                     scale: 30,
                     blend: 0.05,
                     textureId: 1),
        // Sand
        TerrainLayer(height: 0.3,
                     colour: SIMD4<Float>(216 / 255, 218 / 255, 154 / 255, 1.0),
                     scale: 30,
                     blend: 0.05,
                     textureId: 1),
        // Grass
        TerrainLayer(height: 0.4,
                     colour: SIMD4<Float>(100 / 255, 158 / 255, 32 / 255, 1.0),
                     scale: 30,
                     blend: 0.1,
                     textureId: 2),
        // Rock
        TerrainLayer(height: 0.55,
                     colour: SIMD4<Float>(100 / 255, 80 / 255, 75 / 255, 1.0),
                     scale: 30,
                     blend: 0.05,
                     textureId: 3),
        // Rock 2
        TerrainLayer(height: 0.7,
                     colour: SIMD4<Float>(85 / 255, 70 / 255, 70 / 255, 1.0),
                     scale: 30,
                     blend: 0.05,
                     textureId: 4),
        // Snow
        TerrainLayer(height: 0.85,
                     colour: SIMD4<Float>(255 / 255, 255 / 255, 255 / 255, 1.0),
                     scale: 30,
                     blend: 0.1,
                     textureId: 5)
    ];

    init() {
        super.init(name: "Terrain")
        _mesh = Entities.meshes[.None]
        
        setMaterialIsLit(true)
        setMaterialAmbient(0.3)
        setMaterialDiffuse(1)
        setMaterialSpecular(0)
        setMaterialShininess(0)
    }
    
    override func update() {
        _modelConstants.modelMatrix = self.modelMatrix
        
        super.update()
    }
}

extension Terrain: Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Terrain])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])

        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)

        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Terrain], index: 0)
        renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)

        var terrainDatas = _baseColours
        var terrainCount = terrainDatas.count
        var maxTerrainHeight: Float = 117
        
        renderCommandEncoder.setFragmentBytes(&terrainCount, length: Int32.size, index: 4)
        renderCommandEncoder.setFragmentBytes(&terrainDatas, length: TerrainLayer.stride(terrainCount), index: 5)

        //TODO: 117 is a hack, this needs to be passed in!
        renderCommandEncoder.setFragmentBytes(&maxTerrainHeight, length: Float.size, index: 6)
        
        renderCommandEncoder.setFragmentTexture(Entities.textures[.Terrain], index: 0)
        
        renderCommandEncoder.setFragmentTextures([Entities.textures[.Water],
                                                  Entities.textures[.SandyGrass],
                                                  Entities.textures[.Grass],
                                                  Entities.textures[.StonyGround],
                                                  Entities.textures[.Rocks1],
                                                  Entities.textures[.Snow]
                                                ], range: 1..<7)
        
        _mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder)
    }
}


extension Terrain {
    public func setMaterialColour(_ colour: SIMD4<Float>) {
        self._material.colour = colour
        self._material.useMaterialColour = true
        self._material.useTexture = false
    }

    public func setMaterialColour(_ r: Float, _ g: Float, _ b: Float, _ a: Float) {
        setMaterialColour(SIMD4<Float>(r, g, b, a))
    }

    public func setTexture(_ textureType: TextureTypes) {
        self._textureType = textureType
        self._material.useTexture = true
        self._material.useMaterialColour = false
    }

    public func setTexture(_ texture: MTLTexture) {
        self._texture = texture
        self._material.useTexture = true
        self._material.useMaterialColour = false
    }

    public func setMesh(_ mesh: Mesh) {
        self._mesh = mesh
    }


    public func setMaterialIsLit(_ isLit: Bool) { self._material.isLit = isLit }
    public func getMaterialIsLit() -> Bool { return self._material.isLit }

    public func setMaterialAmbient(_ ambient: SIMD3<Float>) { self._material.ambient = ambient }
    public func setMaterialAmbient(_ ambient: Float) { self._material.ambient = SIMD3<Float>(repeating: ambient) }
    public func addMaterialAmbient(_ value: Float) { self._material.ambient += value }
    public func getMaterialAmbient() -> SIMD3<Float> { return self._material.ambient }

    public func setMaterialDiffuse(_ diffuse: SIMD3<Float>) { self._material.diffuse = diffuse }
    public func setMaterialDiffuse(_ diffuse: Float) { self._material.diffuse = SIMD3<Float>(repeating: diffuse) }
    public func addMaterialDiffuse(_ value: Float) { self._material.diffuse += value }
    public func getMaterialDiffuse() -> SIMD3<Float> { return self._material.diffuse }

    public func setMaterialSpecular(_ specular: SIMD3<Float>) { self._material.specular = specular }
    public func setMaterialSpecular(_ specular: Float) { self._material.specular = SIMD3<Float>(repeating: specular) }
    public func addMaterialSpecular(_ value: Float) { self._material.specular += value }
    public func getMaterialSpecular() -> SIMD3<Float> { return self._material.specular }

    public func setMaterialShininess(_ shininess: Float) { self._material.shininess = shininess }
    public func getMaterialShininess() -> Float { return self._material.shininess }
}
