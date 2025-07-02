//
//  OpenAIService.swift
//  AltTextGenerator
//
//  Created by Gary Riches on 01/07/2025.
//

import Foundation
import UIKit

class OpenAIService {
    static let shared = OpenAIService()
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    struct OpenAIRequest: Codable {
        let model: String
        let messages: [Message]
        let maxTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case model
            case messages
            case maxTokens = "max_tokens"
        }
    }
    
    struct Message: Codable {
        let role: String
        let content: [Content]
    }
    
    struct Content: Codable {
        let type: String
        let text: String?
        let imageUrl: ImageURL?
        
        enum CodingKeys: String, CodingKey {
            case type
            case text
            case imageUrl = "image_url"
        }
    }
    
    struct ImageURL: Codable {
        let url: String
    }
    
    struct OpenAIResponse: Codable {
        let choices: [Choice]
    }
    
    struct Choice: Codable {
        let message: ResponseMessage
    }
    
    struct ResponseMessage: Codable {
        let content: String
    }
    
    func generateAltText(for image: UIImage, detailLevel: AltTextDetailLevel = .normally, focusLevel: AltTextFocusLevel = .wholeScreen) async throws -> String {
        guard let apiKey = KeychainService.shared.retrieve(), !apiKey.isEmpty else {
            throw NSError(domain: "OpenAIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key not found"])
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "OpenAIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let (prompt, maxTokens) = getPromptAndTokens(for: detailLevel, focusLevel: focusLevel)
        
        let request = OpenAIRequest(
            model: "gpt-4o",
            messages: [
                Message(
                    role: "user",
                    content: [
                        Content(
                            type: "text",
                            text: prompt,
                            imageUrl: nil
                        ),
                        Content(
                            type: "image_url",
                            text: nil,
                            imageUrl: ImageURL(url: "data:image/jpeg;base64,\(base64Image)")
                        )
                    ]
                )
            ],
            maxTokens: maxTokens
        )
        
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "OpenAIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "API request failed"])
        }
        
        let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let altText = decodedResponse.choices.first?.message.content else {
            throw NSError(domain: "OpenAIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "No response from API"])
        }
        
        return altText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func getPromptAndTokens(for detailLevel: AltTextDetailLevel, focusLevel: AltTextFocusLevel) -> (prompt: String, maxTokens: Int) {
        let focusInstruction = getFocusInstruction(for: focusLevel)
        
        switch detailLevel {
        case .quickly:
            return (
                prompt: "Generate a brief alt text for this image. Provide a concise description focusing only on the main subject. Maximum 1-2 sentences. \(focusInstruction)",
                maxTokens: 75
            )
        case .normally:
            return (
                prompt: "Generate a concise and descriptive alt text for this image. The alt text should be suitable for accessibility purposes and describe the main content of the image in a clear, informative way. \(focusInstruction)",
                maxTokens: 150
            )
        case .fully:
            return (
                prompt: "Generate a detailed and comprehensive alt text for this image. Include all important elements, their relationships, colors, emotions, and context. Provide a thorough description suitable for someone who cannot see the image. \(focusInstruction)",
                maxTokens: 300
            )
        }
    }
    
    private func getFocusInstruction(for focusLevel: AltTextFocusLevel) -> String {
        switch focusLevel {
        case .wholeScreen:
            return "Describe the entire image, including background elements, overall composition, and spatial relationships."
        case .largeImages:
            return "Focus primarily on the most prominent, large, or important visual elements. Give less attention to small details or background elements."
        }
    }
}