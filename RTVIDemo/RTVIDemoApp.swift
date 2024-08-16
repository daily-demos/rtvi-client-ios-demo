import SwiftUI

import RTVIClientIOSDaily
import RTVIClientIOS

@MainActor
class CallContainerModel: ObservableObject {

    @Published var backendURL: String
    @Published var voiceClientStatus: String = TransportState.idle.description
    @Published var isInCall: Bool = false
    
    @Published var toastMessage: String? = nil
    @Published var showToast: Bool = false
    
    public var rtviClientIOS: VoiceClient

    init() {
        // Changing the log level
        RTVIClientIOS.setLogLevel(.warn)

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
        let options = VoiceClientOptions.init(
            services: ["llm": "together", "tts": "cartesia"],
            config: clientConfigOptions
        )

        let defaultBackendURL = "http://192.168.1.23:7860/"
        self.backendURL = defaultBackendURL

        self.rtviClientIOS = DailyVoiceClient.init(baseUrl: defaultBackendURL, options: options)
        self.rtviClientIOS.delegate = self
        self.rtviClientIOS.initDevices(completion: nil)
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
    }

    func onUserStartedSpeaking() {
        self.handleEvent(eventName: "onUserStartedSpeaking")
    }

    func onUserStoppedSpeaking() {
        self.handleEvent(eventName: "onUserStoppedSpeaking")
    }

    func onBotStartedSpeaking(participant: Participant) {
        self.handleEvent(eventName: "onBotStartedSpeaking")
    }

    func onBotStoppedSpeaking(participant: Participant) {
        self.handleEvent(eventName: "onBotStoppedSpeaking")
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


@main
struct RTVIDemoApp: App {

    @StateObject var callContainerModel = CallContainerModel()

    var body: some Scene {
        WindowGroup {
            if (!callContainerModel.isInCall) {
                ContentView().environmentObject(callContainerModel)
            } else {
                RTVISessionView().environmentObject(callContainerModel)
            }
        }
    }

}
