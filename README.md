# DrawKit
A lightweight SwiftUI image markup editor for macOS.

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
