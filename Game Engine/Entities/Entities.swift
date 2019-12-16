class Entities {
    
    private static var _meshLibrary: MeshLibrary!
    public static var meshes: MeshLibrary { return _meshLibrary }
    
    public static func initialise() {
        self._meshLibrary = MeshLibrary()
    }
}
