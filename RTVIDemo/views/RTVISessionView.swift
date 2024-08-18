import SwiftUI

struct RTVISessionView: View {
    
    @EnvironmentObject private var model: CallContainerModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("RTVI Session:")
                .font(.headline)
            Text(model.voiceClientStatus)
                .font(.subheadline)
            Button("Disconnect") {
                self.model.disconnect()
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
