import SwiftUI

import RTVIClientIOSDaily
import RTVIClientIOS

@MainActor
class CallContainerModel: ObservableObject {
    
    @Published var voiceClientStatus: String = TransportState.idle.description
    @Published var isInCall: Bool = false
    @Published var isBotReady: Bool = false
    @Published var timerCount = 0
    
    @Published var isMicEnabled: Bool = false
    
    @Published var toastMessage: String? = nil
    @Published var showToast: Bool = false
    
    @Published
    var remoteAudioLevel: Float = 0
    @Published
    var localAudioLevel: Float = 0
    
    private var meetingTimer: Timer?
    
    var rtviClientIOS: VoiceClient?
    
    init() {
        // Changing the log level
        RTVIClientIOS.setLogLevel(.warn)
    }
    
    private func createOptions(dailyApiKey:String, enableMic:Bool) -> VoiceClientOptions {
        let clientConfigOptions = [
            ServiceConfig(
                service: "llm",
                options: [
                    Option(name: "model", value: Value.string("meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo")),
                    Option(name: "initial_messages", value: Value.array([
                        Value.object([
                            "role" : Value.string("system"),
                            "content": Value.string("You are a assistant called Frankie. You can ask me anything. Keep responses brief and legible. Introduce yourself first.")
                        ])
                    ])),
                    Option(name: "run_on_config", value: Value.boolean(true)),
                ]
            ),
            ServiceConfig(
                service: "tts",
                options: [
                    Option(name: "voice", value: Value.string("79a125e8-cd45-4c13-8a67-188112f4dd22"))
                ]
            )
        ]
        
        let customHeaders = [["Authorization": "Bearer \(dailyApiKey)"]]
        let customBodyParams = Value.object([
            "bot_profile": Value.string("voice_2024_08"),
            "max_duration": Value.number(680)
        ])
        
        return VoiceClientOptions.init(
            enableMic: enableMic,
            enableCam: false,
            services: ["llm": "together", "tts": "cartesia"],
            config: clientConfigOptions,
            customHeaders: customHeaders,
            customBodyParams: customBodyParams
        )
    }
    
    func connect(backendURL: String, dailyApiKey:String) {
        if(dailyApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
            self.showError(message: "Need to fill the Daily API Key. For more info visit: https://bots.daily.co")
            return
        }
        
        let baseUrl = backendURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if(baseUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
            self.showError(message: "Need to fill the backendURL. For more info visit: https://bots.daily.co")
            return
        }
        
        let currentSettings = SettingsManager.getSettings()
        self.rtviClientIOS = DailyVoiceClient.init(baseUrl: baseUrl, options: createOptions(dailyApiKey: dailyApiKey, enableMic: currentSettings.enableMic))
        self.rtviClientIOS?.delegate = self
        self.rtviClientIOS?.start() { result in
            if case .failure(let error) = result {
                self.showError(message: error.localizedDescription)
                self.rtviClientIOS = nil
            }
        }
        // Selecting the mic based on the preferences
        if let selectedMic = currentSettings.selectedMic {
            self.rtviClientIOS?.updateMic(micId: MediaDeviceId(id:selectedMic), completion: nil)
        }
        self.saveCredentials(dailyApiKey: dailyApiKey, backendURL: baseUrl)
    }
    
    func disconnect() {
        self.rtviClientIOS?.disconnect(completion: nil)
    }
    
    func showError(message: String) {
        self.toastMessage = message
        self.showToast = true
        // Hide the toast after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showToast = false
            self.toastMessage = nil
        }
    }
    
    func toggleMicInput() {
        self.rtviClientIOS?.enableMic(enable: !self.isMicEnabled) { result in
            switch result {
            case .success():
                self.isMicEnabled = self.rtviClientIOS?.isMicEnabled ?? false
            case .failure(let error):
                self.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func startTimer() {
        self.meetingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                self.timerCount += 1
            }
        }
    }
    
    private func stopTimer() {
        self.meetingTimer?.invalidate()
        self.meetingTimer = nil
        self.timerCount = 0
    }
    
    func saveCredentials(dailyApiKey: String, backendURL: String) {
        var currentSettings = SettingsManager.getSettings()
        currentSettings.backendURL = backendURL
        currentSettings.dailyApiKey = dailyApiKey
        // Saving the settings
        SettingsManager.updateSettings(settings: currentSettings)
    }
    
}

extension CallContainerModel:VoiceClientDelegate, LLMHelperDelegate {
    
    private func handleEvent(eventName: String, eventValue: Any? = nil) {
        if let value = eventValue {
            print("RTVI Demo, received event:\(eventName), value:\(value)")
        } else {
            print("RTVI Demo, received event: \(eventName)")
        }
    }
    
    func onTransportStateChanged(state: TransportState) {
        self.handleEvent(eventName: "onTransportStateChanged", eventValue: state)
        self.voiceClientStatus = state.description
        self.isInCall = ( state == .connecting || state == .connected || state == .ready || state == .handshaking )
    }
    
    func onBotReady(botReadyData: BotReadyData) {
        self.handleEvent(eventName: "onBotReady")
        self.isBotReady = true
        self.startTimer()
    }
    
    func onConnected() {
        self.isMicEnabled = self.rtviClientIOS?.isMicEnabled ?? false
    }
    
    func onDisconnected() {
        self.stopTimer()
        self.isBotReady = false
    }
    
    func onRemoteAudioLevel(level: Float, participant: Participant) {
        self.remoteAudioLevel = level
    }
    
    func onUserAudioLevel(level: Float) {
        self.localAudioLevel = level
    }
    
    func onUserTranscript(data: Transcript) {
        if (data.final ?? false) {
            self.handleEvent(eventName: "onUserTranscript", eventValue: data.text)
        }
    }
    
    func onBotTranscript(data: String) {
        self.handleEvent(eventName: "onBotTranscript", eventValue: data)
    }
    
    func onError(message: String) {
        self.handleEvent(eventName: "onError", eventValue: message)
        self.showError(message: message)
    }
    
}
