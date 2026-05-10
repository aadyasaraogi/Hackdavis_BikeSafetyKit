import SwiftUI

struct ContentView: View {

    @State private var aiStatus: String = "SAFE"
    @State private var bleStatus: String = "Connected"
    @State private var currentFrame: UIImage? = nil

    private let skyBlue = Color(red: 0.45, green: 0.75, blue: 1.0)
    private let softGray = Color.white.opacity(0.08)

    var body: some View {

        VStack(spacing: 0) {

            // HEADER
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "bicycle")
                        .foregroundStyle(skyBlue)

                    Text("Got Your Back")
                        .font(.headline.bold())

                    Spacer()
                }

                Text("Rear safety awareness system")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding()
            .background(.ultraThinMaterial)

            // CAMERA
            ZStack {
                CameraView()
                if currentFrame == nil {
                    Color.black.opacity(0.2)
                }
            }
            .frame(maxHeight: .infinity)

            // STATUS PANEL
            VStack(spacing: 12) {

                HStack {
                    Text("AI")
                    Spacer()
                    Text(aiStatus)
                        .foregroundStyle(color(aiStatus))
                        .bold()
                }

                HStack {
                    Text("BLE")
                    Spacer()
                    Text(bleStatus)
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .background(softGray)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupBindings()
            CameraManager.shared.start()
        }
    }

    private func setupBindings() {

        CameraManager.shared.onFrame = { image in
            self.currentFrame = image
        }

        CameraManager.shared.onAIResult = { result in

            if result.contains("CAR") {
                aiStatus = "CAR"
            } else if result.contains("DANGER") {
                aiStatus = "DANGER"
            } else {
                aiStatus = "SAFE"
            }
        }
    }

    private func color(_ status: String) -> Color {
        switch status {
        case "CAR": return .orange
        case "DANGER": return .red
        default: return skyBlue
        }
    }
}
