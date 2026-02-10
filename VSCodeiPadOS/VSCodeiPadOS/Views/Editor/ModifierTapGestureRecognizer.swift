import UIKit

/// UITapGestureRecognizer that captures the modifier flags (Option/Shift/Cmd/etc) active at the time of the tap.
///
/// UIKit doesn't expose the UIEvent in the selector callback, so we store it from touchesBegan.
final class ModifierTapGestureRecognizer: UITapGestureRecognizer {
    private(set) var lastModifierFlags: UIEvent.ModifierFlags = []

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        lastModifierFlags = event.modifierFlags
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        lastModifierFlags = event.modifierFlags
        super.touchesMoved(touches, with: event)
    }
}
