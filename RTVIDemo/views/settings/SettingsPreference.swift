import Foundation

struct SettingsPreference: Codable {
    var selectedMic: String?
    var isMicEnabled: Bool
    var backendURL: String
    var dailyApiKey: String
}

