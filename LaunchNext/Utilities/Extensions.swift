import AppKit
import SwiftUI

// MARK: - Color Extensions

extension Color {

  static var launchpadBorder: Color {
    Color(.systemBlue)
  }

}

// MARK: - Font Extensions

extension Font {

  static var `default`: Font {
    .system(size: 11, weight: .medium)
  }

}

// MARK: - View Extensions for Glass Effect

extension View {

  @ViewBuilder
  func liquidGlass(in shape: some Shape, isEnabled _: Bool = true) -> some View {
    if #available(macOS 26.0, iOS 18.0, *) {
      self.glassEffect(.regular, in: shape)
    } else {
      background(.ultraThinMaterial, in: shape)
    }
  }

  @ViewBuilder
  func liquidGlass(isEnabled _: Bool = true) -> some View {
    if #available(macOS 26.0, iOS 18.0, *) {
      self.glassEffect(.regular)
    } else {
      background(.ultraThinMaterial)
    }
  }

}
