import Foundation
import SwiftUI

// 完成系をランダムに切り分けてポリオミノを生成
struct PuzzleGenerator {
    // 切り取った領域と残りの盤面の状態を返す
    struct PuzzleResult {
        let polyominoes: [Polyomino]
        let filledGrid: [[Bool]]  // 残りの盤面の状態（true = 埋まっている）
    }
    static func generateSolvablePuzzle(for difficulty: Difficulty) -> [Polyomino] {
        let boardSize = 10
        var grid = Array(repeating: Array(repeating: false, count: boardSize), count: boardSize)
        var polyominoes: [Polyomino] = []
        
        // 難易度に応じた最小・最大セル数
        let (minCells, maxCells): (Int, Int)
        switch difficulty {
        case .easy:
            minCells = 4
            maxCells = 4
        case .medium:
            minCells = 4
            maxCells = 5
        case .hard:
            minCells = 4
            maxCells = 6
        }
        
        // ランダムにセルを選択してポリオミノを生成
        var availableCells: [(x: Int, y: Int)] = []
        for y in 0..<boardSize {
            for x in 0..<boardSize {
                availableCells.append((x: x, y: y))
            }
        }
        availableCells.shuffle()
        
        var cellIndex = 0
        var polyominoId = 0
        
        while cellIndex < availableCells.count {
            let startCell = availableCells[cellIndex]
            
            // 既に使用されているセルはスキップ
            if grid[startCell.y][startCell.x] {
                cellIndex += 1
                continue
            }
            
            // ランダムなサイズのポリオミノを生成
            let targetSize = Int.random(in: minCells...maxCells)
            let cells = generatePolyominoShape(
                start: startCell,
                size: targetSize,
                grid: &grid,
                boardSize: boardSize
            )
            
            if cells.count == targetSize {
                // 色をランダムに選択
                let colors: [Color] = [.brown1, .brown2, .brown3, .brown4, .brown5]
                let color = colors.randomElement() ?? .brown1
                
                let polyomino = Polyomino(
                    id: UUID(),
                    cells: cells.map { Polyomino.Cell(x: $0.x, y: $0.y) },
                    color: color
                )
                polyominoes.append(polyomino)
                
                // グリッドを更新
                for cell in cells {
                    grid[cell.y][cell.x] = true
                }
            }
            
            cellIndex += 1
        }
        
        // 相対座標に変換（最初のセルを(0,0)に）
        return polyominoes.map { polyomino in
            let minX = polyomino.cells.map { $0.x }.min() ?? 0
            let minY = polyomino.cells.map { $0.y }.min() ?? 0
            
            let relativeCells = polyomino.cells.map { cell in
                Polyomino.Cell(x: cell.x - minX, y: cell.y - minY)
            }
            
            return Polyomino(id: polyomino.id, cells: relativeCells, color: polyomino.color)
        }
    }
    
    // ランダムにポリオミノの形状を生成（BFSを使用）
    private static func generatePolyominoShape(
        start: (x: Int, y: Int),
        size: Int,
        grid: inout [[Bool]],
        boardSize: Int
    ) -> [(x: Int, y: Int)] {
        var visited: Set<String> = []
        var queue: [(x: Int, y: Int)] = [start]
        var result: [(x: Int, y: Int)] = []
        
        // グリッドの実際のサイズを取得
        let gridHeight = grid.count
        let gridWidth = gridHeight > 0 ? grid[0].count : 0
        
        while !queue.isEmpty && result.count < size {
            let current = queue.removeFirst()
            let key = "\(current.x),\(current.y)"
            
            // 範囲チェック
            if current.x < 0 || current.x >= gridWidth || current.y < 0 || current.y >= gridHeight {
                continue
            }
            
            if visited.contains(key) || grid[current.y][current.x] {
                continue
            }
            
            visited.insert(key)
            result.append(current)
            
            if result.count >= size {
                break
            }
            
            // 隣接セルをランダムな順序で追加
            let neighbors = [
                (x: current.x + 1, y: current.y),
                (x: current.x - 1, y: current.y),
                (x: current.x, y: current.y + 1),
                (x: current.x, y: current.y - 1)
            ].shuffled()
            
            for neighbor in neighbors {
                if neighbor.x >= 0 && neighbor.x < gridWidth &&
                   neighbor.y >= 0 && neighbor.y < gridHeight &&
                   !grid[neighbor.y][neighbor.x] &&
                   !visited.contains("\(neighbor.x),\(neighbor.y)") {
                    queue.append(neighbor)
                }
            }
        }
        
        return result
    }
    
    // グリッド内で利用可能なセル数をカウント（BFS）
    private static func countAvailableCellsInGrid(
        from start: (x: Int, y: Int),
        in grid: [[Bool]],
        width: Int,
        height: Int
    ) -> Int {
        var visited: Set<String> = []
        var queue: [(x: Int, y: Int)] = [start]
        var count = 0
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let key = "\(current.x),\(current.y)"
            
            if visited.contains(key) {
                continue
            }
            
            if current.x < 0 || current.x >= width || current.y < 0 || current.y >= height {
                continue
            }
            
            if !grid[current.y][current.x] {
                continue  // 既に使用されているセル
            }
            
            visited.insert(key)
            count += 1
            
            let neighbors = [
                (x: current.x + 1, y: current.y),
                (x: current.x - 1, y: current.y),
                (x: current.x, y: current.y + 1),
                (x: current.x, y: current.y - 1)
            ]
            
            for neighbor in neighbors {
                if neighbor.x >= 0 && neighbor.x < width &&
                   neighbor.y >= 0 && neighbor.y < height &&
                   grid[neighbor.y][neighbor.x] &&
                   !visited.contains("\(neighbor.x),\(neighbor.y)") {
                    queue.append(neighbor)
                }
            }
        }
        
        return count
    }
    
    // セルのグループを難易度に応じたサイズのポリオミノに分割（シンプル版）
    private static func splitIntoPolyominoesSimple(
        cells: [(x: Int, y: Int)],
        minSize: Int,
        maxSize: Int
    ) -> [[(x: Int, y: Int)]] {
        var result: [[(x: Int, y: Int)]] = []
        var allCells = Set(cells.map { "\($0.x),\($0.y)" })
        var used: Set<String> = []
        
        // 全てのセルが処理されるまで繰り返す
        while used.count < allCells.count {
            var currentGroup: [(x: Int, y: Int)] = []
            var queue: [(x: Int, y: Int)] = []
            
            // 最初の未使用セルを見つける
            for cell in cells {
                let key = "\(cell.x),\(cell.y)"
                if !used.contains(key) && allCells.contains(key) {
                    queue.append(cell)
                    used.insert(key)
                    break
                }
            }
            
            if queue.isEmpty {
                break
            }
            
            // BFSで接続されたセルを集める（最大サイズまで）
            while !queue.isEmpty && currentGroup.count < maxSize {
                let current = queue.removeFirst()
                
                if currentGroup.contains(where: { $0.x == current.x && $0.y == current.y }) {
                    continue
                }
                
                currentGroup.append(current)
                
                // 残りのセルから隣接セルを探す
                var foundNeighbor = false
                for cell in cells {
                    let key = "\(cell.x),\(cell.y)"
                    if !used.contains(key) && allCells.contains(key) {
                        let isNeighbor = abs(cell.x - current.x) + abs(cell.y - current.y) == 1
                        if isNeighbor && currentGroup.count < maxSize {
                            queue.append(cell)
                            used.insert(key)
                            foundNeighbor = true
                            break
                        }
                    }
                }
                
                // 隣接セルが見つからない場合は終了
                if !foundNeighbor && queue.isEmpty {
                    break
                }
            }
            
            // 最小サイズに満たない場合は、残りのセルから辺で接続されている最も近いものを追加
            // ただし、サイズ1のミノも許容するため、追加できない場合はそのまま生成
            while currentGroup.count < minSize && used.count < allCells.count {
                var foundAdjacent = false
                
                // 辺で接続されているセル（距離=1）のみを探す
                for cell in cells {
                    let key = "\(cell.x),\(cell.y)"
                    if !used.contains(key) && allCells.contains(key) {
                        // 現在のグループのセルと辺で接続されているかチェック
                        let isAdjacent = currentGroup.contains { existingCell in
                            abs(existingCell.x - cell.x) + abs(existingCell.y - cell.y) == 1
                        }
                        
                        if isAdjacent {
                            currentGroup.append(cell)
                            used.insert(key)
                            foundAdjacent = true
                            break
                        }
                    }
                }
                
                if !foundAdjacent {
                    // 辺で接続されているセルがない場合は、現在のグループをそのまま生成（サイズ1も許容）
                    break
                }
            }
            
            // サイズ1のミノも許容するため、空でない場合は必ず追加
            if !currentGroup.isEmpty {
                result.append(currentGroup)
            }
        }
        
        // 残りのセルを個別のポリオミノとして追加（確実に全てのセルをカバー）
        for cell in cells {
            let key = "\(cell.x),\(cell.y)"
            if !used.contains(key) && allCells.contains(key) {
                result.append([cell])
                used.insert(key)
            }
        }
        
        return result
    }
    
    // 正解の盤面から一部を切り取ってポリオミノを生成
    static func generatePuzzleWithCutRegion(for difficulty: Difficulty) -> PuzzleResult {
        let boardSize = 10
        
        // 切り取る領域のサイズを決定
        let (cutWidth, cutHeight): (Int, Int)
        switch difficulty {
        case .easy:
            cutWidth = 5
            cutHeight = 4  // 右上5×4マス
        case .medium:
            cutWidth = 7
            cutHeight = 7  // 右上7×7マス
        case .hard:
            cutWidth = 10
            cutHeight = 10  // 全体（実際には使わない）
        default:
            cutWidth = 5
            cutHeight = 4
        }
        
        // 切り取る領域の位置（右上）
        let cutStartX = boardSize - cutWidth
        let cutStartY = 0
        
        // まず正解の盤面を生成（全体を埋める）
        var fullGrid = Array(repeating: Array(repeating: false, count: boardSize), count: boardSize)
        var allPolyominoes: [Polyomino] = []
        
        // 難易度に応じた最小・最大セル数
        let (minCells, maxCells): (Int, Int)
        switch difficulty {
        case .easy:
            minCells = 4
            maxCells = 4
        case .medium:
            minCells = 4
            maxCells = 5
        case .hard:
            minCells = 4
            maxCells = 6
        }
        
        // 全体を埋める
        var availableCells: [(x: Int, y: Int)] = []
        for y in 0..<boardSize {
            for x in 0..<boardSize {
                availableCells.append((x: x, y: y))
            }
        }
        availableCells.shuffle()
        
        var cellIndex = 0
        var attempts = 0
        let maxAttempts = availableCells.count * 10
        
        while cellIndex < availableCells.count && attempts < maxAttempts {
            attempts += 1
            let startCell = availableCells[cellIndex]
            
            if fullGrid[startCell.y][startCell.x] {
                cellIndex += 1
                continue
            }
            
            let targetSize = Int.random(in: minCells...maxCells)
            let cells = generatePolyominoShape(
                start: startCell,
                size: targetSize,
                grid: &fullGrid,
                boardSize: boardSize
            )
            
            if cells.count == targetSize {
                let colors: [Color] = [.brown1, .brown2, .brown3, .brown4, .brown5]
                let color = colors.randomElement() ?? .brown1
                
                let polyomino = Polyomino(
                    id: UUID(),
                    cells: cells.map { Polyomino.Cell(x: $0.x, y: $0.y) },
                    color: color
                )
                allPolyominoes.append(polyomino)
                
                for cell in cells {
                    fullGrid[cell.y][cell.x] = true
                }
            }
            
            cellIndex += 1
        }
        
        // 残りのセルを個別のポリオミノとして追加（確実に全てのセルを埋める）
        for y in 0..<boardSize {
            for x in 0..<boardSize {
                if !fullGrid[y][x] {
                    let colors: [Color] = [.brown1, .brown2, .brown3, .brown4, .brown5]
                    let color = colors.randomElement() ?? .brown1
                    
                    let polyomino = Polyomino(
                        id: UUID(),
                        cells: [Polyomino.Cell(x: 0, y: 0)],
                        color: color
                    )
                    allPolyominoes.append(polyomino)
                    fullGrid[y][x] = true
                }
            }
        }
        
        // 切り取る領域のセルを抽出
        var cutRegionCells: [(x: Int, y: Int)] = []
        for y in cutStartY..<(cutStartY + cutHeight) {
            for x in cutStartX..<(cutStartX + cutWidth) {
                if y < boardSize && x < boardSize {
                    cutRegionCells.append((x: x, y: y))
                }
            }
        }
        
        // 切り取った領域を空にする（グリッドから削除）
        var resultGrid = fullGrid
        for cell in cutRegionCells {
            resultGrid[cell.y][cell.x] = false
        }
        
        // 切り取った領域を空きマスから直接ポリオミノを生成
        // まず、切り取った領域の全てのセルをマーク
        var cutGrid = Array(repeating: Array(repeating: false, count: cutWidth), count: cutHeight)
        var cutAvailableCells: [(x: Int, y: Int)] = []
        for cell in cutRegionCells {
            let relativeX = cell.x - cutStartX
            let relativeY = cell.y - cutStartY
            if relativeX >= 0 && relativeX < cutWidth && relativeY >= 0 && relativeY < cutHeight {
                cutGrid[relativeY][relativeX] = true  // true = 空きセル（まだポリオミノに割り当てられていない）
                cutAvailableCells.append((x: relativeX, y: relativeY))
            }
        }
        
        var cutPolyominoes: [Polyomino] = []
        let colors: [Color] = [.brown1, .brown2, .brown3, .brown4, .brown5]
        
        // 空きマスから直接ポリオミノを生成
        // cutGridを直接ループして、確実に全てのセルを処理
        var processed: Set<String> = []
        
        for y in 0..<cutHeight {
            for x in 0..<cutWidth {
                let key = "\(x),\(y)"
                
                // 既に処理済みまたは使用済みのセルはスキップ
                if !cutGrid[y][x] || processed.contains(key) {
                    continue
                }
                
                // 接続されたセルを2〜3個集める
                var polyominoCells: [(x: Int, y: Int)] = [(x: x, y: y)]
                cutGrid[y][x] = false  // 使用済みとしてマーク
                processed.insert(key)
                
                // 隣接する空きマスを探す（最大2個まで追加して、合計3個まで）
                var queue: [(x: Int, y: Int)] = [(x: x, y: y)]
                var visited: Set<String> = [key]
                
                while !queue.isEmpty && polyominoCells.count < 3 {
                    let current = queue.removeFirst()
                    
                    // 隣接セルを探す
                    let neighbors = [
                        (x: current.x + 1, y: current.y),
                        (x: current.x - 1, y: current.y),
                        (x: current.x, y: current.y + 1),
                        (x: current.x, y: current.y - 1)
                    ]
                    
                    var foundNeighbor = false
                    for neighbor in neighbors.shuffled() {
                        if neighbor.x >= 0 && neighbor.x < cutWidth &&
                           neighbor.y >= 0 && neighbor.y < cutHeight {
                            let neighborKey = "\(neighbor.x),\(neighbor.y)"
                            
                            if !visited.contains(neighborKey) && cutGrid[neighbor.y][neighbor.x] {
                                polyominoCells.append(neighbor)
                                cutGrid[neighbor.y][neighbor.x] = false
                                visited.insert(neighborKey)
                                processed.insert(neighborKey)
                                foundNeighbor = true
                                
                                if polyominoCells.count >= 3 {
                                    break
                                }
                                
                                // さらに隣接セルを探すためにキューに追加
                                queue.append(neighbor)
                                break  // 1つずつ追加
                            }
                        }
                    }
                    
                    if !foundNeighbor && queue.isEmpty {
                        break
                    }
                }
                
                // ポリオミノを生成（1マス、2マス、3マスのいずれか）
                if !polyominoCells.isEmpty {
                    let color = colors.randomElement() ?? .brown1
                    
                    // 相対座標に変換
                    let minX = polyominoCells.map { $0.x }.min() ?? 0
                    let minY = polyominoCells.map { $0.y }.min() ?? 0
                    
                    let relativeCells = polyominoCells.map { cell in
                        Polyomino.Cell(x: cell.x - minX, y: cell.y - minY)
                    }
                    
                    let polyomino = Polyomino(
                        id: UUID(),
                        cells: relativeCells,
                        color: color
                    )
                    cutPolyominoes.append(polyomino)
                }
            }
        }
        
        // 残りのセル（1マスだけの飛地など）を個別のポリオミノとして追加（念のため）
        for y in 0..<cutHeight {
            for x in 0..<cutWidth {
                if cutGrid[y][x] {
                    let color = colors.randomElement() ?? .brown1
                    let polyomino = Polyomino(
                        id: UUID(),
                        cells: [Polyomino.Cell(x: 0, y: 0)],
                        color: color
                    )
                    cutPolyominoes.append(polyomino)
                    cutGrid[y][x] = false
                }
            }
        }
        
        return PuzzleResult(polyominoes: cutPolyominoes, filledGrid: resultGrid)
    }
}

