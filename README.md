# DrawKit
A lightweight SwiftUI image markup editor for macOS.

<img width="604" height="392.5" alt="Screenshot 2026-08-13 at 2 39 44 AM" src="https://github.com/user-attachments/assets/0e9a0dcf-f908-473d-9418-db87d2a4f2ca" />


```swift
import DrawKit

@State private var editor: DrawEditor?

if let editor {
    DrawCanvas(editor: editor, save: $save) { image in
        ...
    }

    DrawCanvasControls(editor: editor)
}
```
