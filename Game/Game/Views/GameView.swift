import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var selectedPolyomino: Polyomino?
    @State private var rotatedPolyomino: Polyomino?
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        ZStack {
            // 背景（木材風）
            Color.woodBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // タイトルと難易度選択
                HStack {
                    Text("ポリオミノパズル")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.woodDark)
                    
                    Spacer()
                    
                    // 難易度選択
                    Picker("難易度", selection: $viewModel.selectedDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    .onChange(of: viewModel.selectedDifficulty) { newValue in
                        viewModel.changeDifficulty(newValue)
                        selectedPolyomino = nil
                    }
                }
                .padding(.horizontal)
                
                // ゲームボード
                BoardView(
                    gameBoard: viewModel.gameBoard,
                    selectedPolyomino: rotatedPolyomino ?? selectedPolyomino,
                    dragOffset: isDragging ? dragOffset : .zero,
                    onCellTap: { col, row in
                        if let polyomino = rotatedPolyomino ?? selectedPolyomino {
                            let position = GameBoard.PlacedPolyomino.Position(x: col, y: row)
                            if viewModel.placePolyomino(polyomino, at: position) {
                                selectedPolyomino = nil
                                rotatedPolyomino = nil
                            }
                        }
                    }
                )
                .frame(width: 350, height: 350)
                
                // 利用可能なポリオミノ
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.availablePolyominoes) { polyomino in
                            PolyominoView(polyomino: polyomino)
                                .scaleEffect(selectedPolyomino?.id == polyomino.id ? 1.1 : 1.0)
                                .opacity(selectedPolyomino?.id == polyomino.id ? 0.7 : 1.0)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            if selectedPolyomino?.id != polyomino.id {
                                                selectedPolyomino = polyomino
                                                rotatedPolyomino = polyomino
                                            }
                                            isDragging = true
                                            dragOffset = value.translation
                                        }
                                        .onEnded { value in
                                            isDragging = false
                                            dragOffset = .zero
                                            // ボード上にドロップされたかチェック
                                            handleDrop(at: value.location)
                                        }
                                )
                                .onTapGesture {
                                    if selectedPolyomino?.id == polyomino.id {
                                        // 回転
                                        rotatedPolyomino = (rotatedPolyomino ?? polyomino).rotated()
                                    } else {
                                        selectedPolyomino = polyomino
                                        rotatedPolyomino = polyomino
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
                
                // 操作説明
                HStack {
                    Text("💡 タップ: 回転 | ドラッグ: 配置")
                        .font(.caption)
                        .foregroundColor(.woodDark.opacity(0.7))
                }
                
                // リセットボタン
                Button(action: {
                    viewModel.startNewGame()
                    selectedPolyomino = nil
                    rotatedPolyomino = nil
                }) {
                    Text("リセット")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.woodDark)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            
            // ドラッグ中のポリオミノ表示
            if let polyomino = rotatedPolyomino ?? selectedPolyomino, isDragging {
                DraggingPolyominoView(
                    polyomino: polyomino,
                    offset: dragOffset
                )
            }
            
            // ゲームクリアメッセージ
            if viewModel.isGameComplete {
                GameCompleteView {
                    viewModel.startNewGame()
                    selectedPolyomino = nil
                    rotatedPolyomino = nil
                }
            }
        }
        .environmentObject(viewModel)
    }
    
    private func handleDrop(at location: CGPoint) {
        guard let polyomino = rotatedPolyomino ?? selectedPolyomino else { return }
        
        // ボードの中心位置（350x350のフレームの中心）
        let boardCenterX: CGFloat = 175
        let boardCenterY: CGFloat = 175
        
        // ボードの左上からの相対位置
        let relativeX = location.x - boardCenterX + 175
        let relativeY = location.y - boardCenterY + 175
        
        // セルサイズとスペーシング
        let cellSize: CGFloat = 30
        let spacing: CGFloat = 2
        let boardPadding: CGFloat = 10
        
        // グリッド座標に変換
        let boardX = Int((relativeX - boardPadding) / (cellSize + spacing))
        let boardY = Int((relativeY - boardPadding) / (cellSize + spacing))
        
        // 範囲チェック
        guard boardX >= 0 && boardX < 10 && boardY >= 0 && boardY < 10 else {
            return
        }
        
        let position = GameBoard.PlacedPolyomino.Position(x: boardX, y: boardY)
        
        if viewModel.placePolyomino(polyomino, at: position) {
            selectedPolyomino = nil
            rotatedPolyomino = nil
        }
    }
}

struct BoardView: View {
    @ObservedObject var gameBoard: GameBoard
    @EnvironmentObject var viewModel: GameViewModel
    let selectedPolyomino: Polyomino?
    let dragOffset: CGSize
    let onCellTap: (Int, Int) -> Void
    
    let cellSize: CGFloat = 30
    let spacing: CGFloat = 2
    let boardPadding: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // ボードの背景
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.woodLight)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                
                // グリッド
                VStack(spacing: spacing) {
                    ForEach(0..<gameBoard.size, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<gameBoard.size, id: \.self) { col in
                                CellView(isFilled: gameBoard.grid[row][col])
                                    .frame(width: cellSize, height: cellSize)
                                    .onTapGesture {
                                        onCellTap(col, row)
                                    }
                            }
                        }
                    }
                }
                .padding(boardPadding)
                
                // 配置済みポリオミノ
                ForEach(gameBoard.placedPolyominoes) { placed in
                    PlacedPolyominoView(
                        polyomino: placed.polyomino,
                        position: placed.position,
                        cellSize: cellSize,
                        spacing: spacing,
                        boardPadding: boardPadding
                    )
                    .onTapGesture {
                        // タップで削除
                        viewModel.gameBoard.removePolyomino(withId: placed.id)
                    }
                }
                
                // プレビュー表示（選択中のポリオミノ）
                if let polyomino = selectedPolyomino {
                    PreviewPolyominoView(
                        polyomino: polyomino,
                        dragOffset: dragOffset,
                        cellSize: cellSize,
                        spacing: spacing,
                        boardPadding: boardPadding,
                        boardSize: geometry.size
                    )
                }
            }
        }
    }
}

struct CellView: View {
    let isFilled: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(isFilled ? Color.woodDark : Color.white.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.woodDark.opacity(0.3), lineWidth: 1)
            )
    }
}

struct PlacedPolyominoView: View {
    let polyomino: Polyomino
    let position: GameBoard.PlacedPolyomino.Position
    let cellSize: CGFloat
    let spacing: CGFloat
    let boardPadding: CGFloat = 10
    
    var body: some View {
        ForEach(Array(polyomino.cells.enumerated()), id: \.offset) { _, cell in
            let x = CGFloat(position.x + cell.x) * (cellSize + spacing) + boardPadding
            let y = CGFloat(position.y + cell.y) * (cellSize + spacing) + boardPadding
            
            RoundedRectangle(cornerRadius: 3)
                .fill(polyomino.color)
                .frame(width: cellSize, height: cellSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.woodDark.opacity(0.5), lineWidth: 1)
                )
                .position(x: x + cellSize/2, y: y + cellSize/2)
        }
    }
}

struct PreviewPolyominoView: View {
    let polyomino: Polyomino
    let dragOffset: CGSize
    let cellSize: CGFloat
    let spacing: CGFloat
    let boardPadding: CGFloat
    let boardSize: CGSize
    
    var body: some View {
        let centerX = boardSize.width / 2 + dragOffset.width
        let centerY = boardSize.height / 2 + dragOffset.height
        
        ForEach(Array(polyomino.cells.enumerated()), id: \.offset) { _, cell in
            let offsetX = CGFloat(cell.x) * (cellSize + spacing)
            let offsetY = CGFloat(cell.y) * (cellSize + spacing)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(polyomino.color.opacity(0.6))
                .frame(width: cellSize, height: cellSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(polyomino.color, lineWidth: 2)
                )
                .position(
                    x: centerX + offsetX,
                    y: centerY + offsetY
                )
        }
    }
}

struct DraggingPolyominoView: View {
    let polyomino: Polyomino
    let offset: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2 + offset.width
            let centerY = geometry.size.height / 2 + offset.height
            
            ForEach(Array(polyomino.cells.enumerated()), id: \.offset) { _, cell in
                RoundedRectangle(cornerRadius: 3)
                    .fill(polyomino.color.opacity(0.8))
                    .frame(width: 20, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.woodDark, lineWidth: 2)
                    )
                    .position(
                        x: centerX + CGFloat(cell.x) * 22,
                        y: centerY + CGFloat(cell.y) * 22
                    )
            }
        }
    }
}

struct PolyominoView: View {
    let polyomino: Polyomino
    let cellSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.2))
                .frame(width: 100, height: 100)
            
            // ポリオミノの形状
            ForEach(Array(polyomino.cells.enumerated()), id: \.offset) { _, cell in
                RoundedRectangle(cornerRadius: 2)
                    .fill(polyomino.color)
                    .frame(width: cellSize, height: cellSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.woodDark.opacity(0.5), lineWidth: 1)
                    )
                    .offset(
                        x: CGFloat(cell.x) * cellSize - CGFloat(polyomino.cells.map { $0.x }.min() ?? 0) * cellSize,
                        y: CGFloat(cell.y) * cellSize - CGFloat(polyomino.cells.map { $0.y }.min() ?? 0) * cellSize
                    )
            }
        }
    }
}

struct GameCompleteView: View {
    let onReset: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🎉 完成！")
                    .font(.system(size: 48))
                
                Text("おめでとうございます！")
                    .font(.title2)
                    .foregroundColor(.woodDark)
                
                Button(action: onReset) {
                    Text("もう一度")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.woodDark)
                        .cornerRadius(10)
                }
            }
            .padding(40)
            .background(Color.woodLight)
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}

#Preview {
    GameView()
}

