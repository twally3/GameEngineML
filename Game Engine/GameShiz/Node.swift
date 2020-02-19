import MetalKit

class Node {
    private var _name: String = "Node"
    private var _id: String!
    
    private var _position: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    private var _scale: SIMD3<Float> = SIMD3<Float>(repeating: 1)
    private var _rotation: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    
    var parentModelMatrix = matrix_identity_float4x4
    
    var modelMatrix: matrix_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix.translate(direction: _position)
        modelMatrix.rotate(angle: _rotation.x, axis: X_AXIS)
        modelMatrix.rotate(angle: _rotation.y, axis: Y_AXIS)
        modelMatrix.rotate(angle: _rotation.z, axis: Z_AXIS)
        modelMatrix.scale(axis: _scale)
        return matrix_multiply(parentModelMatrix, modelMatrix)
    }
    
    var children: [Node] = []
    
    init(name: String) {
        self._name = name
        self._id = UUID().uuidString
    }
    
    func addChild(_ child: Node) {
        children.append(child)
    }
    
    func removeChild(_ child: Node) {
        children.removeAll { (x) -> Bool in
            x.getID() == child.getID()
        }
    }
    
    func doUpdate() {}
    
    func update() {
        doUpdate()
        
        for child in children {
            child.parentModelMatrix = self.modelMatrix
            child.update()
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.pushDebugGroup("Rendering \(_name)")
        
        if let renderable = self as? Renderable {
            renderable.doRender(renderCommandEncoder)
        }
        
        for child in children {
            child.render(renderCommandEncoder: renderCommandEncoder)
        }
        
        renderCommandEncoder.popDebugGroup()
    }
}

extension Node {
    func setName(_ name: String) { self._name = name }
    func getName() -> String { return self._name }
    func getID() -> String { return self._id }
    
    func setPosition(_ position: SIMD3<Float>) { self._position = position }
    func setPosition(_ x: Float, _ y: Float, _ z: Float) { self._position = SIMD3<Float>(x, y, z) }
    func setPositionX(_ xPosition: Float) { self._position.x = xPosition }
    func setPositionY(_ yPosition: Float) { self._position.y = yPosition }
    func setPositionZ(_ zPosition: Float) { self._position.z = zPosition }
    func getPosition() -> SIMD3<Float> { return self._position }
    func getPositionX() -> Float { return self._position.x }
    func getPositionY() -> Float { return self._position.y }
    func getPositionZ() -> Float { return self._position.z }
    func move(x: Float, y: Float, z: Float) { self._position += SIMD3<Float>(x, y, z) }
    func moveX(_ delta: Float) { self._position.x += delta }
    func moveY(_ delta: Float) { self._position.y += delta }
    func moveZ(_ delta: Float) { self._position.z += delta }
    
    func setRotation(_ rotation: SIMD3<Float>) { self._rotation = rotation }
    func setRotation(_ x: Float, _ y: Float, _ z: Float) { self._rotation = SIMD3<Float>(x, y, z) }
    func setRotationX(_ xRotation: Float) { self._rotation.x = xRotation }
    func setRotationY(_ yRotation: Float) { self._rotation.y = yRotation }
    func setRotationZ(_ zRotation: Float) { self._rotation.z = zRotation }
    func getRotation() -> SIMD3<Float> { return self._rotation }
    func getRotationX() -> Float { return self._rotation.x }
    func getRotationY() -> Float { return self._rotation.y }
    func getRotationZ() -> Float { return self._rotation.z }
    func rotate(x: Float, y: Float, z: Float) { self._rotation += SIMD3<Float>(x, y, z) }
    func rotateX(_ delta: Float) { self._rotation.x += delta }
    func rotateY(_ delta: Float) { self._rotation.y += delta }
    func rotateZ(_ delta: Float) { self._rotation.z += delta }
    
    func setScale(_ scale: SIMD3<Float>) { self._scale = scale }
    func setScale(_ x: Float, _ y: Float, _ z: Float) { self._scale = SIMD3<Float>(x, y, z) }
    func setScaleX(_ xScale: Float) { self._scale.x = xScale }
    func setScaleY(_ yScale: Float) { self._scale.y = yScale }
    func setScaleZ(_ zScale: Float) { self._scale.z = zScale }
    func getScale() -> SIMD3<Float> { return self._scale }
    func getScaleX() -> Float { return self._scale.x }
    func getScaleY() -> Float { return self._scale.y }
    func getScaleZ() -> Float { return self._scale.z }
    func scaleX(_ delta: Float) { self._scale.x += delta }
    func scaleY(_ delta: Float) { self._scale.y += delta }
    func scaleZ(_ delta: Float) { self._scale.z += delta }
}
