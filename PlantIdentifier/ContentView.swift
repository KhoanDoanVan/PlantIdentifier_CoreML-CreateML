//
//  ContentView.swift
//  PlantIdentifier
//
//  Created by Đoàn Văn Khoan on 26/11/24.
//

import SwiftUI
import CoreML
import Vision
import PhotosUI

struct ContentView: View {
    
    @State private var isScan: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .navigationTitle("Plant Identifier")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isScan = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(.blue)
                            .cornerRadius(20)
                    }
                }
            }
            .sheet(isPresented: $isScan) {
                ScanView()
            }
        }
    }
}

struct ScanView: View {
    
    @State private var imageSelected: PhotosPickerItem?
    @State private var uiImageSelected: UIImage?
    
    @State private var result: String = "No Prediction Yet"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    
                    if let uiImage = uiImageSelected {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                    }
                    
                    PhotosPicker(
                        selection: $imageSelected,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("Choose Image")
                    }
                    
                }
                
                Text(result)
                    .font(.title2)
                    .foregroundStyle(.red)
                    .bold()
                
                Button {
                    classifyImage()
                } label: {
                    Text("Let's Prediction")
                }
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: imageSelected) {
                Task {
                    if let data = try? await imageSelected?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data)
                    {
                        uiImageSelected = image
                    } else {
                        print("Failed Picker Image")
                    }
                }
            }
        }
    }
    
    func classifyImage() {
        guard uiImageSelected != nil else {
            result = "Please select image first"
            return
        }
        
        /// Convert image to CGImage
        guard let cgImage = uiImageSelected?.cgImage else {
            result = "Failed to process the image"
            return
        }
        
        do {
            let config = MLModelConfiguration()
            let model = try PlantIdentifier(configuration: config)
            
            let coreModel = try VNCoreMLModel(for: model.model)
            
            /// Create a Vision request
            let request = VNCoreMLRequest(model: coreModel) { request, _ in
                if let results = request.results as? [VNClassificationObservation],
                   let topResult = results.first {
                    DispatchQueue.main.async {
                        self.result = "\(topResult.identifier) (\(Int(topResult.confidence * 100))%)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.result = "No classification results found"
                    }
                }
            }
            
            /// Perform the request
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
        } catch {
            result = "Error classify \(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
