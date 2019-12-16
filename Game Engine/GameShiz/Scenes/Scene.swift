import MetalKit

class Scene: Node {
    
    private var _cameraManager = CameraManager()
    private var _lightManager = LightManager()
    private var _sceneConstants = SceneConstants()
    
    init() {
        super.init(name: "Scene")
        buildScene()
    }
    
    func buildScene() {}
    
    func addCamera(_ camera: Camera, _ isCurrentCamera: Bool = true) {
        _cameraManager.registerCamera(camera: camera)
        
        if (isCurrentCamera) {
            _cameraManager.setCamera(camera.cameraType)
        }
    }
    
    func addLight(_ light: LightObject) {
        self.addChild(light)
        self._lightManager.addLightObject(light)
    }
    
    func updateSceneConstants() {
        _sceneConstants.viewMatrix = _cameraManager.currentCamera.viewMatrix
        _sceneConstants.projectionMatrix = _cameraManager.currentCamera.projectionMatrix
    }
    
    func updateCameras() {
        _cameraManager.update()
    }
    
    override func update() {
        updateSceneConstants()
        super.update()
    }
    
    override func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setVertexBytes(&_sceneConstants, length: SceneConstants.stride, index: 1)
        _lightManager.setLightData(renderCommandEncoder)
        super.render(renderCommandEncoder: renderCommandEncoder)
    }
    
}
