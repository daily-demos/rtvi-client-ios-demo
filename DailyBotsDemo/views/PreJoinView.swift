import SwiftUI

struct PreJoinView: View {
    
    // Note: In a production environment, it is recommended to avoid calling Daily's API endpoint directly.
    // Instead, you should route requests through your own server to handle authentication, validation,
    // and any other necessary logic. Therefore, the baseUrl should be set to the URL of your own server.
    @State var backendURL: String
    @State var dailyApiKey: String

    //for dev only, to test using Preview
    //@EnvironmentObject private var model: MockCallContainerModel

    //prod
    @EnvironmentObject private var model: CallContainerModel
    
    init() {
        let currentSettings = SettingsManager.getSettings()
        self.backendURL = currentSettings.backendURL
        self.dailyApiKey = currentSettings.dailyApiKey
    }

    var body: some View {
        VStack(spacing: 20) {
            Image("dailyBot")
                .resizable()
                .frame(width: 64, height: 64)
            Text("Connect to a Daily Bot.")
                .font(.headline)
            SecureField("Daily API Key", text: $dailyApiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                .padding([.horizontal])
            TextField("Server URL", text: $backendURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                .padding([.bottom, .horizontal])
            Button("Connect") {
                self.model.connect(backendURL: self.backendURL, dailyApiKey:self.dailyApiKey)
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.backgroundApp)
        .toast(message: model.toastMessage, isShowing: model.showToast)
    }
}

#Preview {
    PreJoinView().environmentObject(MockCallContainerModel())
}
