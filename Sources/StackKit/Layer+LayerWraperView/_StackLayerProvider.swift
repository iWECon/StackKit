import UIKit

protocol _StackLayerProvider {
    var effectiveSublayers: [CALayer] { get }
    func spacerLayers() -> [SpacerLayer]
    func dynamicSpacerLayers() -> [SpacerLayer]
    func dividerLayers() -> [DividerLayer]
    func viewsWithoutSpacer() -> [CALayer]
    func viewsWithoutSpacerAndDivider() -> [CALayer]
}

extension _StackLayerProvider where Self: CALayer {
    var effectiveSublayers: [CALayer] {
        (sublayers ?? []).lazy.filter { $0._isEffectiveLayer }
    }
    func spacerLayers() -> [SpacerLayer] {
        effectiveSublayers.compactMap({ $0 as? SpacerLayer })
    }
    func dynamicSpacerLayers() -> [SpacerLayer] {
        effectiveSublayers.compactMap({ $0 as? SpacerLayer }).filter({ $0.length == .greatestFiniteMagnitude })
    }
    func dividerLayers() -> [DividerLayer] {
        effectiveSublayers.compactMap({ $0 as? DividerLayer })
    }
    func viewsWithoutSpacer() -> [CALayer] {
        effectiveSublayers.filter({ ($0 as? SpacerLayer) == nil })
    }
    func viewsWithoutSpacerAndDivider() -> [CALayer] {
        effectiveSublayers.filter({ ($0 as? SpacerLayer) == nil && ($0 as? DividerLayer) == nil })
    }
}
