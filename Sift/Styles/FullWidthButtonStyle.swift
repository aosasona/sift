//
//  FullWidthButtonStyle.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//

import SwiftUI

struct FullWidthButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let cornerRadius = 10.0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundStyle(isEnabled ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14.0)
            .padding(.horizontal)
            .background(
                isEnabled
                    ? (configuration.isPressed ? .accent.opacity(0.8) : .accent)
                    : .gray.opacity(0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isEnabled ? .accent : .clear, lineWidth: 0.75)
                    .brightness(0.15)
            )
            .sensoryFeedback(.impact, trigger: configuration.isPressed)
    }
}

extension ButtonStyle where Self == FullWidthButtonStyle {
    static var fullWidth: Self {
        return .init()
    }
}
