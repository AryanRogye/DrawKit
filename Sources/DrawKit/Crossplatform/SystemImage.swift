//
//  SystemImage.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/13/26.
//



#if os(macOS)
import AppKit
public typealias SystemImage = NSImage
#elseif os(iOS)
import UIKit
public typealias SystemImage = UIImage
#endif
