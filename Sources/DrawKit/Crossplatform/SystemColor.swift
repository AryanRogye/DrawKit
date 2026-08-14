//
//  SystemColor.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/13/26.
//

#if os(macOS)
import AppKit
public typealias SystemColor = NSColor
#elseif os(iOS)
import UIKit
public typealias SystemColor = UIColor
#endif
