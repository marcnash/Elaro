import Foundation

struct ExplainWhyBuilder {
    func build(focusId: String, preferredDuration: Int, hour: Int, frictionIndex: Double) -> String {
        let when: String = (5..<12).contains(hour) ? "mornings" : (12..<17).contains(hour) ? "afternoons" : "evenings"
        let friction = frictionIndex > 0.4 ? "gentle options" : "a small stretch"
        let focusWord = (focusId == "emotion_skills") ? "Emotion Skills" : (focusId == "independence" ? "Independence" : "your focus")
        return "Because \(when) and \(preferredDuration)-minute actions work for you, we're offering \(friction) for \(focusWord) today."
    }
}
