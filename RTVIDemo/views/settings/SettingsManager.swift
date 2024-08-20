import Foundation

class SettingsManager {
    private let preferencesKey = "settingsPreference"

    var settings: SettingsPreference {
        get {
            if let data = UserDefaults.standard.data(forKey: preferencesKey),
               let settings = try? JSONDecoder().decode(SettingsPreference.self, from: data) {
                return settings
            } else {
                // default values in case we don't have any settings
                return SettingsPreference(isMicEnabled: true, backendURL: "https://api.daily.co/v1/bots/start", dailyApiKey: "")
            }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: preferencesKey)
            }
        }
    }
}
