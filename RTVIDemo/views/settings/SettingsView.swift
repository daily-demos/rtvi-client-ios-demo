import SwiftUI
import RTVIClientIOS

struct SettingsView: View {
    
    @Binding var showingSettings: Bool
    
    private var rtviClientIOS: VoiceClient?
    private let microphones: [MediaDeviceInfo]
    
    @State private var selectedMic: MediaDeviceId? = nil
    @State private var isMicEnabled: Bool = true
    @State private var backendURL: String = ""
    @State private var dailyApiKey: String = ""
    
    @MainActor
    init(showingSettings: Binding<Bool>, rtviClientIOS: VoiceClient?) {
        self._showingSettings = showingSettings
        self.rtviClientIOS = rtviClientIOS
        self.microphones = rtviClientIOS?.getAllMics() ?? []
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Credentials")) {
                    SecureField("Daily API Key", text: $dailyApiKey)
                }
                Section(header: Text("Audio Settings")) {
                    List(microphones, id: \.self.id.id) { mic in
                        Button(action: {
                            selectMic(mic.id)
                        }) {
                            HStack {
                                Text(mic.name)
                                Spacer()
                                if mic.id == selectedMic {
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
                        saveSettings()
                        showingSettings = false
                    }
                }
            }
            .onAppear {
                loadSettings()
            }
        }
    }
    
    private func selectMic(_ mic: MediaDeviceId) {
        // TODO invoke callModel
        selectedMic = mic
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
    SettingsView(showingSettings: .constant(true), rtviClientIOS: nil)
}
