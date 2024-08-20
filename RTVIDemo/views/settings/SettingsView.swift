import SwiftUI
import RTVIClientIOS

struct SettingsView: View {
    
    //for dev only, to test using Preview
    //@EnvironmentObject private var model: MockCallContainerModel
    
    //prod
    @EnvironmentObject private var model: CallContainerModel
    
    @Binding var showingSettings: Bool
    
    @State private var selectedMic: MediaDeviceId? = nil
    @State private var isMicEnabled: Bool = true
    @State private var backendURL: String = ""
    @State private var dailyApiKey: String = ""
    
    
    var body: some View {
        let microphones = self.model.rtviClientIOS?.getAllMics() ?? []
        NavigationView {
            Form {
                Section(header: Text("Credentials")) {
                    SecureField("Daily API Key", text: $dailyApiKey)
                }
                Section(header: Text("Audio Settings")) {
                    List(microphones, id: \.self.id.id) { mic in
                        Button(action: {
                            self.selectMic(mic.id)
                        }) {
                            HStack {
                                Text(mic.name)
                                Spacer()
                                if mic.id == self.selectedMic {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                Section(header: Text("Start options")) {
                    Toggle("Enable Microphone", isOn: $isMicEnabled)
                }
                Section(header: Text("Server")) {
                    TextField("Backend URL", text: $backendURL)
                        .keyboardType(.URL)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        self.saveSettings()
                        self.showingSettings = false
                    }
                }
            }
            .onAppear {
                self.loadSettings()
            }
        }
    }
    
    private func selectMic(_ mic: MediaDeviceId) {
        self.selectedMic = mic
        self.model.rtviClientIOS?.updateMic(micId: mic, completion: nil)
    }
    
    private func saveSettings() {
        let newSettings = SettingsPreference(
            selectedMic: selectedMic?.id,
            isMicEnabled: isMicEnabled,
            backendURL: backendURL,
            dailyApiKey: dailyApiKey
        )
        SettingsManager.updateSettings(settings: newSettings)
    }
    
    private func loadSettings() {
        let savedSettings = SettingsManager.getSettings()
        if let selectedMic = savedSettings.selectedMic {
            self.selectedMic = MediaDeviceId(id: selectedMic)
        } else {
            self.selectedMic = nil
        }
        self.isMicEnabled = savedSettings.isMicEnabled
        self.backendURL = savedSettings.backendURL
        self.dailyApiKey = savedSettings.dailyApiKey
    }
}

#Preview {
    SettingsView(showingSettings: .constant(true))
}
