import SwiftUI

@main
struct RTVIDemoApp: App {

    @StateObject var callContainerModel = CallContainerModel()

    var body: some Scene {
        WindowGroup {
            if (!callContainerModel.isInCall) {
                PreJoinView().environmentObject(callContainerModel)
            } else {
                MeetingView().environmentObject(callContainerModel)
            }
        }
    }

}
