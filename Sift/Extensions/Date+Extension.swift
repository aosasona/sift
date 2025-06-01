//
//  Date+Extension.swift
//  Sift
//
//  Created by Ayodeji Osasona on 01/06/2025.
//
import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
