#if os(iOS)
import SwiftUI

@main
struct FlacMusiciOSApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                MusicAPIService.shared.validateCookieIfNeeded()
            }
        }
    }
}
#endif
