import SwiftUI

struct SettingsView: View {
    @Binding var showingSettings: Bool
    @State private var settingsManager = SettingsManager()
    @State private var selectedMic: String?
    @State private var microphones: [String] = ["Mic 1", "Mic 2", "Mic 3"]
    @State private var isMicEnabled: Bool = true
    @State private var backendURL: String = ""
    @State private var dailyApiKey: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Credentials")) {
                    SecureField("Daily API Key", text: $dailyApiKey)
                }
                Section(header: Text("Audio Settings")) {
                    List(microphones, id: \.self) { mic in
                        Button(action: {
                            selectMic(mic)
                        }) {
                            HStack {
                                Text(mic)
                                Spacer()
                                if mic == selectedMic {
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

    private func selectMic(_ mic: String) {
        selectedMic = mic
    }

    private func saveSettings() {
        let newSettings = SettingsPreference(
            selectedMic: selectedMic,
            isMicEnabled: isMicEnabled,
            backendURL: backendURL,
            dailyApiKey: dailyApiKey
        )
        settingsManager.settings = newSettings
    }

    private func loadSettings() {
        let savedSettings = settingsManager.settings
        selectedMic = savedSettings.selectedMic
        isMicEnabled = savedSettings.isMicEnabled
        backendURL = savedSettings.backendURL
        dailyApiKey = savedSettings.dailyApiKey
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showingSettings: .constant(true))
    }
}
