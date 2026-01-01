import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameBoard = GameBoard()
    @Published var availablePolyominoes: [Polyomino] = []
    @Published var selectedDifficulty: Difficulty = .medium
    @Published var isGameComplete = false
    @Published var draggingPolyomino: Polyomino?
    @Published var dragPosition: CGPoint = .zero
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        gameBoard.reset()
        isGameComplete = false
        
        switch selectedDifficulty {
        case .easy, .medium:
            // 正解の盤面から一部を切り取る方法
            let result = PuzzleGenerator.generatePuzzleWithCutRegion(for: selectedDifficulty)
            
            // 残りの盤面の状態を設定
            gameBoard.grid = result.filledGrid
            
            // 切り取った領域のポリオミノを利用可能リストに追加
            availablePolyominoes = result.polyominoes
            
        case .hard:
            // 現在の実装のまま（全体をランダムに切り分ける）
            availablePolyominoes = PuzzleGenerator.generateSolvablePuzzle(for: selectedDifficulty)
        }
    }
    
    func changeDifficulty(_ difficulty: Difficulty) {
        selectedDifficulty = difficulty
        startNewGame()
    }
    
    func rotatePolyomino(_ polyomino: Polyomino) -> Polyomino {
        return polyomino.rotated()
    }
    
    func placePolyomino(_ polyomino: Polyomino, at position: GameBoard.PlacedPolyomino.Position) -> Bool {
        let success = gameBoard.place(polyomino, at: position)
        if success {
            // 配置されたポリオミノを利用可能リストから削除
            availablePolyominoes.removeAll { $0.id == polyomino.id }
            
            // ゲームクリア判定
            if gameBoard.isComplete() {
                isGameComplete = true
            }
        }
        return success
    }
    
    func removePolyomino(withId id: UUID) {
        gameBoard.removePolyomino(withId: id)
        // ポリオミノを利用可能リストに戻す（元の形状を復元）
        // これは簡略化のため、実際には元の形状を保持する必要がある
    }
}

