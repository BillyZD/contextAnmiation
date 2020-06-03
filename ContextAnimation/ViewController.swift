//
//  ViewController.swift
//  ContextAnimation
//
//  Created by 张冬 on 2019/10/15.
//  Copyright © 2019 张冬. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {

    let animatinView = AnimationView()
    
    let layView = PieView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(animatinView)
        self.view.addSubview(layView)
        layView.backgroundColor = UIColor.black
        animatinView.backgroundColor = UIColor.black
        animatinView.frame = CGRect(x: 20, y: 70, width: 300, height: 300)
        layView.frame = CGRect(x: 20, y: 390, width: 300, height: 300)
        self.layView.startAnmaiton(duration: 1)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animatinView.startAnmaiton(duration: 0.5)
        self.layView.startAnmaiton(duration: 1)
        debugPrint(cos(CGFloat.pi) , cos(0.5 * CGFloat.pi) ,cos(1.8 * CGFloat.pi) , cos(CGFloat.pi * 2) , 180 * acos(0.5)/CGFloat.pi)
    }
    
}

class AnimationView: UIView {
    
    private let animation = AnimationModel()
    
    private let VMagrin: CGFloat = 20
    
    private let hMargin: CGFloat = 20
    
    private let shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.yellow.cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.lineWidth = 1
        return layer
    }()

    private let dataArr: [Double] = [29 , 39 ,23 , 49 , 100 , 30 ,34 , 0 ,12 , 45 ,23 ,13 ,34 , 12 , 45 , 24 , 34 , 45 ,23 ,24]
    
    private var maxData: Double = 0
    
    private let radius: CGFloat = 2
    
    /// 是否正在动画
    private var isAnimation: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.maxData = dataArr.max() ?? 0
        self.layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnmaiton(duration: TimeInterval) {
        guard isAnimation == false else {
            return
        }
        isAnimation = true
        self.animation.animate(duration: duration)
        self.animation.updateBlock = {
            self.setNeedsDisplay()
        }
        self.animation.stopBlock = { [weak self] in
            self?.isAnimation = false
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.shapeLayer.frame = self.bounds
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        self.drawAxle(rect: rect, context: context)
        self.drawLinchart(rect: rect, context: context)
        
    }
    
    /// 画折线图
    private func drawLinchart(rect: CGRect , context: CGContext) {
        guard self.maxData > 0 else {
            return
        }
        context.saveGState()
        context.setLineWidth(1)
        context.setFillColor(UIColor.red.cgColor)
        let drawLenge: Int = Int((Double(dataArr.count) * animation.phaseX))
        if drawLenge <= dataArr.count , drawLenge > 1 {
            let w: CGFloat = (rect.width - hMargin * 2)/(CGFloat(dataArr.count - 1))
            for i in 1 ... drawLenge {
                let x1 = hMargin + CGFloat(i - 1) * w
                let y1 = rect.height - CGFloat(dataArr[i - 1]/maxData) * (rect.height - 2 * VMagrin) - VMagrin
               
                if i != drawLenge {
                    let x2 = hMargin + CGFloat(i) * w
                    let y2 = rect.height - CGFloat(dataArr[i]/maxData) * (rect.height - 2 * VMagrin) - VMagrin
                    let pointGroup = changePoint(x1: CGPoint(x: x1, y: y1), x2: CGPoint(x: x2, y: y2), radius: radius)
                    context.move(to: pointGroup.x1) ; context.addLine(to: pointGroup.x2)
                }
                context.setStrokeColor(UIColor.red.cgColor)
                context.setLineJoin(.round)
                context.strokePath()
                context.fillEllipse(in: CGRect(x: x1 - radius, y: y1 - radius , width: radius * 2, height: radius * 2))
                context.setStrokeColor(UIColor.white.cgColor)
                context.strokeEllipse(in: CGRect(x: x1 - radius, y: y1 - radius , width: radius * 2, height: radius * 2))
            }
        }
      
        context.restoreGState()
    }
    
    /// 画坐标系
    private func drawAxle(rect: CGRect , context: CGContext) {
        
        let zeroPoint = CGPoint(x: hMargin, y: rect.height - VMagrin)
        
        let yPoint = CGPoint(x: rect.width - hMargin, y: rect.height - VMagrin)
        
        let xPoint = CGPoint(x: hMargin, y: VMagrin)
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(1)
        
        context.move(to: xPoint)
        context.addLine(to: zeroPoint)
        context.addLine(to: yPoint)
        context.strokePath()
        
    }
    
    /// 计算折线不穿过点
    private func changePoint(x1: CGPoint , x2: CGPoint , radius: CGFloat) -> (x1: CGPoint , x2: CGPoint) {
        let k = (x2.y - x1.y)/(x2.x - x1.x)
        let arc = atan(k) // 反三角函数,获取角度
        let sinArc = sin(arc)
        let coseArc = cos(arc)
        let _x1 = CGPoint(x: x1.x + radius * coseArc, y: x1.y + radius * sinArc)
        let _x2 = CGPoint(x: x2.x - radius * coseArc, y: x2.y  - radius * sinArc)
        return (_x1 , _x2)
    }
    
}


class AnimationModel: NSObject {
    
    var displayLin: CADisplayLink?
    
    var startTime: TimeInterval = 0.0
    
    var endTime: TimeInterval = 0.0
    
    var duration: TimeInterval = 0.0
    
    var updateBlock: (() -> Void)?
    
    var stopBlock: (() -> Void)?
    
    var phaseX: Double = 1
    
    func animate(duration: TimeInterval) {
        self.startTime = CACurrentMediaTime()
        self.duration = duration
        self.endTime = startTime + duration
        self.updateAnimationPhsees(currentTime: startTime)
        if self.displayLin == nil {
            self.displayLin = CADisplayLink(target: self, selector: #selector(animationLoop))
            self.displayLin?.add(to: .main, forMode: .common)
        }
        
    }
    
    func stop() {
        self.displayLin?.remove(from: .main, forMode: .common)
        self.displayLin = nil
        stopBlock?()
    }
    
    @objc private func animationLoop(){
        let currentTime = CACurrentMediaTime()
        self.updateAnimationPhsees(currentTime: currentTime)
        updateBlock?()
        if currentTime >= self.endTime {
            self.stop()
        }
    }
    
    /// 更新进度
    private func updateAnimationPhsees(currentTime: TimeInterval) {
        let elapsedTime = currentTime - self.startTime
        if elapsedTime >= duration {
            phaseX = 1.0
            return
        }
        phaseX = elapsedTime/duration
    }
    
}

class LayerAnimation: UIView {
    
    private let VMagrin: CGFloat = 20
    
    private let hMargin: CGFloat = 20
    
    private let dataArr: [Double] = [29 , 39 ,23 , 49 , 100 , 30 ,34 , 0 ,12 , 45 ,23 ,13 ,34 , 12 , 45 , 24 , 34 , 45 ,23 ,24]
    
    private let shapePathLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.yellow.cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.lineWidth = 1
        return layer
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(shapePathLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.shapePathLayer.frame = rect
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        self.drawAxle(rect: rect, context: context)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: hMargin, y: rect.height - VMagrin))
        path.addLine(to: CGPoint(x: hMargin, y: 150))
        path.addLine(to: CGPoint(x: hMargin + 30, y: 100))
        path.addLine(to: CGPoint(x:  hMargin + 60, y: 200))
        path.addLine(to: CGPoint(x:  hMargin + 60, y: rect.height - VMagrin))
        let criclePath = UIBezierPath(arcCenter: CGPoint(x: hMargin, y: 150), radius: 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        path.append(criclePath)
        UIColor.yellow.setFill()
        path.fill()
        path.stroke()
      //  self.shapePathLayer.path = path.cgPath
    }
    
    
    /// 画坐标系
    private func drawAxle(rect: CGRect , context: CGContext) {
        
        let zeroPoint = CGPoint(x: hMargin, y: rect.height - VMagrin)
        
        let yPoint = CGPoint(x: rect.width - hMargin, y: rect.height - VMagrin)
        
        let xPoint = CGPoint(x: hMargin, y: VMagrin)
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(1)
        
        context.move(to: xPoint)
        context.addLine(to: zeroPoint)
        context.addLine(to: yPoint)
        context.strokePath()
        
    }
}


class PieView: UIView {
    
    private let animation = AnimationModel()
    
    private let dataArr: [Double] = [0.25 , 0.3 ,0.15 , 0.1 , 0.2]
    
    private let colorArr: [UIColor] = [.white , .red , .yellow , .blue , .brown]
    
    private let radius: CGFloat = 100
    
    /// 是否正在动画
    private var isAnimation: Bool = false
    
    /// 选中时的半径比例
    private var selectRadius = 1.2
    
    
    /// 初始角度
    private var startAngle: CGFloat = 270
    
    /// 开始拖动时的角度
    private var startMoveAngle: CGFloat = 270
    
    /// 开始触摸的点
    private var startTouchPoint: CGPoint = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotaionGestureRecogniezd(recognizer:)))
        self.addGestureRecognizer(rotationGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureRcogniezd(recognizer:)))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    private var selectIndex: Int = -1 {
        didSet{
            if oldValue != selectIndex {
               self.setNeedsDisplay()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            self.startTouchPoint = point
            let angle = self.angleForPoint(point: point)
            self.startMoveAngle = angle
            self.startMoveAngle -= self.startAngle
        }
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.startMoveAngle = startAngle
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self)  {
            if caluateDistance(p1: point, p2: startTouchPoint) >= 8 {
                self.selectIndex = -1
                let angle = self.angleForPoint(point: point)
                self.startAngle = angle - startMoveAngle
                if self.startAngle < 0 {
                    self.startAngle = startAngle + 360
                }else if self.startAngle >= 360 {
                    self.startAngle = startAngle - 360
                }
                self.setNeedsDisplay()
            }
            
        }
    }
    
    // 计算二点之间的距离
    private func caluateDistance(p1: CGPoint , p2: CGPoint) -> CGFloat {
        let tx = p2.x - p1.x
        let ty = p2.y - p1.y
        return sqrt(tx * tx + ty * ty)
    }


    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnmaiton(duration: TimeInterval) {
        guard isAnimation == false else {
            return
        }
        self.selectIndex = -1
        isAnimation = true
        self.animation.animate(duration: duration)
        self.animation.updateBlock = {
            self.setNeedsDisplay()
        }
        self.animation.stopBlock = { [weak self] in
            self?.isAnimation = false
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let center: CGPoint = CGPoint(x: rect.width/2, y: rect.height/2)
        context.saveGState()
        var angle: CGFloat = 0
        var _radius = self.radius
        for i in 0 ..< dataArr.count {
            if i == self.selectIndex {
                _radius = self.radius * CGFloat(self.selectRadius)
            }else {
                _radius = self.radius
            }
            context.setFillColor(colorArr[i].cgColor)
            let sliceAngle: CGFloat = CGFloat(dataArr[i]) * 360
            let startAngeOuter = startAngle + angle
            
            let arcStartPointX = center.x + _radius * cos(startAngeOuter.DEG2RAD())
            let arcStartPointY = center.y + _radius * sin(startAngeOuter.DEG2RAD())
            let path = CGMutablePath()
            path.move(to: CGPoint(x: arcStartPointX, y: arcStartPointY))
    
            path.addRelativeArc(center: center, radius: _radius, startAngle: startAngeOuter.DEG2RAD(), delta: sliceAngle.DEG2RAD())
            
            path.addLine(to: center)
            
            path.closeSubpath()
            context.beginPath()
            context.addPath(path)
            context.fillPath(using: .evenOdd)

            angle = angle + sliceAngle * CGFloat(self.animation.phaseX)
        }
        context.restoreGState()
        self.drawValue(context: context)
        self.drawInnerArc(context: context, percent: 0.4)
    
    }
    
    /// 画数据
    private func drawValue(context: CGContext) {
        let center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        let angleArr = dataArr.map { progress in
            return progress * 360.0
        }
        ///设置边线
        let leftMaxX: CGFloat = 25 ; let rightMaxX: CGFloat = self.frame.size.width - 25
        
        context.saveGState()
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.green.cgColor)
        context.setFillColor(UIColor.black.cgColor)
        var _startAngle = Double(self.startAngle)
        var endAngle = _startAngle
        for i in 0 ..< angleArr.count {
            endAngle = _startAngle + angleArr[i]
            var centerAngle = (_startAngle + endAngle)/2
            if centerAngle >= 360 {
                centerAngle = centerAngle - 360
            }
            centerAngle = Double.pi * centerAngle/180
            let p = CGPoint(x: center.x + self.radius * CGFloat(cos(centerAngle)), y: center.y + radius * CGFloat(sin(centerAngle)))
            
            context.fillEllipse(in: CGRect(x: p.x - 2, y: p.y - 2 , width: 4, height: 4))
            context.strokeEllipse(in: CGRect(x: p.x - 2, y: p.y - 2 , width: 4, height: 4))
            _startAngle = endAngle
            
            let p1 = CGPoint(x: center.x + (radius + 15) * CGFloat(cos(centerAngle)), y: center.y + (radius + 15) * CGFloat(sin(centerAngle)))
            // 画线
            context.move(to: p) ; context.addLine(to: p1)
            // 角度决定水平方向
            if (centerAngle >= 0 && centerAngle <= Double.pi/2) || (centerAngle >= 1.5 * Double.pi) {
                // 水平向右
                if p1.x <= rightMaxX {
                    let p2 = CGPoint(x: rightMaxX, y: p1.y)
                    context.addLine(to: p2)
                }else {
                    // 水平右边的距离不够
                    debugPrint("水平右边的距离不够")
                }
            } else {
                // 水平向左
                if p1.x >= leftMaxX {
                    let p2 = CGPoint(x: leftMaxX, y: p1.y)
                    context.addLine(to: p2)
                }else {
                     debugPrint("水平左边的距离不够")
                }
            }
            context.strokePath()
            
            if _startAngle >= 360 {
                _startAngle = _startAngle - 360
            }
            _startAngle = _startAngle * animation.phaseX
        }
        context.restoreGState()
    }
    
    /// 画同心圆
    private func drawInnerArc(context: CGContext , percent: CGFloat) {
        guard percent >= 0 , percent < 1 else {
            return
        }
        context.saveGState()
        context.setFillColor(UIColor.black.cgColor)
        defer { context.restoreGState() }
        // 圆心
        let center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        // 半径
        let innerRadius = self.radius * percent
        context.fillEllipse(in: CGRect(x: center.x - innerRadius, y: center.y - innerRadius, width: innerRadius * 2, height: innerRadius * 2))
    }

    /// 判断是否在点击的点在圆内
    func isContain(point: CGPoint) -> Bool {
        let center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        let r: CGFloat = abs(point.x - center.x) *  abs(point.x - center.x) + abs(point.y - center.y) * abs(point.y - center.y)
        return r <= self.radius * self.radius
    }
    
    /// 计算点击的角度(三角函数基本知识)
    private func angleForPoint(point: CGPoint) -> CGFloat {
        // 圆心
        let c = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        let tx = Double(point.x - c.x)
        let ty = Double(point.y - c.y)
        let length = sqrt(tx * tx + ty * ty)
        let r = acos(tx/length)
        var angle = (CGFloat(r)/CGFloat.pi) * 180
        if point.y <= c.y {
            angle = 360 - angle
            if point.y == c.y , point.x < c.x{
                angle = 180
            }else if point.y == c.y ,point.x > c.x {
                angle = 360
            } else if point.x == c.x {
                angle = 270
            }
        }else if point.y > c.y , point.x == c.x {
            angle = 90
        }
        return angle
    }
    
    /// 获取下标
    private func indexForAngle(_ angle: CGFloat) -> Int {
        let angreArr = self.dataArr.map {  progress in
            return progress * 360
        }
        var start: Double = Double(self.startAngle) > 360 ? Double(startAngle) - 360 : Double(startAngle)
        var maxAngle: Double = start
        for i in 0 ... angreArr.count - 1 {
           maxAngle = start + angreArr[i]
            if maxAngle < 360 {
                if Double(angle) > start , Double(angle) < maxAngle {
                    return i
                }
            }else {
                if Double(angle) > start {
                    return i
                }
                maxAngle =  maxAngle - 360
                if Double(angle) < maxAngle {
                    return i
                }
            }
            start = maxAngle
            start = start > 360 ? (start - 360) : start
           
        }
        return -1
    }
    
    /// 旋转手势的回调
    @objc private func rotaionGestureRecogniezd(recognizer: UIRotationGestureRecognizer) {
        debugPrint("旋转手势")
        if recognizer.state == .began || recognizer.state == .changed {
            let angle = (recognizer.rotation * 180) / CGFloat.pi
            debugPrint(angle)
            self.startAngle = self.startAngle + angle
            if startAngle >= 360 {
                startAngle = startAngle - 360
            }
            self.setNeedsDisplay()
            
            
        }
    }
    
    /// 点击手势
    @objc private func tapGestureRcogniezd(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        if self.isContain(point: point) {
            let angle = self.angleForPoint(point: point)
            selectIndex = self.indexForAngle(angle)
        }else {
            debugPrint("不处理")
            selectIndex = -1
        }
            
        
    }
    
}


extension CGFloat {
    
    /// 获取角度
    func DEG2RAD() -> CGFloat {
        return CGFloat.pi * self/180
    }
    
}
