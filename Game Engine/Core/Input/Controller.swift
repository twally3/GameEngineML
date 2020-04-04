import GameController

class Controller {
    // TODO: Currently dependent on only one controller.
    // Add support for more in the future by binding each one
    private static var controller: GCController?
    
    static func ignite() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(Controller.controllerDidConnect),
                                               name: NSNotification.Name.GCControllerDidConnect,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(Controller.controllerDidDisconnect),
                                               name: NSNotification.Name.GCControllerDidDisconnect,
                                               object: nil)
    }
    
    static func getController() -> GCController? {
        return controller
    }
    
    @objc static func controllerDidConnect() {
        print("Controller Connect")
        controller = GCController.controllers().first
    }
    
    @objc static func controllerDidDisconnect() {
        print("Controller Disconnect")
        controller = nil
    }
}
