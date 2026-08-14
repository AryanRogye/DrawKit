//
//  ContentView.swift
//  iOSDrawKitExample
//
//  Created by Aryan Rogye on 8/13/26.
//

import SwiftUI
import DrawKit
import PhotosUI

struct ContentView: View {
    
    @State private var isPresented: Bool = false
    @State private var error: String?
    @State private var showError: Bool = false
    
    @State private var drawEditorControls: DrawEditor?
    @State private var selectedPhoto: PhotosPickerItem?
    
    
    @State private var save: Bool = false
    
    var body: some View {
        VStack {
            if let drawEditorControls {
                DrawCanvas(editor: drawEditorControls, save: $save) { image in
                    guard let image else {
                        self.error = "No image to save."
                        self.showError = true
                        return
                    }
                    
                    PHPhotoLibrary.shared().performChanges {
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    } completionHandler: { success, error in
                        Task { @MainActor in
                            if let error {
                                self.error = "Error Saving Image: \(error.localizedDescription)"
                                self.showError = true
                            } else if !success {
                                self.error = "Could not save the image."
                                self.showError = true
                            }
                        }
                    }
                }
                DrawCanvasControls(editor: drawEditorControls)
            }
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text("\(error, default: "Unknown Error")")
            )
        }
        .toolbar {
            if drawEditorControls != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save Image") {
                        save = true
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images
                ) {
                    Label("Choose Photo", systemImage: "photo")
                }
                .onChange(of: selectedPhoto) { _, newItem in
                    guard let newItem else { return }
                    
                    Task {
                        do {
                            guard let data = try await newItem.loadTransferable(type: Data.self),
                                  let image = UIImage(data: data) else {
                                self.error = "Cannot convert the selected photo to an image."
                                self.showError = true
                                return
                            }
                            
                            drawEditorControls = .init(image: image)
                        } catch {
                            self.error = "Error Importing Image: \(error.localizedDescription)"
                            self.showError = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
