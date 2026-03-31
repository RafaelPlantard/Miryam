import Testing
@testable import MiryamVision

@MainActor
@Suite("Vision App Smoke")
struct MiryamVisionTests {
    @Test("Vision app body can be evaluated")
    func visionAppBodySmoke() {
        let app = MiryamVisionApp()
        _ = app.body
    }
}
