//
//  PhotoAnalysisView.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 13/09/2024.
//

import SwiftUI
import PhotosUI
import Vision
import RandomColor
import RealmSwift


struct PhotoAnalysisView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var r: R?
    @State private var recognizedTexts: [String] = [] // Store recognized texts
    @State private var showBubbles: Bool = false // Control navigation to the bubble view
    
    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Import Photo")
                        .padding()
                }
                .onChange(of: selectedItem) {
                    Task {
                        // Retrieve selected asset in the form of Data
                        if let selectedItem = selectedItem {
                            if let data = try? await selectedItem.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                image = uiImage
                                analyzeImage(uiImage)
                            }
                        }
                    }
                }
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
                
                NavigationLink(value: recognizedTexts) {
                    Text("Show Recognized Text")
                }
                .navigationDestination(for: [String].self) { texts in
                    RecognizedTextBubbleView(recognizedTexts: texts)
                }
            }
            .navigationTitle("Photo Analysis")
        }
    }
    
    func analyzeImage(_ image: UIImage) {
        let request = VNRecognizeTextRequest { request, error in
            if let results = request.results as? [VNRecognizedTextObservation] {
                if results.isEmpty {
                    print("No text found in the image.")
                    return
                }
                
                var texts: [String] = []
                for observation in results {
                    let allCandidates = observation.topCandidates(1)
                    let regex = "^[a-zA-Z0-9,\\.\\s]+$"
                    for candidate in allCandidates {
                        let candidateString = candidate.string
                        
                        // Check if the candidate matches the allowed regex pattern
                        if candidateString.range(of: regex, options: .regularExpression) != nil {
                            texts.append(candidateString.lowercased())
                        }
                    }                }
                recognizedTexts = texts // Save recognized text for the next view
                showBubbles = true // Trigger navigation to bubble view
                
            } else if let error = error {
                print("Error recognizing text: \(error.localizedDescription)")
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
        try? handler.perform([request])
    }
    
    func parseReceiptText(_ text: String) -> R? {
        // Implement your logic to parse text and extract receipt data
        return R(date: "2024-09-13", receiptNumber: "12345", items: [ReceiptItem(name: "Item 1", amount: 10.0)])
    }
}

struct R {
    let date: String
    let receiptNumber: String
    let items: [RI]
}

struct RI: Hashable {
    let name: String
    let amount: Double
}

struct RecognizedTextBubbleView: View {
    let recognizedTexts: [String]
    let pairColors: [UIColor]
    
    init(recognizedTexts: [String]) {
        self.recognizedTexts = recognizedTexts
        self.pairColors = randomColors(count: recognizedTexts.count / 2, hue: .blue, luminosity : .light)
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedFirst: String? = nil
    @State private var selectedSecond: String? = nil
    @State private var pairs: [(String, String)] = [] // Store pairs of selected bubbles
    @State var buttonOffsets: [String: CGSize] = [:]
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all) // Full white background
            
            
            VStack {
                // Display recognized text in bubbles
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(recognizedTexts, id: \.self) { text in
                        Button(action: {
                            handleBubbleSelection(text)
                        }) {
                            Text(text)
                                .font(.system(size: 11))  // Adjust font size to be smaller
                                .foregroundColor(.white)  // Set text color
                                .padding(.horizontal, 10) // Adjust padding for text fitting
                                .padding(.vertical, 6)
                                .background(Color(UIColor.lightGray))
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(borderColor(for: text)), lineWidth: 3)
                                )
                                .textCase(nil) // Remove capitalization
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .offset(buttonOffsets[text] ?? .zero)
                        .onAppear {
                            let randomOffset = CGSize(width: CGFloat.random(in: -20...20), height: CGFloat.random(in: -5...5))
                            buttonOffsets[text] = randomOffset // Store random offset
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                // Confirm button
                Button(action: {
                    // Handle confirmation action
                    confirmSelections()
                }) {
                    Text("Confirm Selections")
                        .font(.system(size: 14)) // Adjust the font size to be smaller
                        .padding(.horizontal, 10)  // Reduce horizontal padding
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    // Method to handle bubble selection logic
    private func handleBubbleSelection(_ text: String) {
        if selectedFirst == nil {
            selectedFirst = text
        } else if selectedSecond == nil {
            selectedSecond = text
            if let first = selectedFirst, let second = selectedSecond {
                pairs.append((first, second)) // Save the pair
                selectedFirst = nil // Reset for new selection
                selectedSecond = nil
            }
        }
    }
    
    // Method to handle confirmation
    private func confirmSelections() {
        print("Confirmed pairs: \(pairs)")
        // Add logic to handle the confirmed pairs (e.g., save to an array)
        let today = Date()
        let category = "Miscellaneous"
        do {
            let realm = try Realm()
            try realm.write {
                for (name, price) in pairs {
                     let expense = Expense()
                     expense.expenseName = name
                     expense.date = today
                     expense.categoryString = category
                     expense.amount = Double(price) ?? 0.0
                     
                     realm.add(expense) // Save to Realm
                     print("Added expense: \(expense)")
                 }
            }
            presentationMode.wrappedValue.dismiss()
            pairs.removeAll()
        } catch {
            print("Error saving expense: \(error)")
        }
    }

    // Method to get border color
    private func borderColor(for text: String) -> UIColor {
        if text == selectedFirst || text == selectedSecond {
            return .systemPink // Highlight the selected bubble
        }
        if let pairIndex = pairs.firstIndex(where: { $0.0 == text || $0.1 == text }) {
            print("Index of text: \(text) : \(pairIndex)")
            // Assign a color based on the pair's index
            let color = pairColors[pairIndex]
            return color
        } else {
            return .clear
        }
    }
}
