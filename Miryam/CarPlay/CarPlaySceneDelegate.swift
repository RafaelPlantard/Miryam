#if canImport(CarPlay)
    import CarPlay
    import MiryamCore
    import MiryamFeatures

    class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
        var interfaceController: CPInterfaceController?

        func templateApplicationScene(
            _ templateApplicationScene: CPTemplateApplicationScene,
            didConnect interfaceController: CPInterfaceController
        ) {
            self.interfaceController = interfaceController

            let nowPlayingTemplate = CPNowPlayingTemplate.shared
            interfaceController.setRootTemplate(nowPlayingTemplate, animated: true, completion: nil)
        }

        func templateApplicationScene(
            _ templateApplicationScene: CPTemplateApplicationScene,
            didDisconnectInterfaceController interfaceController: CPInterfaceController
        ) {
            self.interfaceController = nil
        }
    }
#endif
