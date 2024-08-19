import SwiftUI

struct MicrophoneView: View {
    var audioLevel: Float // Current audio level
    var isMuted: Bool // Muted state

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        // Outer gray border
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.8)

                        // Gray middle
                        Circle()
                            .fill(isMuted ? Color.disabledMic : Color.backgroundCircle)
                            .frame(width: geometry.size.width * 0.82, height: geometry.size.width * 0.70)

                        // Green circle expanding based on audio level
                        if !isMuted {
                            Circle()
                                .fill(Color.micVolume)
                                .opacity(0.5)
                                .frame(width: CGFloat(audioLevel) * (geometry.size.width * 0.95),
                                       height: CGFloat(audioLevel) * (geometry.size.height * 0.95))
                                .animation(.easeInOut(duration: 0.2), value: audioLevel)
                        }

                        // Microphone icon in the center
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    MicrophoneView(audioLevel: 0.5, isMuted: true)
}
