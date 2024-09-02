import SwiftUI

@main
struct DailyBotsDemoApp: App {

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
