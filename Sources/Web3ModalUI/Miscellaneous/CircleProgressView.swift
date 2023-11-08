import SwiftUI
import UIKit

public struct DrawingProgressView: UIViewRepresentable {
    var shape: DrawingProgressUIView.ShapePath
    var color: Color
    var lineWidth: CGFloat
    var duration: Double

    @Binding var isAnimating: Bool

    public init(
        shape: DrawingProgressUIView.ShapePath,
        color: Color,
        lineWidth: CGFloat,
        duration: Double = 1.5,
        isAnimating: Binding<Bool>
    ) {
        self.shape = shape
        self.color = color
        self.lineWidth = lineWidth
        self.duration = duration
        self._isAnimating = isAnimating
    }

    public func makeUIView(context: Context) -> DrawingProgressUIView {
        let view = DrawingProgressUIView(
            shape: shape,
            colors: [UIColor(color)],
            lineWidth: lineWidth,
            duration: duration
        )

        view.isAnimating = true
        
        switch shape {
        case .circle, .roundedRectangleRelative, .roundedRectangleAbsolute:
            view.transform = .identity.rotated(by: -CGFloat.pi / 2)
        case .hexagon:
            break
        }

        return view
    }

    public func updateUIView(_ uiView: DrawingProgressUIView, context: Context) {}
}

struct DrawingProgressView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            DrawingProgressView(
                shape: .circle,
                color: .blue,
                lineWidth: 5,
                isAnimating: .constant(true)
            )
            .frame(width: 100, height: 100)
            
            DrawingProgressView(
                shape: .roundedRectangleAbsolute(cornerRadius: 5),
                color: .blue,
                lineWidth: 5,
                isAnimating: .constant(true)
            )
            .frame(width: 100, height: 100)
            
            DrawingProgressView(
                shape: .roundedRectangleRelative(relativeCornerRadius: 0.25),
                color: .blue,
                lineWidth: 5,
                isAnimating: .constant(true)
            )
            .frame(width: 100, height: 100)
            
            DrawingProgressView(
                shape: .hexagon,
                color: .blue,
                lineWidth: 5,
                isAnimating: .constant(true)
            )
            .frame(width: 100, height: 100)
        }
    }
}

public class DrawingProgressUIView: UIView {
    public enum ShapePath {
        case circle
        case roundedRectangleRelative(relativeCornerRadius: Double)
        case roundedRectangleAbsolute(cornerRadius: Double)
        case hexagon
    }

    // MARK: - Properties

    let shape: ShapePath
    let colors: [UIColor]
    let lineWidth: CGFloat
    let duration: Double

    private lazy var shapeLayer: ProgressShapeLayer = .init(strokeColor: colors.first!, lineWidth: lineWidth)

    var isAnimating: Bool = false {
        didSet {
            if self.isAnimating {
                self.animateStroke()
            } else {
                self.shapeLayer.removeFromSuperlayer()
                self.layer.removeAllAnimations()
                self.removeFromSuperview()
            }
        }
    }

    // MARK: - Initialization

    init(
        shape: ShapePath,
        frame: CGRect,
        colors: [UIColor],
        lineWidth: CGFloat,
        duration: Double
    ) {
        self.shape = shape
        self.colors = colors
        self.lineWidth = lineWidth
        self.duration = duration

        super.init(frame: frame)

        self.backgroundColor = .clear
    }

    convenience init(
        shape: ShapePath,
        colors: [UIColor],
        lineWidth: CGFloat,
        duration: Double
    ) {
        self.init(
            shape: shape,
            frame: .zero,
            colors: colors,
            lineWidth: lineWidth,
            duration: duration
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        
        let path: CGPath

        switch self.shape {
        case .circle:
            path = UIBezierPath(ovalIn: frame).cgPath
        case let .roundedRectangleRelative(relativeCornerRadius):
            path = CGPath(
                roundedRect: self.frame,
                cornerWidth: self.frame.width * relativeCornerRadius,
                cornerHeight: self.frame.height * relativeCornerRadius,
                transform: nil
            )
        case let .roundedRectangleAbsolute(cornerRadius):
            path = CGPath(
                roundedRect: self.frame,
                cornerWidth: cornerRadius,
                cornerHeight: cornerRadius,
                transform: nil
            )
        case .hexagon:
            path = Polygon(count: 6, relativeCornerRadius: 0.25).path(in: frame).cgPath
        }

        self.shapeLayer.path = path
    }

    // MARK: - Animations

    func animateStroke() {
        let beginTime = 0.25

        let startAnimation = StrokeAnimation(
            type: .start,
            beginTime: beginTime,
            fromValue: 0.0,
            toValue: 1.0,
            duration: duration - beginTime
        )

        let endAnimation = StrokeAnimation(
            type: .end,
            fromValue: 0.0,
            toValue: 1.0,
            duration: duration - beginTime
        )

        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = duration
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [startAnimation, endAnimation]

        self.shapeLayer.add(strokeAnimationGroup, forKey: nil)

        let colorAnimation = StrokeColorAnimation(
            colors: colors.map { $0.cgColor },
            duration: strokeAnimationGroup.duration * Double(self.colors.count)
        )

        self.shapeLayer.add(colorAnimation, forKey: nil)

        self.layer.addSublayer(self.shapeLayer)
    }

    func animateRotation() {
        let rotationAnimation = RotationAnimation(
            direction: .z,
            fromValue: 0,
            toValue: CGFloat.pi * 2,
            duration: 2,
            repeatCount: .greatestFiniteMagnitude
        )

        self.layer.add(rotationAnimation, forKey: nil)
    }
}

class ProgressShapeLayer: CAShapeLayer {
    public init(strokeColor: UIColor, lineWidth: CGFloat) {
        super.init()

        self.strokeColor = strokeColor.cgColor
        self.lineWidth = lineWidth
        self.fillColor = UIColor.clear.cgColor
        self.lineCap = .square
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RotationAnimation: CABasicAnimation {
    enum Direction: String {
        case x, y, z
    }

    override init() {
        super.init()
    }

    public init(
        direction: Direction,
        fromValue: CGFloat,
        toValue: CGFloat,
        duration: Double,
        repeatCount: Float
    ) {
        super.init()

        self.keyPath = "transform.rotation.\(direction.rawValue)"

        self.fromValue = fromValue
        self.toValue = toValue

        self.duration = duration

        self.repeatCount = repeatCount
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StrokeAnimation: CABasicAnimation {
    override init() {
        super.init()
    }

    init(type: StrokeType,
         beginTime: Double = 0.0,
         fromValue: CGFloat,
         toValue: CGFloat,
         duration: Double)
    {
        super.init()

        self.keyPath = type == .start ? "strokeStart" : "strokeEnd"

        self.beginTime = beginTime
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = .init(name: .easeInEaseOut)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum StrokeType {
        case start
        case end
    }
}

class StrokeColorAnimation: CAKeyframeAnimation {
    override init() {
        super.init()
    }

    init(colors: [CGColor], duration: Double) {
        super.init()

        self.keyPath = "strokeColor"
        self.values = colors
        self.duration = duration
        self.repeatCount = .greatestFiniteMagnitude
        self.timingFunction = .init(name: .easeInEaseOut)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
