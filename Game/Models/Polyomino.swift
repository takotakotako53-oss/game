import Foundation
import SwiftUI

// ポリオミノの形状を表す構造体
struct Polyomino: Identifiable, Equatable {
    let id: UUID
    var cells: [Cell] // 相対座標（0,0を基準点として）
    var color: Color
    
    struct Cell: Hashable {
        let x: Int
        let y: Int
    }
    
    // 回転（90度時計回り）
    func rotated() -> Polyomino {
        let rotatedCells = cells.map { cell in
            Cell(x: -cell.y, y: cell.x)
        }
        return Polyomino(id: id, cells: rotatedCells, color: color)
    }
    
    // ミラー（左右反転）
    func mirrored() -> Polyomino {
        let mirroredCells = cells.map { cell in
            Cell(x: -cell.x, y: cell.y)
        }
        return Polyomino(id: id, cells: mirroredCells, color: color)
    }
}

// ポリオミノの形状定義（4〜6マス）
struct PolyominoShapes {
    static let tetrominoes: [Polyomino] = [
        // I型（4マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 2, y: 0),
            Polyomino.Cell(x: 3, y: 0)
        ], color: .brown1),
        
        // O型（4マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1)
        ], color: .brown2),
        
        // T型（4マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 2, y: 1)
        ], color: .brown3),
        
        // L型（4マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 0, y: 2),
            Polyomino.Cell(x: 1, y: 2)
        ], color: .brown4),
        
        // S型（4マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 2, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1)
        ], color: .brown5)
    ]
    
    static let pentominoes: [Polyomino] = [
        // F型（5マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 2, y: 1),
            Polyomino.Cell(x: 0, y: 2)
        ], color: .brown1),
        
        // P型（5マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 0, y: 2)
        ], color: .brown2),
        
        // U型（5マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 2, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 2, y: 1)
        ], color: .brown3),
        
        // V型（5マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 0, y: 2),
            Polyomino.Cell(x: 1, y: 2),
            Polyomino.Cell(x: 2, y: 2)
        ], color: .brown4),
        
        // W型（5マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 2, y: 1),
            Polyomino.Cell(x: 2, y: 2)
        ], color: .brown5),
        
        // X型（5マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 2, y: 1),
            Polyomino.Cell(x: 1, y: 2)
        ], color: .brown1),
        
        // Y型（5マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 1, y: 2),
            Polyomino.Cell(x: 1, y: 3)
        ], color: .brown2),
        
        // Z型（5マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 1, y: 2),
            Polyomino.Cell(x: 2, y: 2)
        ], color: .brown3)
    ]
    
    static let hexominoes: [Polyomino] = [
        // 長方形型（6マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 2, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 2, y: 1)
        ], color: .brown4),
        
        // L型（6マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 0, y: 2),
            Polyomino.Cell(x: 0, y: 3),
            Polyomino.Cell(x: 1, y: 3),
            Polyomino.Cell(x: 2, y: 3)
        ], color: .brown5),
        
        // T型（6マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 2, y: 0),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 1, y: 2),
            Polyomino.Cell(x: 1, y: 3)
        ], color: .brown1),
        
        // S型（6マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 2, y: 0),
            Polyomino.Cell(x: 0, y: 1),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 2, y: 2),
            Polyomino.Cell(x: 3, y: 2)
        ], color: .brown2),
        
        // 階段型（6マス）
        Polyomino(id: UUID(), cells: [
            Polyomino.Cell(x: 0, y: 0),
            Polyomino.Cell(x: 1, y: 0),
            Polyomino.Cell(x: 1, y: 1),
            Polyomino.Cell(x: 2, y: 1),
            Polyomino.Cell(x: 2, y: 2),
            Polyomino.Cell(x: 3, y: 2)
        ], color: .brown3)
    ]
    
    // 難易度に応じたポリオミノを返す（合計100マスになるように調整）
    static func getPolyominoes(for difficulty: Difficulty) -> [Polyomino] {
        switch difficulty {
        case .easy:
            // テトロミノ（4マス）を25個 = 100マス
            // 5種類を5回ずつ使用
            var result: [Polyomino] = []
            for _ in 0..<5 {
                for tetromino in tetrominoes {
                    result.append(Polyomino(id: UUID(), cells: tetromino.cells, color: tetromino.color))
                }
            }
            return result
            
        case .medium:
            // テトロミノ（4マス）5種類 + ペントミノ（5マス）16個 = 20 + 80 = 100マス
            // ペントミノを2回ずつ使用（8種類 × 2 = 16個）
            var result: [Polyomino] = []
            result.append(contentsOf: tetrominoes.map { Polyomino(id: UUID(), cells: $0.cells, color: $0.color) })
            for _ in 0..<2 {
                for pentomino in pentominoes {
                    result.append(Polyomino(id: UUID(), cells: pentomino.cells, color: pentomino.color))
                }
            }
            return result
            
        case .hard:
            // テトロミノ（4マス）5種類 + ペントミノ（5マス）8種類 + ヘキソミノ（6マス）10個 = 20 + 40 + 60 = 120マス
            // または、テトロミノ5種類 + ペントミノ8種類 + ヘキソミノ5種類 + 追加のペントミノ4個 = 20 + 40 + 30 + 20 = 110マス
            // より良い組み合わせ: テトロミノ5種類 + ペントミノ12種類 + ヘキソミノ5種類 = 20 + 60 + 30 = 110マス
            // 最適: テトロミノ5種類 + ペントミノ8種類 + ヘキソミノ10個 = 20 + 40 + 60 = 120マス（少し多め）
            // 正確に100マス: テトロミノ5種類 + ペントミノ8種類 + ヘキソミノ5種類 + テトロミノ5個 = 20 + 40 + 30 + 20 = 110マス
            // より良い: テトロミノ5種類 + ペントミノ10種類 + ヘキソミノ5種類 = 20 + 50 + 30 = 100マス（正確！）
            var result: [Polyomino] = []
            result.append(contentsOf: tetrominoes.map { Polyomino(id: UUID(), cells: $0.cells, color: $0.color) })
            // ペントミノを10個（8種類から2個追加）
            for pentomino in pentominoes {
                result.append(Polyomino(id: UUID(), cells: pentomino.cells, color: pentomino.color))
            }
            // 追加のペントミノ2個（最初の2種類を追加）
            for i in 0..<2 {
                result.append(Polyomino(id: UUID(), cells: pentominoes[i].cells, color: pentominoes[i].color))
            }
            result.append(contentsOf: hexominoes.map { Polyomino(id: UUID(), cells: $0.cells, color: $0.color) })
            return result
        }
    }
}

// 難易度
enum Difficulty: String, CaseIterable {
    case easy = "簡単"
    case medium = "普通"
    case hard = "難しい"
}

// 茶色系のカラー定義
extension Color {
    static let brown1 = Color(red: 0.6, green: 0.4, blue: 0.2)
    static let brown2 = Color(red: 0.7, green: 0.5, blue: 0.3)
    static let brown3 = Color(red: 0.65, green: 0.45, blue: 0.25)
    static let brown4 = Color(red: 0.55, green: 0.35, blue: 0.15)
    static let brown5 = Color(red: 0.75, green: 0.55, blue: 0.35)
    static let woodBackground = Color(red: 0.85, green: 0.75, blue: 0.65)
    static let woodDark = Color(red: 0.4, green: 0.3, blue: 0.2)
    static let woodLight = Color(red: 0.9, green: 0.8, blue: 0.7)
}

