//
//  ConsoleSymbolView.swift
//  GameConsoleSymbols
//
//  SwiftUI helpers that load the symbols from the package's resource bundle.
//

#if canImport(SwiftUI)
import SwiftUI

public extension Image {
    /// Creates an `Image` for a console symbol, loaded from this package's bundle.
    init(consoleSymbol: ConsoleSymbol) {
        self.init(consoleSymbol.assetName, bundle: .module)
    }

    /// Creates an `Image` for a console symbol by asset name (no accessibility label).
    init(consoleSymbolNamed assetName: String) {
        self.init(assetName, bundle: .module)
    }
}

/// Renders a console symbol as a template image with a VoiceOver label.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ConsoleSymbolView: View {
    private let symbol: ConsoleSymbol
    private let height: CGFloat

    /// - Parameters:
    ///   - symbol: The symbol to render (see ``GameConsoleSymbols/symbol(igdbID:slug:abbreviation:name:variant:)``).
    ///   - height: Point height the logo is scaled to fit. Defaults to 18.
    public init(symbol: ConsoleSymbol, height: CGFloat = 18) {
        self.symbol = symbol
        self.height = height
    }

    public var body: some View {
        Image(consoleSymbol: symbol)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(height: height)
            .accessibilityLabel(Text(symbol.label))
    }
}
#endif
