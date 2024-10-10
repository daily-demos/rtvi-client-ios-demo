import Foundation

class SettingsManager {
    private static let preferencesKey = "settingsPreference"

    static func getSettings() -> SettingsPreference {
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let settings = try? JSONDecoder().decode(SettingsPreference.self, from: data) {
            return settings
        } else {
            // default values in case we don't have any settings
            return SettingsPreference(enableMic: true, backendURL: "https://api.daily.co/v1/bots", dailyApiKey: "")
        }
    }
    
    static func updateSettings(settings: SettingsPreference) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: preferencesKey)
        }
    }
}
