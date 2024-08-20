import SwiftUI

struct SettingsView: View {
    
    @Binding var showingSettings: Bool
    
    @State private var selectedMic: String? = nil
    @State private var microphones: [String] = ["Mic 1", "Mic 2", "Mic 3"] // Replace with actual microphone fetching logic

    
    var body: some View {
        NavigationView {
            Text("Settings")
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showingSettings = false
                        }
                    }
                }
        }
    }
}
