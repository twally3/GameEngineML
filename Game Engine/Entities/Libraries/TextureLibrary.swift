import MetalKit

enum TextureTypes{
    case None
    case PartyPirateParot
    case Cruiser
    case WaterDUDV
    case WaterNormalMap
    case WaterReflectionTexture
    case WaterRefractionTexture
    case WaterRefractionDepthTexture
    case SkyBox
    
    // --- TERRAIN ---
    case Water
    case SandyGrass
    case Grass
    case StonyGround
    case Rocks1
    case Snow
    case Terrain
}

class TextureLibrary: Library<TextureTypes, MTLTexture> {
    private var _library: [TextureTypes : Texture] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Texture("PartyPirateParot"), forKey: .PartyPirateParot)
        _library.updateValue(Texture("cruiser", ext: "bmp", origin: .bottomLeft), forKey: .Cruiser)
        _library.updateValue(Texture("waterDUDV"), forKey: .WaterDUDV)
        _library.updateValue(Texture("waterNormalMap"), forKey: .WaterNormalMap)
        _library.updateValue(Texture(["left", "right", "up", "down", "back", "front"], cubeMap: true), forKey: .SkyBox)

        _library.updateValue(Texture(["Water", "Sandy grass", "Grass", "Stony ground", "Rocks 1", "Snow"], cubeMap: false), forKey: .Terrain)
        
        _library.updateValue(Texture("Water"), forKey: .Water)
        _library.updateValue(Texture("Sandy grass"), forKey: .SandyGrass)
        _library.updateValue(Texture("Grass"), forKey: .Grass)
        _library.updateValue(Texture("Stony ground"), forKey: .StonyGround)
        _library.updateValue(Texture("Rocks 1"), forKey: .Rocks1)
        _library.updateValue(Texture("Snow"), forKey: .Snow)
    }
    
    override subscript(_ type: TextureTypes) -> MTLTexture? {
        get {
            return _library[type]?.texture
        }
        
        set(texture) {
            _library.updateValue(Texture(texture!), forKey: type)
        }
    }
}

class Texture {
    var texture: MTLTexture!
    
    init(_ texture: MTLTexture) {
        setTexture(texture)
    }
    
    init(_ textureName: String, ext: String = "png", origin: MTKTextureLoader.Origin = .topLeft){
        let textureLoader = TextureLoader(textureName: textureName, textureExtension: ext, origin: origin)
        let texture: MTLTexture = textureLoader.loadTextureFromBundle()
        setTexture(texture)
    }
    
    init(_ textureNames: [String], ext: String = "png", origin: MTKTextureLoader.Origin = .topLeft, cubeMap: Bool = false) {
        var texture: MTLTexture!
        
        if cubeMap {
            texture = loadCubeMap(textureNames: textureNames, ext: ext, origin: origin)
        } else {
            texture = loadTexture2DArray(textureNames: textureNames, ext: ext, origin: origin)
        }
        
        setTexture(texture)
    }
    
    func loadTexture2DArray(textureNames: [String], ext: String, origin: MTKTextureLoader.Origin) -> MTLTexture {
        var texture: MTLTexture!
        let scale: Int = 1
//        let firstImage = NSImage(named: textureNames.first!)
        #if os(iOS)
            let firstImage = UIImage(named: textureNames.first!)
        #elseif os(macOS)
            let firstImage = NSImage(named: textureNames.first!)
        #endif
        let cubeSize = Int(firstImage!.size.width) * scale
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = Preferences.mainPixelFormat
        textureDescriptor.height = cubeSize
        textureDescriptor.width = cubeSize
        textureDescriptor.textureType = .type2DArray
        textureDescriptor.arrayLength = textureNames.count
        textureDescriptor.mipmapLevelCount = Int(log2(Float(cubeSize)) + 1)
        
        texture = Engine.device.makeTexture(descriptor: textureDescriptor)
        
        for (i, textureName) in textureNames.enumerated() {
            let textureLoader = TextureLoader(textureName: textureName, textureExtension: ext, origin: origin)
            let tex: MTLTexture = textureLoader.loadTextureFromBundle()

            for j in 0..<tex.mipmapLevelCount {
                let texSize = cubeSize / Int(pow(Double(2), Double(j)))

                let rowBytes = texSize * 4
                let length = rowBytes * texSize
                let bgraBytes = [UInt8](repeating: 0, count: length)
                tex.getBytes(UnsafeMutableRawPointer(mutating: bgraBytes),
                             bytesPerRow: rowBytes,
                             from: MTLRegionMake2D(0, 0, texSize, texSize),
                             mipmapLevel: j)

                texture.replace(region: MTLRegionMake2D(0, 0, texSize, texSize),
                                 mipmapLevel: j,
                                 slice: i,
                                 withBytes: bgraBytes,
                                 bytesPerRow: rowBytes,
                                 bytesPerImage: bgraBytes.count)
            }
        }
        
        return texture
    }
    
    func loadCubeMap(textureNames: [String], ext: String, origin: MTKTextureLoader.Origin) -> MTLTexture {
        var texture: MTLTexture!
        let scale: Int = 1
//        let firstImage = NSImage(named: textureNames.first!)
        #if os(iOS)
            let firstImage = UIImage(named: textureNames.first!)
        #elseif os(macOS)
            let firstImage = NSImage(named: textureNames.first!)
        #endif
        let cubeSize = Int(firstImage!.size.width) * scale

        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .bgra8Unorm_srgb
        textureDescriptor.height = cubeSize
        textureDescriptor.width = cubeSize
        textureDescriptor.textureType = .typeCube
        
        texture = Engine.device.makeTexture(descriptor: textureDescriptor)

        for (i, imageName) in textureNames.enumerated() {
            let textureLoader = TextureLoader(textureName: imageName, textureExtension: ext, origin: origin)
            let tex: MTLTexture = textureLoader.loadTextureFromBundle()
            
            let rowBytes = cubeSize * 4
            let length = rowBytes * cubeSize
            let bgraBytes = [UInt8](repeating: 0, count: length)
            tex.getBytes(UnsafeMutableRawPointer(mutating: bgraBytes),
                         bytesPerRow: rowBytes,
                         from: MTLRegionMake2D(0, 0, cubeSize, cubeSize),
                         mipmapLevel: 0)
            
            texture.replace(region: MTLRegionMake2D(0, 0, cubeSize, cubeSize),
                             mipmapLevel: 0,
                             slice: i,
                             withBytes: bgraBytes,
                             bytesPerRow: rowBytes,
                             bytesPerImage: bgraBytes.count)
        }
        
        return texture
    }
    
    func setTexture(_ texture: MTLTexture){
        self.texture = texture
    }
}

class TextureLoader {
    private var _textureName: String!
    private var _textureExtension: String!
    private var _origin: MTKTextureLoader.Origin!
    
    init(textureName: String, textureExtension: String = "png", origin: MTKTextureLoader.Origin = .topLeft){
        self._textureName = textureName
        self._textureExtension = textureExtension
        self._origin = origin
    }
    
    public func loadTextureFromBundle()->MTLTexture{
        var result: MTLTexture!
        if let url = Bundle.main.url(forResource: _textureName, withExtension: self._textureExtension) {
            let textureLoader = MTKTextureLoader(device: Engine.device)
            
            let options: [MTKTextureLoader.Option : Any] = [
                MTKTextureLoader.Option.origin : _origin as Any,
                MTKTextureLoader.Option.generateMipmaps : true
            ]
            
            do{
                result = try textureLoader.newTexture(URL: url, options: options)
                result.label = _textureName
            }catch let error as NSError {
                print("ERROR::CREATING::TEXTURE::__\(_textureName!)__::\(error)")
            }
        }else {
            print("ERROR::CREATING::TEXTURE::__\(_textureName!) does not exist")
        }
        
        return result
    }
}
