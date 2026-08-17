//
//  DrawEditor+Undo.swift
//  DrawKit
//
//  Created by OpenAI on 8/15/26.
//

import CoreGraphics
import Foundation

// MARK: - Public API's
extension DrawEditor {
    /// Restores the canvas to its state before the most recent edit.
    ///
    /// Calling this method when no undo history is available has no effect.
    public func undo() {
        commitHistoryTransaction()

        guard let snapshot = history.undoSnapshots.popLast() else { return }
        history.redoSnapshots.append(items)
        items = snapshot
        resetTransientGestureState()
        reconcileSelection()
    }

    /// Reapplies the most recently undone canvas edit.
    ///
    /// Calling this method when no redo history is available has no effect.
    public func redo() {
        commitHistoryTransaction()
        
        guard let snapshot = history.redoSnapshots.popLast() else { return }
        history.undoSnapshots.append(items)
        trimUndoHistoryIfNeeded()
        items = snapshot
        resetTransientGestureState()
        reconcileSelection()
    }
}

// MARK: - Multi Transaction Avoidance
extension DrawEditor {
    /// the whole point of this is that say for example we're changing a slider
    /// a slider will go 0.1, 0.2, 0.3, 0.4
    /// we dont want to store all changes like this, instead what we want is
    /// we want to begin transaction before the 0.1, and commit after 0.4
    func beginHistoryTransaction() {
        guard history.transactionStart == nil else { return }
        history.transactionStart = items
    }
    
    func commitHistoryTransaction() {
        guard let transactionStart = history.transactionStart else { return }
        history.transactionStart = nil
        recordHistoryIfChanged(from: transactionStart)
    }
}

extension DrawEditor {
    func performHistoryMutation(_ mutation: () -> Void) {
        if history.transactionStart != nil {
            mutation()
            return
        }
        
        let previousItems = items
        mutation()
        recordHistoryIfChanged(from: previousItems)
    }
    
    /// this is used in case the canvas size changes, this is cuz when canvas size changes
    /// the positions and sizes change, this will replace all history for these items
    func remapHistory(from oldImageRect: CGRect, to newImageRect: CGRect) {
        history.undoSnapshots = history.undoSnapshots.map {
            $0.mapped(from: oldImageRect, to: newImageRect)
        }
        history.redoSnapshots = history.redoSnapshots.map {
            $0.mapped(from: oldImageRect, to: newImageRect)
        }
        history.transactionStart = history.transactionStart?.mapped(
            from: oldImageRect,
            to: newImageRect
        )
    }
    
    private func reconcileSelection() {
        guard let selection = canvasSelected else { return }
        
        guard let index = items.firstIndex(where: {
            $0.id == .markup(selection.id)
        }) else {
            canvasSelected = nil
            return
        }
        
        canvasSelected = CanvasSelection(index: index, id: selection.id)
    }
    
}

// MARK: - Private APIs
extension DrawEditor {
    /// make sure that items actually changed if they did change add to
    /// undo history
    private func recordHistoryIfChanged(from previousItems: [MarkupItems]) {
        guard previousItems != items else { return }
        
        // add to undo history
        history.undoSnapshots.append(previousItems)
        trimUndoHistoryIfNeeded()
        // since we updated undo we can remove anything inside redo
        history.redoSnapshots.removeAll(keepingCapacity: true)
    }
    
    private func trimUndoHistoryIfNeeded() {
        let overflow = history.undoSnapshots.count - history.limit
        guard overflow > 0 else { return }
        history.undoSnapshots.removeFirst(overflow)
    }
    
    /// When we Undo or Redo something on the canvas will get changed
    /// this sets it so that any drag interaction we have, just gets reset
    private func resetTransientGestureState() {
        resizeStartRect = nil
        dragStartRect = nil
        activeRotationDetent = nil
    }
}
