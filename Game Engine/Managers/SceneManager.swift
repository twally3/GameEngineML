import MetalKit

enum SceneTypes {
    case Sandbox
}

class SceneManager {
    
    private static var _currentScene: Scene!
    
    public static func initialize(_ sceneType: SceneTypes) {
        setScene(sceneType: sceneType)
    }
    
    public static func setScene(sceneType: SceneTypes) {
        switch sceneType {
        case .Sandbox:
            _currentScene = SandboxScene()
        }
    }
    
    public static func tickScene(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        GameTime.updateTime(deltaTime)
        _currentScene.updateCameras()
        _currentScene.update()
        _currentScene.render(renderCommandEncoder: renderCommandEncoder)
    }
}
