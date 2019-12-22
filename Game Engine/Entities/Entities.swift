class Entities {
    private static var _meshLibrary: MeshLibrary!
    public static var meshes: MeshLibrary { return _meshLibrary }
    
    private static var _textureLibrary: TextureLibrary!
    public static var textures: TextureLibrary { return _textureLibrary }
    
    public static func initialise() {
        self._meshLibrary = MeshLibrary()
        self._textureLibrary = TextureLibrary()
    }
}
