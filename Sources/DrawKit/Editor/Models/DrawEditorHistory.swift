//
//  DrawEditorHistory.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/15/26.
//


/// The private storage behind `DrawEditor.undo()` and `DrawEditor.redo()`.
///
/// Each entry is a snapshot of the editor's complete `items` array. Keeping
/// snapshots makes restoring an edit straightforward: undo replaces the
/// current items with the most recent snapshot, while saving the state it
/// replaced so that redo can restore it later.
///
/// This type contains only canvas content. Tool selection, zoom, and other
/// temporary interface state are intentionally not part of undo history.
struct DrawEditorHistory {
    /// The maximum number of snapshots retained in `undoSnapshots`.
    /// When the limit is exceeded, the oldest snapshots are discarded first.
    let limit: Int

    /// Canvas states from before completed edits.
    ///
    /// The newest snapshot is at the end of the array. Undo removes that
    /// snapshot and installs it as the editor's current `items` value.
    var undoSnapshots: [[MarkupItems]] = []

    /// Canvas states that were removed by undo and can be restored by redo.
    ///
    /// Completing a new edit clears this array because the editor has started
    /// a new history branch.
    var redoSnapshots: [[MarkupItems]] = []

    /// The canvas state captured at the beginning of a continuous interaction.
    ///
    /// Pen strokes, eraser drags, shape transforms, and slider drags can update
    /// `items` many times. This snapshot lets those updates become one undo
    /// step when `commitHistoryTransaction()` is called. It is `nil` when no
    /// continuous interaction is active.
    var transactionStart: [MarkupItems]?
}
