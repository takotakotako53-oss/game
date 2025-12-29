import Foundation

// ゲームボードの状態を管理
class GameBoard: ObservableObject {
    @Published var grid: [[Bool]] // true = 埋まっている
    @Published var placedPolyominoes: [PlacedPolyomino] = []
    
    let size = 10
    
    struct PlacedPolyomino: Identifiable {
        let id: UUID
        let polyomino: Polyomino
        let position: Position
        
        struct Position {
            let x: Int
            let y: Int
        }
    }
    
    init() {
        grid = Array(repeating: Array(repeating: false, count: size), count: size)
    }
    
    // ポリオミノを配置できるかチェック
    func canPlace(_ polyomino: Polyomino, at position: PlacedPolyomino.Position) -> Bool {
        for cell in polyomino.cells {
            let x = position.x + cell.x
            let y = position.y + cell.y
            
            // 範囲外チェック
            if x < 0 || x >= size || y < 0 || y >= size {
                return false
            }
            
            // 既に埋まっているかチェック
            if grid[y][x] {
                return false
            }
        }
        return true
    }
    
    // ポリオミノを配置
    func place(_ polyomino: Polyomino, at position: PlacedPolyomino.Position) -> Bool {
        guard canPlace(polyomino, at: position) else {
            return false
        }
        
        // グリッドを更新
        for cell in polyomino.cells {
            let x = position.x + cell.x
            let y = position.y + cell.y
            grid[y][x] = true
        }
        
        // 配置済みリストに追加
        placedPolyominoes.append(PlacedPolyomino(
            id: polyomino.id,
            polyomino: polyomino,
            position: position
        ))
        
        return true
    }
    
    // ポリオミノを削除
    func removePolyomino(withId id: UUID) {
        guard let index = placedPolyominoes.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let placed = placedPolyominoes[index]
        
        // グリッドを更新
        for cell in placed.polyomino.cells {
            let x = placed.position.x + cell.x
            let y = placed.position.y + cell.y
            grid[y][x] = false
        }
        
        placedPolyominoes.remove(at: index)
    }
    
    // ゲームクリア判定
    func isComplete() -> Bool {
        return grid.allSatisfy { row in
            row.allSatisfy { $0 }
        }
    }
    
    // リセット
    func reset() {
        grid = Array(repeating: Array(repeating: false, count: size), count: size)
        placedPolyominoes = []
    }
}

