//
//  MatrixCalculation.swift
//  AbawMission
//
//  Created by 許佳航 on 2017/2/8.
//  Copyright © 2017年 許佳航. All rights reserved.
//

import UIKit

class MatrixCalculation: NSObject {
    static let sharedInstance = MatrixCalculation()
    // MARK: 3x3矩陣相乘
    func Matrix3x3(left:[Double], right:[Double]) -> [Double] {
        var result = [Double]()
        let column1 = [left[0],left[1],left[2]]
        let column2 = [left[3],left[4],left[5]]
        let column3 = [left[6],left[7],left[8]]
        let row1 = [right[0],right[3],right[6]]
        let row2 = [right[1],right[4],right[7]]
        let row3 = [right[2],right[5],right[8]]
        result.insert(matrixMultiplication(left: column1, right: row1), at: result.count)
        result.insert(matrixMultiplication(left: column1, right: row2), at: result.count)
        result.insert(matrixMultiplication(left: column1, right: row3), at: result.count)
        result.insert(matrixMultiplication(left: column2, right: row1), at: result.count)
        result.insert(matrixMultiplication(left: column2, right: row2), at: result.count)
        result.insert(matrixMultiplication(left: column2, right: row3), at: result.count)
        result.insert(matrixMultiplication(left: column3, right: row1), at: result.count)
        result.insert(matrixMultiplication(left: column3, right: row2), at: result.count)
        result.insert(matrixMultiplication(left: column3, right: row3), at: result.count)
        return result
    }
    
    // 矩陣乘法計算
    func matrixMultiplication(left:[Double], right:[Double]) -> Double {
        return left[0] * right[0] + left[1] * right[1] + left[2] * right[2]
    }

    // 矩陣 x 向量
    func matrixXVector(x: Double, y: Double, z: Double, gravitationalAcceleration: [Double]) -> [Double] {
        var result = [Double]()
        let newAccelerometerX =
            gravitationalAcceleration[0] * x + gravitationalAcceleration[1] * y + gravitationalAcceleration[2] * z
        let newAccelerometerY =
            gravitationalAcceleration[3] * x + gravitationalAcceleration[4] * y + gravitationalAcceleration[5] * z
        let newAccelerometerZ =
            gravitationalAcceleration[6] * x + gravitationalAcceleration[7] * y + gravitationalAcceleration[8] * z
        result.insert(newAccelerometerX, at: result.count)
        result.insert(newAccelerometerY, at: result.count)
        result.insert(newAccelerometerZ, at: result.count)
        return result
    }
    
    // 矩陣加法
    func additionOfMatrices(left:[Double], right:[Double]) -> [Double] {
        var result = left
        for i in 0...result.count - 1 {
            result[i] += right[i]
        }
        return result
    }
    
    // 矩陣 x Double
    func matrixXDouble(Matrix:[Double], double:Double) -> [Double] {
        var result = Matrix
        for i in 0...result.count - 1 {
            result[i] = result[i] * double
        }
        return result
    }
    
    // 向量長度
    func vectorNorm(vector: [Double]) -> Double {
        var result = 0.0
        result = (vector[0] * vector[0] + vector[1] * vector[1] + vector[2] * vector[2]).squareRoot()
        return result
    }
    
    // 向量內積求Cos Theta
    func vectorDotProductForCosTheta(vector1: [Double], vector2: [Double]) -> Double {
        var result = 0.0
        result = (vector1[0] * vector2[0] + vector1[1] * vector2[1] + vector1[2] * vector2[2]) / vectorNorm(vector: vector1) / vectorNorm(vector: vector2)
        return result
    }
    
    // 向量外積
    func vectorCrossProduct(vector1: [Double], vector2: [Double]) -> [Double] {
        var result = [0.0, 0.0, 0.0]
        result[0] = vector1[1] * vector2[2] - vector1[2] * vector2[1]
        result[1] = vector1[2] * vector2[0] - vector1[0] * vector2[2]
        result[2] = vector1[0] * vector2[1] - vector1[1] * vector2[0]
        return result
    }
    
    // 用旋轉矩陣將向量旋轉
    func correctingVectorToCoordinateSystem(vector: [Double], axle: String, angle: Double) -> [Double] {
        var result = [0.0, 0.0, 0.0]
        // X
        if axle == "x" || axle == "X" {
            let matrixX = [1.0, 0.0, 0.0,
                           0.0, cos(angle), -sin(angle),
                           0.0, sin(angle), cos(angle)]
            result = matrixXVector(x: vector[0], y: vector[1], z: vector[2], gravitationalAcceleration: matrixX)
        }
        if axle == "y" || axle == "Y" {
            // Y
            let matrixY = [cos(angle), 0.0, sin(angle),
                           0.0, 1.0, 0.0,
                           -sin(angle), 0.0, sin(angle)]
            result = matrixXVector(x: vector[0], y: vector[1], z: vector[2], gravitationalAcceleration: matrixY)
        }
        if axle == "z" || axle == "Z" {
            // Z
            let matrixZ = [cos(angle), -sin(angle), 0.0,
                           sin(angle), cos(angle), 1.0,
                           0.0, 0.0, 1.0]
            result = matrixXVector(x: vector[0], y: vector[1], z: vector[2], gravitationalAcceleration: matrixZ)
        }
        return result
    }
}
