//
//  NumberFormatterUtils.swift
//  GitHubViewer
//
//  Created by Duong Pham on 31/12/24.
//

import Foundation

struct NumberFormatterUtils {
    /// Formats a number into GitHub-like shorthand notation.
    /// - Parameter number: The number to be formatted.
    /// - Returns: A formatted string (e.g., "10+", "100+", "1K+", "10K+")
    static func formatGitHubNumber(_ number: Int) -> String {
        switch number {
        case 0..<10:
            return "\(number)"
        case 10..<100:
            return "\(number / 10 * 10)+"
        case 100..<1000:
            return "\(number / 100 * 100)+"
        default:
            return "\(number / 1000)K+"
        }
    }
}
