import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var selectedPolyomino: Polyomino?
    @State private var rotatedPolyomino: Polyomino?
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var dragStartLocation: CGPoint = .zero
    @State private var polyominoViewFrame: CGRect = .zero
    
    var body: some View {
        ZStack {
            // 背景（木材風）
            Color.woodBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // タイトルと難易度選択
                HStack {
                    Text("パズル")
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
                        // 盤面のセルをタップした時
                        if let polyomino = rotatedPolyomino ?? selectedPolyomino {
                            // 選択中のミノがある場合は配置を試みる
                            let position = GameBoard.PlacedPolyomino.Position(x: col, y: row)
                            if viewModel.placePolyomino(polyomino, at: position) {
                                selectedPolyomino = nil
                                rotatedPolyomino = nil
                            }
                        } else {
                            // 選択中のミノがない場合は、選択状態をキャンセル
                            selectedPolyomino = nil
                            rotatedPolyomino = nil
                        }
                    },
                    onDrop: { location in
                        // ドロップ時の処理
                        handleDrop(at: location)
                    },
                    onDragChanged: { offset in
                        isDragging = true
                        dragOffset = offset
                    },
                    onDragEnded: { location in
                        isDragging = false
                        handleDrop(at: location)
                        dragOffset = .zero
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
                                .onTapGesture {
                                    if selectedPolyomino?.id == polyomino.id {
                                        // 選択中のミノを再度タップで回転
                                        rotatedPolyomino = (rotatedPolyomino ?? polyomino).rotated()
                                    } else {
                                        // 新しいミノを選択
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
        
        // セルサイズとスペーシング
        let cellSize: CGFloat = 30
        let spacing: CGFloat = 2
        let boardPadding: CGFloat = 10
        
        // ミノの中心位置を計算（最初のセルを基準に）
        let minX = polyomino.cells.map { $0.x }.min() ?? 0
        let minY = polyomino.cells.map { $0.y }.min() ?? 0
        
        // locationはボードビュー内の座標系（ドラッグされた位置）
        // ミノの中心がドロップ位置になるように、左上のセルの位置を計算
        // ドロップ位置から、ミノの左上セルの位置を逆算
        let relativeX = location.x - boardPadding
        let relativeY = location.y - boardPadding
        
        // ミノの中心位置をグリッド座標に変換
        let centerGridX = relativeX / (cellSize + spacing)
        let centerGridY = relativeY / (cellSize + spacing)
        
        // ミノの左上セルのグリッド座標を計算
        let topLeftGridX = centerGridX - CGFloat(minX) - (CGFloat(polyomino.cells.map { $0.x }.max() ?? 0) - CGFloat(minX)) / 2
        let topLeftGridY = centerGridY - CGFloat(minY) - (CGFloat(polyomino.cells.map { $0.y }.max() ?? 0) - CGFloat(minY)) / 2
        
        let boardX = Int(round(topLeftGridX))
        let boardY = Int(round(topLeftGridY))
        
        // 範囲チェック（ミノ全体がボード内に収まるか）
        let maxCellX = polyomino.cells.map { $0.x }.max() ?? 0
        let maxCellY = polyomino.cells.map { $0.y }.max() ?? 0
        guard boardX >= 0 && boardX + maxCellX - minX < 10 && boardY >= 0 && boardY + maxCellY - minY < 10 else {
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
    let onDrop: (CGPoint) -> Void
    let onDragChanged: (CGSize) -> Void
    let onDragEnded: (CGPoint) -> Void
    
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
                    .onDrop(of: [.text], isTargeted: nil) { providers in
                        // ドロップ処理（実際にはDragGestureのonEndedで処理）
                        return true
                    }
                
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
                        spacing: spacing
                    )
                    .onTapGesture {
                        // タップで削除
                        viewModel.gameBoard.removePolyomino(withId: placed.id)
                    }
                }
                
                // プレビュー表示（選択中のポリオミノ）
                // 選択されたポリオミノが利用可能リストに存在する場合のみ表示
                // selectedPolyominoは既にrotatedPolyominoが考慮されている
                if let polyomino = selectedPolyomino,
                   viewModel.availablePolyominoes.contains(where: { $0.id == polyomino.id }) {
                    PreviewPolyominoView(
                        polyomino: polyomino,
                        dragOffset: dragOffset,
                        cellSize: cellSize,
                        spacing: spacing,
                        boardPadding: boardPadding,
                        boardSize: geometry.size
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                onDragChanged(value.translation)
                            }
                            .onEnded { value in
                                // ボードビュー内の座標に変換
                                let dropLocation = CGPoint(
                                    x: value.location.x,
                                    y: value.location.y
                                )
                                onDragEnded(dropLocation)
                            }
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
            // セルの左上座標を計算
            let x = CGFloat(position.x + cell.x) * (cellSize + spacing) + boardPadding
            let y = CGFloat(position.y + cell.y) * (cellSize + spacing) + boardPadding
            
            // セルの中心座標
            let centerX = x + cellSize / 2
            let centerY = y + cellSize / 2
            
            RoundedRectangle(cornerRadius: 3)
                .fill(polyomino.color)
                .frame(width: cellSize, height: cellSize)
                .position(x: centerX, y: centerY)
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
        // ミノの中心位置を計算（最初のセルを基準に）
        let minX = polyomino.cells.map { $0.x }.min() ?? 0
        let minY = polyomino.cells.map { $0.y }.min() ?? 0
        let maxX = polyomino.cells.map { $0.x }.max() ?? 0
        let maxY = polyomino.cells.map { $0.y }.max() ?? 0
        
        // ミノの中心をボードの中心に配置し、ドラッグオフセットを適用
        let centerX = boardSize.width / 2 + dragOffset.width
        let centerY = boardSize.height / 2 + dragOffset.height
        
        // ミノ全体の幅と高さ
        let polyominoWidth = CGFloat(maxX - minX + 1) * (cellSize + spacing)
        let polyominoHeight = CGFloat(maxY - minY + 1) * (cellSize + spacing)
        
        // ミノの左上からの相対位置で各セルを配置
        ForEach(Array(polyomino.cells.enumerated()), id: \.offset) { _, cell in
            let offsetX = CGFloat(cell.x - minX) * (cellSize + spacing)
            let offsetY = CGFloat(cell.y - minY) * (cellSize + spacing)
            
            let cellCenterX = centerX - polyominoWidth/2 + offsetX + cellSize/2
            let cellCenterY = centerY - polyominoHeight/2 + offsetY + cellSize/2
            
            RoundedRectangle(cornerRadius: 3)
                .fill(polyomino.color.opacity(0.6))
                .frame(width: cellSize, height: cellSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(polyomino.color, lineWidth: 2)
                )
                .position(x: cellCenterX, y: cellCenterY)
        }
    }
}

struct DraggingPolyominoView: View {
    let polyomino: Polyomino
    let startLocation: CGPoint
    let offset: CGSize
    
    var body: some View {
        // 配置前のミノサイズ（20x20）で表示
        let cellSize: CGFloat = 20
        let spacing: CGFloat = 2
        
        // ドラッグ開始位置から現在の位置を計算
        let currentX = startLocation.x + offset.width
        let currentY = startLocation.y + offset.height
        
        // ミノの中心位置を計算（最初のセルを基準に）
        let minX = polyomino.cells.map { $0.x }.min() ?? 0
        let minY = polyomino.cells.map { $0.y }.min() ?? 0
        
        ForEach(Array(polyomino.cells.enumerated()), id: \.offset) { _, cell in
            let offsetX = CGFloat(cell.x - minX) * (cellSize + spacing)
            let offsetY = CGFloat(cell.y - minY) * (cellSize + spacing)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(polyomino.color.opacity(0.8))
                .frame(width: cellSize, height: cellSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.woodDark, lineWidth: 2)
                )
                .position(
                    x: currentX + offsetX + cellSize/2,
                    y: currentY + offsetY + cellSize/2
                )
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

