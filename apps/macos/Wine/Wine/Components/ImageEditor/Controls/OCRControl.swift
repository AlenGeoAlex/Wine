//
//  OCRControl.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI
import Vision

struct OCRControl: View {
    @State var sharedEditorOptions: SharedImageEditorViewModel;
    @State var ocrControlView: OCRControlViewModel = OCRControlViewModel();
    
    var body: some View {
        VStack {
            Text("Image OCR")
                .font(.title)

            if self.ocrControlView.status == .creating {
                ProgressView()
            }else if self.ocrControlView.status == .error{
                
            }else{
                TextEditor(text: self.$ocrControlView.recognizedText)
                    .padding(20)
                    
            }
            
            Button {
                
            } label: {
                Image(systemName: "document.on.clipboard")
                Text("Copy to clipboard")
                   
            }
            .background(Color.blue)
        }.task {
            self.performOCR()
        }
    }
    
    func performOCR() {
        self.ocrControlView.status = .creating;
        let url = self.sharedEditorOptions.capture.filePath

        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            print("Failed to create image source.")
            return
        }

        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            print("Failed to create CGImage.")
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        let recognizeRequest = VNRecognizeTextRequest { (request, error) in
            
            // Parse the results as text
            guard let result = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            // Extract the data
            let stringArray = result.compactMap { result in
                result.topCandidates(1).first?.string
            }
            
            // Update the UI
            DispatchQueue.main.async {
                self.ocrControlView.recognizedText = stringArray.joined(separator: "\n")
                self.ocrControlView.status = .ready
            }
        }
        
        recognizeRequest.recognitionLevel = .accurate
        do {
            try handler.perform([recognizeRequest])
        } catch {
            print(error)
        }
    }
}

@Observable class OCRControlViewModel {
    var recognizedText: String = "";
    var status: OCRStatus = .creating;
    
}

enum OCRStatus {
    case creating
    case ready
    case error
}

#Preview {
    OCRControl(sharedEditorOptions: SharedImageEditorViewModel.preview())
}
