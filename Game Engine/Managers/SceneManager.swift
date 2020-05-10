import MetalKit

enum SceneTypes {
    case Sandbox
    case Default
    case Terrain
    case Boids
    case Sphere
}

class SceneManager {
    private static var _currentScene: Scene!
    
    public static func initialize(_ sceneType: SceneTypes) {
        setScene(sceneType: sceneType)
    }
    
    public static func setScene(sceneType: SceneTypes) {
        switch sceneType {
        case .Sandbox:
            _currentScene = SandboxScene(name: "Sandbox")
        case .Default:
            _currentScene = DefaultScene(name: "Default")
        case .Terrain:
            _currentScene = TerrainScene(name: "Terrain")
        case .Boids:
            _currentScene = BoidsScene(name: "Boids")
        case .Sphere:
            _currentScene = SphereScene(name: "Sphere")
        }
    }
    
    public static func tickScene(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        GameTime.updateTime(deltaTime)
        _currentScene.updateCameras()
        _currentScene.update()
        _currentScene.render(renderCommandEncoder: renderCommandEncoder)
    }
    
    public static func updateScene(deltaTime: Float) {
        GameTime.updateTime(deltaTime)
        _currentScene.updateCameras()
        _currentScene.update()
    }
    
    public static func renderScene(renderCommandEncoder: MTLRenderCommandEncoder) {
        _currentScene.render(renderCommandEncoder: renderCommandEncoder)
    }
    
    public static func renderWater(renderCommandEncoder: MTLRenderCommandEncoder) {
        _currentScene.renderWater(renderCommandEncoder: renderCommandEncoder)
    }
    
    public static func getCurrentScene() -> Scene {
        return self._currentScene
    }
}

