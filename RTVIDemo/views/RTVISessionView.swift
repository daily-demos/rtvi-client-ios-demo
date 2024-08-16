import SwiftUI

struct RTVISessionView: View {
    
    @EnvironmentObject private var model: CallContainerModel
    
    func disconnect() {
        self.model.rtviClientIOS.disconnect(completion: nil)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("RTVI Session:")
                .font(.headline)
            Text(model.voiceClientStatus)
                .font(.subheadline)
            Button("Disconnect") {
                disconnect()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .toast(message: model.toastMessage, isShowing: model.showToast)
    }
}
