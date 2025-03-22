//
//  MistralPhotoView.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 12/01/2025.
//
import SwiftUI
import PhotosUI

struct MistralPhotoView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var apiResponse: [String: Any]?
    @State private var navigateToEntries = false
    
    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Select receipt or transaction image")
                }
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            sendRequest(with: image)
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToEntries) {
                    if let response = apiResponse {
                        AIReceiptEntriesView(responseJSON: response)
                    } else {
                        Text("No data available")
                    }
                }
            }
            .navigationTitle("Document Recognition")
        }
    }
    
    func sendRequest(with image: UIImage) {
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.9)?.base64EncodedString() else {
            print("Failed to encode image")
            return
        }
        
        // Construct the request body
        let requestBody: [String: Any] = [
            "model": "pixtral-12b-2409",
            "messages": [
                [
                    "role": "system",
                    "content": [
                        [
                            "type": "text",
                            "text": """
                                Extract the text elements described by the user from the picture, and return the result formatted as a json in the following format: {name_of_element : [value]}
                                """
                        ]
                    ]
                ],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": Constants.photoScanPrompt],
                        ["type": "image_url", "image_url": "data:image/jpeg;base64,\(imageData)"]
                    ]
                ]
            ],
            "response_format": ["type": "json_object"]
        ]
        
        if let request = Utils.createMistralAPIRequest(requestBody: requestBody) {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Request failed: \(error)")
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                else {
                    print("Invalid response")
                    return
                }
                
                print("Response JSON: \(json)")
                
                DispatchQueue.main.async {
                    apiResponse = json
                    navigateToEntries = true
                }
            }
            task.resume()
        } else {
            print("Failed to create API request")
        }
    }
}

#Preview {
    MistralPhotoView()
}
