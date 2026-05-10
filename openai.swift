import Foundation
import UIKit

final class OpenAIService {

    static let shared = OpenAIService()

    private let apiKey = ""
    func analyze(frame: UIImage, completion: @escaping (String) -> Void) {

        guard let imageData = frame.jpegData(compressionQuality: 0.6) else {
            completion("INVALID_IMAGE")
            return
        }

        let base64 = imageData.base64EncodedString()

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": """
        You are a real-time cyclist safety AI inside a bike computer.

        Your job is NOT to describe images.

        Your job is to detect immediate safety risk.

        Prioritize in this order:
        1. Cars or vehicles near cyclist = CAR
        2. Anything potentially dangerous = DANGER
        3. Pedestrians in path = PEDESTRIAN
        4. No relevant threat = SAFE

        Rules:
        - You MUST choose exactly one word.
        - NEVER say UNKNOWN.
        - If uncertain, choose DANGER.
        - Be decisive like a safety system in a real vehicle.
        """
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this frame for cyclist safety."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 10
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
              let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion("REQUEST_BUILD_ERROR")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in

            // 🧠 STEP 1: PRINT REAL ERROR
            if let error = error {
                print("❌ NETWORK ERROR:", error)
                completion("NETWORK_ERROR")
                return
            }

            guard let data = data else {
                completion("NO_DATA")
                return
            }

            // 🧠 STEP 2: PRINT RAW RESPONSE (THIS IS KEY)
            let raw = String(data: data, encoding: .utf8) ?? "nil"
            print("🧾 RAW RESPONSE:\n", raw)

            // 🧠 STEP 3: PARSE SAFELY
            guard
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let choices = json["choices"] as? [[String: Any]],
                let message = choices.first?["message"] as? [String: Any],
                let content = message["content"] as? String
            else {
                completion("PARSE_ERROR")
                return
            }

            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))

        }.resume()
    }
}
