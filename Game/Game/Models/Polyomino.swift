import Foundation

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
    
    // 難易度に応じたポリオミノを返す
    static func getPolyominoes(for difficulty: Difficulty) -> [Polyomino] {
        switch difficulty {
        case .easy:
            return tetrominoes
        case .medium:
            return tetrominoes + pentominoes
        case .hard:
            return tetrominoes + pentominoes + hexominoes
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

