//
//  ContentView.swift
//  DrawKitExample
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI
import DrawKit
import UniformTypeIdentifiers

struct ContentView: View {
    
    @State private var isPresented: Bool = false
    @State private var error: String?
    @State private var showError: Bool = false
    
    @State private var drawEditorControls: DrawEditor?
    @AppStorage("BookmarkedImage") var bookmarkedImage: Data?
    
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
                    let panel = NSSavePanel()
                    panel.allowedContentTypes = [.png]
                    panel.nameFieldStringValue = "Untitled.png"
                    panel.canCreateDirectories = true
                    panel.title = "Save Image"
                    
                    // beginSheetModal(for:) is better if you have a window to attach to
                    panel.begin { response in
                        guard response == .OK, let url = panel.url else { return }
                        do {
                            guard let tiff = image.tiffRepresentation,
                                  let bitmap = NSBitmapImageRep(data: tiff),
                                  let data = bitmap.representation(using: .png, properties: [:]) else {
                                throw CocoaError(.fileWriteUnknown)
                            }
                            try data.write(to: url)
                        } catch {
                            self.error = "Error Saving: \(error.localizedDescription)"
                            self.showError = true
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
                Button("Open Image") {
                    drawEditorControls = nil
                    isPresented = true
                }
            }
        }
        .task {
            if let bookmarkedImage {
                
                var isStale = false
                
                do {
                    let url = try URL(
                        resolvingBookmarkData: bookmarkedImage,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale
                    )
                    if isStale {
                        self.bookmarkedImage = try url.bookmarkData(
                            options: .withSecurityScope,
                            includingResourceValuesForKeys: nil,
                            relativeTo: nil
                        )
                    }
                    guard url.startAccessingSecurityScopedResource() else {
                        self.error = "Cannot access saved image"
                        self.showError = true
                        self.bookmarkedImage = nil
                        return
                    }
                    
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }

                    if let image = NSImage(contentsOf: url) {
                        self.drawEditorControls = .init(image: image)
                    }
                } catch {
                    self.error = "Error Loading Saved Image"
                    self.showError = true
                    self.bookmarkedImage = nil
                }
            }
        }
        .fileImporter(isPresented: $isPresented, allowedContentTypes: [.image]) { result in
            switch result {
            case .success(let url):
                
                guard url.startAccessingSecurityScopedResource() else {
                    self.error = "Cannot access file (permission denied)"
                    self.showError = true
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                do {
                    bookmarkedImage = try url.bookmarkData(
                        options: .withSecurityScope,
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil
                    )
                } catch {
                    self.error = "Error Saving Image: \(error.localizedDescription)"
                    self.showError = true
                }
                
                if let image = NSImage(contentsOf: url) {
                    drawEditorControls = .init(image: image)
                } else {
                    self.error = "Cannot convert the selected file to an image."
                    self.showError = true
                }
            case .failure(let failure):
                self.error = "Error Importing Image: \(failure)"
                self.showError = true
            }
        }
    }
}

#Preview {
    ContentView()
}
