import SwiftUI

struct TabBar: View {

    enum BallTrajectory {
        case parabolic
        case teleport
        case straight
    }

    @Binding private var selectedIndex: Int
    @Binding private var prevSelectedIndex: Int
    private var views: [AnyView] = []

    init<Views>(selectedIndex: Binding<Int>,
                       prevSelectedIndex: Binding<Int>? = nil,
                       @ViewBuilder content: @escaping () -> TupleView<Views>) {
        self._selectedIndex = selectedIndex
        self._prevSelectedIndex = prevSelectedIndex ?? .constant(0)
        self.internalPrevSelectedIndex = selectedIndex.wrappedValue
        self.views = content().getViews
    }

    init<Content: View>(selectedIndex: Binding<Int>,
                               prevSelectedIndex: Binding<Int>? = nil,
                               views: [Content]) {
        self._selectedIndex = selectedIndex
        self._prevSelectedIndex = prevSelectedIndex ?? .constant(0)
        self.internalPrevSelectedIndex = selectedIndex.wrappedValue
        self.views = views.map { AnyView($0) }
    }

    // MARK: - Customization

    private var barColor: Color = .white
    private var selectedColor: Color = .red
    private var unselectedColor: Color = .black
    private var ballColor: Color = .red

    private var verticalPadding: CGFloat = 30
    private var cornerRadius: CGFloat = 0

    private var ballAnimation: Animation = .easeOut(duration: 0.6)
    private var indentAnimation: Animation = .easeOut(duration: 0.6)
    private var buttonsAnimation: Animation = .easeOut(duration: 0.6)
    private var ballTrajectory: BallTrajectory = .parabolic

    private var didSelectIndex: ((Int)->())? = nil

    // MARK: - Properties

    @State private var frames: [CGRect] = []
    @State private var tBall: CGFloat = 0
    @State private var tIndent: CGFloat = 0
    @State private var internalPrevSelectedIndex: Int = 1

    private let circleSize = 10.0

    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                if layoutDirection == .rightToLeft {
                    Spacer()
                    circle
                        .scaleEffect(x: layoutDirection == .rightToLeft ? -1 : 1, y: 1)
                } else {
                    circle
                    Spacer()
                }
            }

            ZStack {
                background
                    .cornerRadius(cornerRadius)

                ButtonsBar {
                    ForEach(0..<views.count, id: \.self) { i in
                        let view = views[i].onTapGesture {
                            prevSelectedIndex = selectedIndex
                            selectedIndex = i
                            didSelectIndex?(i)
                        }
                            .background(ButtonPreferenceViewSetter())

#if swift(>=5.9)
                        if #available(iOS 17.0, *) {
                            view.animation(.linear) {
                                $0.foregroundStyle(selectedIndex == i ? selectedColor : unselectedColor)
                            }
                        } else {
                            view
                                .foregroundStyle(selectedIndex == i ? selectedColor : unselectedColor)
                                .animation(buttonsAnimation, value: selectedIndex)
                        }
#else
                        view
                            .foregroundStyle(selectedIndex == i ? selectedColor : unselectedColor)
                            .animation(buttonsAnimation, value: selectedIndex)
#endif
                    }
                }
                .coordinateSpace(name: buttonsBarSpace)
                .onPreferenceChange(ButtonPreferenceKey.self) { frames in
                    self.frames = frames
                }
                .padding(.vertical, verticalPadding)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .onChange(of: selectedIndex) { [selectedIndex] newValue in
            internalPrevSelectedIndex = selectedIndex
            tBall = 0
            tIndent = 0
            DispatchQueue.main.async {
                withAnimation(ballAnimation) {
                    tBall = 1
                }
                withAnimation(indentAnimation) {
                    tIndent = 1
                }
            }
        }
    }

    @ViewBuilder
    var circle: some View {
        switch ballTrajectory {
        case .parabolic:
            Circle()
                .frame(width: circleSize, height: circleSize)
                .foregroundColor(ballColor)
                .fixedSize()
                .alongPath(
                    t: tBall,
                    trajectory: trajectory(
                        from: getBallCoord(internalPrevSelectedIndex),
                        to: getBallCoord(selectedIndex)
                    )
                )

        case .teleport:
            Circle()
                .frame(width: circleSize, height: circleSize)
                .foregroundColor(ballColor)
                .fixedSize()
                .teleportEffect(t: tBall, from: getBallCoord(internalPrevSelectedIndex).x, to: getBallCoord(selectedIndex).x)
                .offset(y: 15)

        case .straight:
            Circle()
                .frame(width: circleSize, height: circleSize)
                .foregroundColor(ballColor)
                .fixedSize()
                .offset(x: getBallCoord(selectedIndex).x, y: 15)
                .animation(ballAnimation, value: selectedIndex)
        }
    }

    @ViewBuilder
    var background: some View {
        switch ballTrajectory {
        case .parabolic, .teleport:
            HStack(spacing: 0) {
                ForEach(0..<views.count, id: \.self) { i in
                    IndentableRect(t: selectedIndex == i ? 1 : 0, delay: 0.7)
                        .foregroundColor(barColor)
                        .animation(indentAnimation, value: selectedIndex)
                }
            }

        case .straight:
            SlidingIndentRect(t: tIndent, indentX: getCoord(selectedIndex).x, prevIndentX: getCoord(internalPrevSelectedIndex).x)
                .foregroundColor(barColor)
        }
    }

    func getBallCoord(_ at: Int) -> CGPoint {
        guard let frame = frames[safe: at] else {
            return .zero
        }
        return CGPoint(x: frame.midX - circleSize/2, y: frame.minY + 15)
    }

    func getCoord(_ at: Int) -> CGPoint {
        guard let frame = frames[safe: at] else {
            return .zero
        }
        return CGPoint(x: frame.midX, y: frame.minY)
    }

    func trajectory(from: CGPoint?, to: CGPoint?) -> Path {
        var path = Path()
        guard let from = from, let to = to else {
            return path
        }
        path.move(to: from)
        path.addQuadCurve(to: to, control: CGPoint(x: (from.x + to.x)/2, y: from.y - 100))
        return path
    }

    // MARK: - Customization setters

    func barColor(_ color: Color) -> TabBar {
        var switcher = self
        switcher.barColor = color
        return switcher
    }

    func selectedColor(_ color: Color) -> TabBar {
        var switcher = self
        switcher.selectedColor = color
        return switcher
    }

    func unselectedColor(_ color: Color) -> TabBar {
        var switcher = self
        switcher.unselectedColor = color
        return switcher
    }

    func ballColor(_ color: Color) -> TabBar {
        var switcher = self
        switcher.ballColor = color
        return switcher
    }

    func verticalPadding(_ verticalPadding: CGFloat) -> TabBar {
        var switcher = self
        switcher.verticalPadding = verticalPadding
        return switcher
    }

    func cornerRadius(_ cornerRadius: CGFloat) -> TabBar {
        var switcher = self
        switcher.cornerRadius = cornerRadius
        return switcher
    }

    func ballAnimation(_ ballAnimation: Animation) -> TabBar {
        var switcher = self
        switcher.ballAnimation = ballAnimation
        return switcher
    }

    func indentAnimation(_ indentAnimation: Animation) -> TabBar {
        var switcher = self
        switcher.indentAnimation = indentAnimation
        return switcher
    }

    func buttonsAnimation(_ buttonsAnimation: Animation) -> TabBar {
        var switcher = self
        switcher.buttonsAnimation = buttonsAnimation
        return switcher
    }

    func ballTrajectory(_ ballTrajectory: BallTrajectory) -> TabBar {
        var switcher = self
        switcher.ballTrajectory = ballTrajectory
        return switcher
    }

    func didSelectIndex(_ closure: @escaping (Int)->()) -> TabBar {
        var switcher = self
        switcher.didSelectIndex = closure
        return switcher
    }
}
