import MetalKit

class Node {
    private var _name: String = "Node"
    private var _id: String!
    
    private var _position: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    private var _scale: SIMD3<Float> = SIMD3<Float>(repeating: 1)
    private var _rotation: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    
    var parentModelMatrix = matrix_identity_float4x4
    
    private var _modelMatrix = matrix_identity_float4x4
    var modelMatrix: matrix_float4x4 {
        return matrix_multiply(parentModelMatrix, _modelMatrix)
    }
    
    var children: [Node] = []
    
    init(name: String) {
        self._name = name
        self._id = UUID().uuidString
    }
    
    func addChild(_ child: Node) {
        children.append(child)
    }
    
    func updateModelMatrix() {
        _modelMatrix = matrix_identity_float4x4
        _modelMatrix.translate(direction: _position)
        _modelMatrix.rotate(angle: _rotation.x, axis: X_AXIS)
        _modelMatrix.rotate(angle: _rotation.y, axis: Y_AXIS)
        _modelMatrix.rotate(angle: _rotation.z, axis: Z_AXIS)
        _modelMatrix.scale(axis: _scale)
    }
    
    // Overrides for later ;)
    func afterTranslation() {}
    func afterRotation() {}
    func afterScale() {}
    
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
    
    func setPosition(_ position: SIMD3<Float>) {
        self._position = position
        updateModelMatrix()
        afterTranslation()
    }
    
    func setPosition(_ x: Float, _ y: Float, _ z: Float) { setPosition(SIMD3<Float>(x, y, z)) }
    func setPositionX(_ xPosition: Float) { setPosition(SIMD3<Float>(xPosition, getPositionY(), getPositionZ())) }
    func setPositionY(_ yPosition: Float) { setPosition(SIMD3<Float>(getPositionX(), yPosition, getPositionZ())) }
    func setPositionZ(_ zPosition: Float) { setPosition(SIMD3<Float>(getPositionX(), zPosition, getPositionZ())) }
    func move(x: Float, y: Float, z: Float) { setPosition(getPosition() + SIMD3<Float>(x, y, z)) }
    func moveX(_ delta: Float) { move(x: delta, y: 0, z: 0) }
    func moveY(_ delta: Float) { move(x: 0, y: delta, z: 0) }
    func moveZ(_ delta: Float) { move(x: 0, y: 0, z: delta) }
    func getPosition() -> SIMD3<Float> { return self._position }
    func getPositionX() -> Float { return self._position.x }
    func getPositionY() -> Float { return self._position.y }
    func getPositionZ() -> Float { return self._position.z }
    
    func setRotation(_ rotation: SIMD3<Float>) {
        self._rotation = rotation
        updateModelMatrix()
        afterRotation()
    }
    
    func setRotation(_ x: Float, _ y: Float, _ z: Float) { setRotation(SIMD3<Float>(x, y, z)) }
    func setRotationX(_ xRotation: Float) { setRotation(SIMD3<Float>(xRotation, 0, 0)) }
    func setRotationY(_ yRotation: Float) { setRotation(SIMD3<Float>(0, yRotation, 0)) }
    func setRotationZ(_ zRotation: Float) { setRotation(SIMD3<Float>(0, 0, zRotation)) }
    func rotate(x: Float, y: Float, z: Float) { setRotation(getRotation() + SIMD3<Float>(x, y, z)) }
    func rotateX(_ delta: Float) { rotate(x: delta, y: 0, z: 0) }
    func rotateY(_ delta: Float) { rotate(x: 0, y: delta, z: 0) }
    func rotateZ(_ delta: Float) { rotate(x: 0, y: 0, z: delta) }
    func getRotation() -> SIMD3<Float> { return self._rotation }
    func getRotationX() -> Float { return self._rotation.x }
    func getRotationY() -> Float { return self._rotation.y }
    func getRotationZ() -> Float { return self._rotation.z }
    
    func setScale(_ scale: SIMD3<Float>) {
        self._scale = scale
        updateModelMatrix()
        afterScale()
    }
    
    func setScale(_ x: Float, _ y: Float, _ z: Float) { setScale(SIMD3<Float>(x, y, z)) }
    func setScaleX(_ xScale: Float) { setScale(xScale, 0, 0) }
    func setScaleY(_ yScale: Float) { setScale(0, yScale, 0) }
    func setScaleZ(_ zScale: Float) { setScale(0, 0, zScale) }
    func scale(x: Float, y: Float, z: Float) { setScale(getScale() + SIMD3<Float>(x, y, z)) }
    func scaleX(_ delta: Float) { scale(x: delta, y: 0, z: 0) }
    func scaleY(_ delta: Float) { scale(x: 0, y: delta, z: 0) }
    func scaleZ(_ delta: Float) { scale(x: 0, y: 0, z: delta) }
    func getScale() -> SIMD3<Float> { return self._scale }
    func getScaleX() -> Float { return self._scale.x }
    func getScaleY() -> Float { return self._scale.y }
    func getScaleZ() -> Float { return self._scale.z }
    
}
