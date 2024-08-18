import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var model: CallContainerModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Connect to an RTVI server")
                .font(.headline)

            Text("Backend URL")
                .font(.subheadline)

            TextField("Enter URL", text: $model.backendURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Connect") {
                self.model.connect()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .toast(message: model.toastMessage, isShowing: model.showToast)
    }
}

/*#Preview {
    ContentView(model: <#CallContainerModel#>)
}*/
