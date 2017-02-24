//
//  ViewController.swift
//  AbawMission
//
//  Created by 許佳航 on 2017/1/24.
//  Copyright © 2017年 許佳航. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    let coreMotionManager = CMMotionManager()
    let coreLocationManager = CLLocationManager()
    var lastPoint = CGPoint(x: 150, y: 450)
    var lastAccelerometerX:Double = 0
    var lastAccelerometerY:Double = 0
    var lastAccelerometerZ:Double = 0
    let time = 1.0 / 5.0
    // draw line
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 3.0
    var opacity: CGFloat = 1.0
    // Matrix amounting
    var gravitationalAcceleration:[Double] = [1,0,0,
                                              0,1,0,
                                              0,0,1]
    // gyro
    lazy var queue = OperationQueue()
    // accelerometer
    var accelerometerX = 0.0
    var accelerometerY = 0.0
    var accelerometerZ = 0.0
    // compass
    var northPointAngle = 0.0
    // labels
    @IBOutlet weak var accelerometerXLabel: UILabel!
    @IBOutlet weak var accelerometerYLabel: UILabel!
    @IBOutlet weak var accelerometerZLabel: UILabel!
    @IBOutlet weak var direction: UILabel!
    @IBOutlet weak var gyroX: UILabel!
    @IBOutlet weak var gyroY: UILabel!
    @IBOutlet weak var gyroZ: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreLocationManager.delegate = self
        if coreMotionManager.isAccelerometerAvailable {
            accelerometer()
            print("加速計可用")
        }
        if coreMotionManager.isGyroAvailable {
            gyroStart()
            print("陀螺儀可用")
        }
        if CLLocationManager.headingAvailable() {
            coreLocationManager.startUpdatingHeading()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 陀螺儀
    func gyroStart() {
        if coreMotionManager.isGyroActive  ==  false {
            coreMotionManager.gyroUpdateInterval  =  time
            coreMotionManager.startGyroUpdates(to: queue, withHandler: { (data, error) in
                DispatchQueue.main.async {
                    self.gyroX.text = "Gyro  Rotation  x  =  \((data?.rotationRate.x))"
                    self.gyroY.text = "Gyro  Rotation  y  =  \((data?.rotationRate.y))"
                    self.gyroZ.text = "Gyro  Rotation  z  =  \((data?.rotationRate.z))"
                    let rotationAmount =
                        self.rotationAmountCalculation(x: (data?.rotationRate.x)!, y: (data?.rotationRate.x)!, z: (data?.rotationRate.x)!)
                    self.gravitationalAcceleration = MatrixCalculation().Matrix3x3(left: rotationAmount, right: self.gravitationalAcceleration)
                    
                    // 重力向量
                    let nowGravitationalAccelerationVector =
                        MatrixCalculation().matrixXVector(
                            x: self.lastAccelerometerX,
                            y: self.lastAccelerometerY,
                            z: self.lastAccelerometerZ,
                            gravitationalAcceleration: self.gravitationalAcceleration)
//                    let a = MatrixCalculation().vectorCrossProduct(vector1: nowGravitationalAcceleration, vector2: [0,0,1])

                    // 移動向量
                    let movementVector = [(self.accelerometerX - nowGravitationalAccelerationVector[0]) * (self.time * self.time),
                                          (self.accelerometerY - nowGravitationalAccelerationVector[1]) * (self.time * self.time),
                                          (self.accelerometerZ - nowGravitationalAccelerationVector[2]) * (self.time * self.time)]
                    
                    // 校正至地球座標系
                    let correctedNowGravitationalAccelerationVector = MatrixCalculation().correctingVectorToCoordinateSystem(vector: nowGravitationalAccelerationVector, axle: "z", angle: -self.northPointAngle)
                    let correctedMovementVector = MatrixCalculation().correctingVectorToCoordinateSystem(vector: movementVector, axle: "z", angle: -self.northPointAngle)
//                    print("校正後的重力向量：\(correctedNowGravitationalAccelerationVector)")
//                    print("校正後的移動向量：\(correctedMovementVector)")
                    _ = MatrixCalculation().vectorCrossProduct(vector1: correctedNowGravitationalAccelerationVector, vector2: [0.0, 0.0, 1.0])
                    _ = MatrixCalculation().vectorDotProductForCosTheta(vector1: correctedNowGravitationalAccelerationVector, vector2: [0.0, 0.0, 1.0])
                    
                    let aDotb = nowGravitationalAccelerationVector[0] * movementVector[0] + nowGravitationalAccelerationVector[1] * movementVector[1] + nowGravitationalAccelerationVector[2] * movementVector[2]
                    let bxaDotb = [nowGravitationalAccelerationVector[0] * aDotb,
                                   nowGravitationalAccelerationVector[1] * aDotb,
                                   nowGravitationalAccelerationVector[2] * aDotb]
                    let projection = [movementVector[0] - bxaDotb[0],
                                      movementVector[1] - bxaDotb[1],
                                      movementVector[2] - bxaDotb[2]]
//                    print(Float(projection[0]), Float(projection[1]), Float(projection[2]))
//                    let newPoint = CGPoint(x: Double(self.lastPoint.x) + projection[0], y: Double(self.lastPoint.y) + projection[1])
//                    self.drawLine(from: self.lastPoint, to: newPoint)
//                    self.lastPoint = newPoint
                }
            })
        } else {
            print("Gyro  is  already  active")
        }
    }

    // MARK: 加速計
    func accelerometer() {
        coreMotionManager.accelerometerUpdateInterval = time
        coreMotionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
            self.accelerometerX = (data?.acceleration.x)!
            self.accelerometerY = (data?.acceleration.y)!
            self.accelerometerZ = (data?.acceleration.z)!
            if self.lastAccelerometerX == 0 {
                self.lastAccelerometerX = self.accelerometerX
                self.lastAccelerometerY = self.accelerometerY
                self.lastAccelerometerZ = self.accelerometerZ
            }
            DispatchQueue.main.async {
                self.accelerometerXLabel.text = "x = \((data?.acceleration.x))"
                self.accelerometerYLabel.text = "y = \((data?.acceleration.y))"
                self.accelerometerZLabel.text = "z = \((data?.acceleration.z))"
            }
        })
    }
    
    // MARK: 計算旋轉量
    func rotationAmountCalculation(x:Double, y:Double, z:Double) -> [Double] {
        var result = [Double]()
        // X
        let matrixX = [1.0, 0.0, 0.0,
                       0.0, cos(x), -sin(x),
                       0.0, sin(x), cos(x)]
        // Y
        let matrixY = [cos(y), 0.0, sin(y),
                       0.0, 1.0, 0.0,
                       -sin(y), 0.0, sin(y)]
        // Z
        let matrixZ = [cos(z), -sin(z), 0.0,
                       sin(z), cos(z), 1.0,
                       0.0, 0.0, 1.0]
        
        let leftMatrix = MatrixCalculation().Matrix3x3(left: matrixX, right: matrixY)
        let rightMatrix = matrixZ
        result = MatrixCalculation().Matrix3x3(left: leftMatrix, right: rightMatrix)

        return result
    }
    
    // MARK: drawLine
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        
        imageView.image?.draw(in: view.bounds)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(CGBlendMode.normal)
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    // MARK: Heading
     func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        direction.text = "\(newHeading.magneticHeading)"
        self.northPointAngle = newHeading.magneticHeading
     }
}

