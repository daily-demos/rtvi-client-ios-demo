import SwiftUI

import RTVIClientIOSDaily
import RTVIClientIOS

@MainActor
class CallContainerModel: ObservableObject {
    
    // Note: In a production environment, it is recommended to avoid calling Daily's API endpoint directly.
    // Instead, you should route requests through your own server to handle authentication, validation,
    // and any other necessary logic. Therefore, the baseUrl should be set to the URL of your own server.
    @Published var backendURL: String = UserDefaults.standard.string(forKey: "backendURL") ?? "https://api.daily.co/v1/bots/start"
    @Published var dailyApiKey: String = UserDefaults.standard.string(forKey: "dailyApiKey") ?? ""
    
    @Published var voiceClientStatus: String = TransportState.idle.description
    @Published var isInCall: Bool = false
    @Published var isConnected: Bool = false
    @Published var timerCount = 0
    
    @Published var isMicEnabled: Bool = true
    
    @Published var toastMessage: String? = nil
    @Published var showToast: Bool = false
    
    @Published
    var remoteAudioLevel: Float = 0
    @Published
    var localAudioLevel: Float = 0
    
    private var meetingTimer: Timer?
    
    private var rtviClientIOS: VoiceClient?
    
    init() {
        // Changing the log level
        RTVIClientIOS.setLogLevel(.warn)
    }
    
    private func createOptions() -> VoiceClientOptions {
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
        
        let customHeaders = [["Authorization": "Bearer \(self.dailyApiKey)"]]
        return VoiceClientOptions.init(
            services: ["llm": "together", "tts": "cartesia"],
            config: clientConfigOptions,
            customHeaders: customHeaders
        )
    }
    
    func connect() {
        if(self.dailyApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
            self.showError(message: "Need to fill the Daily API Key. For more info visit: https://bots.daily.co")
            return
        }
        
        let baseUrl = self.backendURL.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rtviClientIOS = DailyVoiceClient.init(baseUrl: baseUrl, options: createOptions())
        self.rtviClientIOS?.delegate = self
        self.rtviClientIOS?.start() { result in
            if case .failure(let error) = result {
                self.showError(message: error.localizedDescription)
                self.rtviClientIOS = nil
            }
        }
        self.saveCredentials()
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
    
    func saveCredentials() {
        UserDefaults.standard.set(self.backendURL, forKey: "backendURL")
        UserDefaults.standard.set(self.dailyApiKey, forKey: "dailyApiKey")
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
        self.isConnected = ( state == .ready )
    }
    
    func onBotReady(botReadyData: BotReadyData) {
        self.handleEvent(eventName: "onBotReady")
        self.startTimer()
    }
    
    func onConnected() {
        self.isMicEnabled = self.rtviClientIOS?.isMicEnabled ?? false
    }
    
    func onDisconnected() {
        self.stopTimer()
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
