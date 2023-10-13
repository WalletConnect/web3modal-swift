import UIKit
import SwiftUI

struct CircleProgressView: UIViewRepresentable {
    
    var color: Color
    var lineWidth: CGFloat
    
    @Binding var isAnimating: Bool

    func makeUIView(context: Context) -> CircleProgressUIView {
        let view = CircleProgressUIView(
            colors: [UIColor(color)],
            lineWidth: lineWidth
        )
        
        view.isAnimating = true
        
        return view
    }

    func updateUIView(_ uiView: CircleProgressUIView, context: Context) {

    }
}

struct CircleProgressView_Preview: PreviewProvider {
    static var previews: some View {
        CircleProgressView(
            color: .blue,
            lineWidth: 10,
            isAnimating: .constant(true)
        )
        .frame(width: 100, height: 100)
    }
}

class CircleProgressUIView: UIView {

    // MARK: - Properties
    let colors: [UIColor]
    let lineWidth: CGFloat

    private lazy var shapeLayer: ProgressShapeLayer = {
        return ProgressShapeLayer(strokeColor: colors.first!, lineWidth: lineWidth)
    }()

    var isAnimating: Bool = false {
        didSet {
            if isAnimating {
                self.animateStroke()
                self.animateRotation()
            } else {
                self.shapeLayer.removeFromSuperlayer()
                self.layer.removeAllAnimations()
                self.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Initialization
    init(frame: CGRect,
         colors: [UIColor],
         lineWidth: CGFloat
    ) {
        self.colors = colors
        self.lineWidth = lineWidth

        super.init(frame: frame)

        self.backgroundColor = .clear
    }
    
    convenience init(colors: [UIColor], lineWidth: CGFloat) {
        self.init(frame: .zero, colors: colors, lineWidth: lineWidth)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = self.frame.width / 2

        let path = UIBezierPath(ovalIn:
            CGRect(
                x: 0,
                y: 0,
                width: self.bounds.width,
                height: self.bounds.width
            )
        ).cgPath
        
        
        
//        let cornerRadius: CGFloat = 25
//        let rect = self.bounds
//        let path = CGMutablePath()
//
//        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
//        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
//        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius), radius: cornerRadius)
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
//        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY), radius: cornerRadius)
//        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
//        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius), radius: cornerRadius)
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
//        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.minX + cornerRadius, y: rect.minY), radius: cornerRadius)
//        path.closeSubpath()

        shapeLayer.path = path
    }

    // MARK: - Animations
    func animateStroke() {

        let startAnimation = StrokeAnimation(
            type: .start,
            beginTime: 0.25,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )

        let endAnimation = StrokeAnimation(
            type: .end,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )

        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [startAnimation, endAnimation]

        shapeLayer.add(strokeAnimationGroup, forKey: nil)

        let colorAnimation = StrokeColorAnimation(
            colors: colors.map { $0.cgColor },
            duration: strokeAnimationGroup.duration * Double(colors.count)
        )

        shapeLayer.add(colorAnimation, forKey: nil)

        self.layer.addSublayer(shapeLayer)
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
        self.lineCap = .round
    }

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
         duration: Double) {

        super.init()

        self.keyPath = type == .start ? "strokeStart" : "strokeEnd"

        self.beginTime = beginTime
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = .init(name: .easeInEaseOut)
    }

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
