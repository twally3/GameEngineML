import MetalKit

class Scene: Node {
    private var _cameraManager = CameraManager()
    private var _lightManager = LightManager()
    private var _sceneConstants = SceneConstants()
    
    private var _waters: [Water] = []
    
    public var clippingPlane = SIMD4<Float>(repeating: 0) 
    
    override init(name: String) {
        super.init(name: name)
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
    
    func addWater(_ water: Water) {
        _waters.append(water)
    }
    
    func updateCameras() {
        _cameraManager.update()
    }
    
    func updateSceneConstants() {
        _sceneConstants.viewMatrix = _cameraManager.currentCamera.viewMatrix
        _sceneConstants.projectionMatrix = _cameraManager.currentCamera.projectionMatrix
        _sceneConstants.cameraPosition = _cameraManager.currentCamera.getPosition()
        _sceneConstants.clippingPlane = self.clippingPlane
    }
    
    override func update() {
        updateSceneConstants()
        
        for water in _waters {
            water.update()
        }
        
        super.update()
    }
    
    override func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.pushDebugGroup("Rendering Scene \(getName())")
        renderCommandEncoder.setVertexBytes(&_sceneConstants, length: SceneConstants.stride, index: 1)
        _lightManager.setLightData(renderCommandEncoder)
        super.render(renderCommandEncoder: renderCommandEncoder)
        renderCommandEncoder.popDebugGroup()
    }
    
    func renderWater(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.pushDebugGroup("Rendering Scene \(getName()) water")
        renderCommandEncoder.setVertexBytes(&_sceneConstants, length: SceneConstants.stride, index: 1)
        _lightManager.setLightData(renderCommandEncoder)
        
        for water in _waters {
            water.render(renderCommandEncoder: renderCommandEncoder)
        }
        renderCommandEncoder.popDebugGroup()
    }
    
    func getCameraManager() -> CameraManager {
        return self._cameraManager
    }
}
