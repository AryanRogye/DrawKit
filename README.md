# DrawKit

DrawKit is an embeddable SwiftUI image editor package for iOS and macOS. Add its editor canvas and controls directly to your own app to provide freehand drawing, editable shapes, selection tools, zooming, and composited image export without building a markup editor from scratch.

<img width="604" height="392.5" alt="DrawKit image markup editor" src="https://github.com/user-attachments/assets/0e9a0dcf-f908-473d-9418-db87d2a4f2ca" />

## Features

- Embed the editor in any SwiftUI view and arrange it to fit your app's interface.
- Keep editor state in a reusable `DrawEditor` instance owned by your app.
- Draw independent freehand pen strokes with configurable colors and thicknesses.
- Add, move, and resize rectangles, circles, and triangles.
- Select strokes using their visible path instead of their transparent canvas bounds.
- Edit item opacity and rectangle corner radius in the inspector.
- Pan and zoom while keeping drawing input aligned with the pointer.
- Preserve markup positions when the canvas changes size.
- Export the image and its markup as a `UIImage` on iOS or an `NSImage` on macOS.

## Requirements

- iOS 18 or later
- macOS 15 or later
- Swift 6.4 or later
- Xcode with Swift 6.4 support

## Installation

Add DrawKit to your project with Swift Package Manager:

1. In Xcode, choose **File → Add Package Dependencies**.
2. Enter `https://github.com/AryanRogye/DrawKit.git`.
3. Select the `main` branch and add the `DrawKit` product to your target.

You can also add it to `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/AryanRogye/DrawKit.git",
        branch: "main"
    )
]
```

Then add `DrawKit` to the dependencies of your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "DrawKit", package: "DrawKit")
    ]
)
```

## Usage

DrawKit does not provide a standalone app or force a particular editor layout. Its canvas and controls are regular SwiftUI views that you can embed anywhere in your own screen, window, sheet, navigation flow, or custom interface.

Create one `DrawEditor` for the image being edited, then pass that shared editor to `DrawCanvas` and `DrawCanvasControls`. Your app owns the surrounding layout, image import, save destination, and presentation behavior.

```swift
import DrawKit
import SwiftUI

struct MarkupEditorView: View {
    @State private var editor: DrawEditor
    @State private var shouldSave = false

    init(image: SystemImage) {
        _editor = State(initialValue: DrawEditor(image: image))
    }

    var body: some View {
        VStack(spacing: 12) {
            DrawCanvas(editor: editor, save: $shouldSave) { renderedImage in
                guard let renderedImage else { return }
                save(renderedImage)
            }

            DrawCanvasControls(editor: editor)

            Button("Save Image") {
                shouldSave = true
            }
        }
    }

    private func save(_ image: SystemImage) {
        // Persist or share the rendered UIImage/NSImage here.
    }
}
```

`DrawCanvasControls` includes the pen, shape, color, and stroke-thickness controls. Selecting an item on the canvas opens the built-in inspector, where supported appearance and geometry properties can be edited or the item can be deleted.

If you do not need export handling, use the simpler canvas initializer:

```swift
DrawCanvas(editor: editor)
```

## Exporting

Set the `save` binding to `true` to request a composited image. DrawKit renders the source image and markup at the source image size, passes the result to `onSave`, and resets the binding when the operation finishes.

```swift
DrawCanvas(editor: editor, save: $shouldSave) { image in
    guard let image else {
        // Handle a rendering failure.
        return
    }

    // Persist or share the UIImage/NSImage.
}
```

See `iOSDrawKitExample` for an iOS example using `PhotosPicker`, or `DrawKitExample` for a macOS example that imports an image with `fileImporter` and saves the rendered result as PNG.

## License

No license has been added to this repository yet.
