import SwiftUI

struct Tile: Identifiable {
    let id = UUID()
    var value: Int?
}

struct PuzzleView: View {
    @State private var puzzle = [
        [Tile(value: 1), Tile(value: 2), Tile(value: 3)],
        [Tile(value: 4), Tile(value: 5), Tile(value: 6)],
        [Tile(value: 7), Tile(value: 8), Tile()]] // One empty tile to make 8 pieces

    @State private var emptyTile = (row: 2, col: 2)
    @State private var moveCount = 0
    @State private var isSolved = false
    @State private var showCelebration = false
    @State private var showInfo = false
    @State private var draggedTile: (Int, Int)? = nil
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                Text("Jeu de Puzzle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                
                HStack {
                    Text("Coups: \(moveCount)")
                        .font(.title2)
                        .padding()
                        .background(Color.brown.opacity(0.2))
                        .cornerRadius(8)
                    
                    if isSolved {
                        Text("Résolu!")
                            .font(.title3)
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                // Game board frame with relief effect
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.brown, lineWidth: 5)
                        .frame(width: 300, height: 300)
                        .background(Color.brown.opacity(0.1))
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 3, y: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.brown.opacity(0.5), lineWidth: 2)
                        )
                    
                    VStack(spacing: -1) {
                        ForEach(0..<3) { row in
                            HStack(spacing: -1) {
                                ForEach(0..<3) { col in
                                    ZStack {
                                        // Tile view
                                        if let draggedTile = draggedTile, draggedTile.0 == row, draggedTile.1 == col {
                                            // Show dragged tile with offset
                                            TileView(tile: puzzle[row][col])
                                                .frame(width: 99, height: 99)
                                                .offset(dragOffset)
                                                .animation(.none, value: dragOffset)
                                        } else {
                                            // Normal tile view
                                            TileView(tile: puzzle[row][col])
                                                .frame(width: 99, height: 99)
                                        }
                                        
                                        // Make the tile clickable for regular interaction (fallback)
                                        if puzzle[row][col].value != nil {
                                            Button(action: {
                                                // Check if this tile is adjacent to empty tile
                                                if isAdjacent(to: (row, col)) {
                                                    moveTile(at: (row, col))
                                                    moveCount += 1
                                                    checkSolved()
                                                }
                                            }) {
                                                Rectangle()
                                                    .fill(Color.clear)
                                                    .frame(width: 99, height: 99)
                                            }
                                        }
                                    }
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 5, coordinateSpace: .local)
                                            .onChanged { value in
                                                // Only start dragging if tile is adjacent to empty space
                                                if draggedTile == nil {
                                                    if isAdjacent(to: (row, col)) {
                                                        draggedTile = (row, col)
                                                    }
                                                }
                                                
                                                // Only allow movement when we're actually dragging an adjacent tile
                                                if let startRow = draggedTile?.0, let startCol = draggedTile?.1 {
                                                    // Calculate movement direction
                                                    let horizontal = value.translation.width
                                                    let vertical = value.translation.height
                                                    
                                                    // Only enable dragging if it's an adjacent tile
                                                    if isAdjacent(to: (startRow, startCol)) {
                                                        // Determine valid movement direction based on empty tile position
                                                        let (emptyRow, emptyCol) = emptyTile
                                                        let rowDiff = startRow - emptyRow
                                                        let colDiff = startCol - emptyCol
                                                        
                                                        // Calculate how far we can drag based on direction to empty space
                                                        let maxHorizontal: CGFloat = 99
                                                        let maxVertical: CGFloat = 99
                                                        
                                                        // Only allow movement in the direction of the empty space
                                                        if rowDiff == -1 && colDiff == 0 {
                                                            // Empty is below the tile (tile can only go down)
                                                            if vertical >= 0 {
                                                                dragOffset = CGSize(width: 0, height: max(min(vertical, maxVertical), 0))
                                                            } else {
                                                                dragOffset = .zero
                                                            }
                                                        } else if rowDiff == 1 && colDiff == 0 {
                                                            // Empty is above the tile (tile can only go up)
                                                            if vertical <= 0 {
                                                                dragOffset = CGSize(width: 0, height: max(min(vertical, 0), -maxVertical))
                                                            } else {
                                                                dragOffset = .zero
                                                            }
                                                        } else if rowDiff == 0 && colDiff == -1 {
                                                            // Empty is to the right of the tile (tile can only go right)
                                                            if horizontal >= 0 {
                                                                dragOffset = CGSize(width: max(min(horizontal, maxHorizontal), 0), height: 0)
                                                            } else {
                                                                dragOffset = .zero
                                                            }
                                                        } else if rowDiff == 0 && colDiff == 1 {
                                                            // Empty is to the left of the tile (tile can only go left)
                                                            if horizontal <= 0 {
                                                                dragOffset = CGSize(width: max(min(horizontal, 0), -maxHorizontal), height: 0)
                                                            } else {
                                                                dragOffset = .zero
                                                            }
                                                        } else {
                                                            // Not adjacent to empty space - reset drag
                                                            dragOffset = .zero
                                                        }
                                                    }
                                                }
                                            }
                                            .onEnded { value in
                                                // Check if we've moved far enough to be a valid move (at least 20 pixels)
                                                if let startRow = draggedTile?.0, let startCol = draggedTile?.1 {
                                                    let horizontal = value.translation.width
                                                    let vertical = value.translation.height
                                                    let distance = sqrt(pow(horizontal, 2) + pow(vertical, 2))
                                                    
                                                    // Only proceed with move if dragged far enough
                                                    if distance > 20 {
                                                        // Check if this is a valid adjacent move
                                                        if isAdjacent(to: (startRow, startCol)) {
                                                            moveTile(at: (startRow, startCol))
                                                            moveCount += 1
                                                            checkSolved()
                                                            // Add haptic feedback
                                                            UISelectionFeedbackGenerator().selectionChanged()
                                                        }
                                                    }
                                                }
                                                draggedTile = nil
                                                dragOffset = .zero
                                            }
                                    )
                                }
                            }
                        }
                    }
                    .padding(2) // Inner padding to create grid effect
                }
                .padding()
                
                Button("Redémarrer") {
                    restartGame()
                }
                .font(.title2)
                .padding()
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                
                if showCelebration {
                    Text("Ouf! 🎉")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                        .scaleEffect(showCelebration ? 1.5 : 1.0)
                        .animation(.spring(), value: showCelebration)
                }
            }
            .onAppear {
                // Shuffle the puzzle to start a new game
                shufflePuzzle()
            }
            
            // Info button at top right corner
            Button(action: {
                showInfo = true
            }) {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .clipShape(Capsule())
            }
            .position(x: UIScreen.main.bounds.width - 30, y: 30)
            .buttonStyle(PlainButtonStyle()) // Remove default button styling including halo
            
            // Info alert
            .alert("À propos", isPresented: $showInfo) {
                Button("Fermer") { }
            } message: {
                Text("""
                Jeu de Puzzle v1.0
                
                Créé en 20 minutes avec Ollama dans Xcode 26.3
                Utilisant l'IA et le modèle qwen2.5-coder-7b
                
                Ce projet utilise l'IA pour générer du code Swift pour
                créer une application de puzzle avec interface utilisateur
                et fonctionnalités comme les mouvements, l'animation et
                le compteur de coups.
                
                Le modèle qwen3-coder-30b a été utilisé pour cette création,
                tandis que le modèle qwen2.5-coder-7b n'a pas réussi à atteindre
                ce niveau de génération.
                """)
            }
        }
    }
    
    private func isAdjacent(to position: (Int, Int)) -> Bool {
        let (row, col) = position
        let (emptyRow, emptyCol) = emptyTile
        
        // Check if adjacent (up, down, left, right)
        return (abs(row - emptyRow) == 1 && col == emptyCol) || 
               (abs(col - emptyCol) == 1 && row == emptyRow)
    }
    
    private func moveTile(at tilePosition: (Int, Int)) {
        let (row, col) = tilePosition
        let (emptyRow, emptyCol) = emptyTile
        
        // Swap the values
        let temp = puzzle[row][col].value
        puzzle[row][col].value = puzzle[emptyRow][emptyCol].value
        puzzle[emptyRow][emptyCol].value = temp
        
        // Update empty tile position
        emptyTile = (row, col)
        
        // Add haptic feedback
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    private func checkSolved() {
        // Check if puzzle is solved
        var expectedValue = 1
        for row in 0..<3 {
            for col in 0..<3 {
                if row == 2 && col == 2 {
                    // Last tile should be empty
                    if puzzle[row][col].value != nil {
                        isSolved = false
                        return
                    }
                } else {
                    if puzzle[row][col].value != expectedValue {
                        isSolved = false
                        return
                    }
                    expectedValue += 1
                }
            }
        }
        isSolved = true
        showCelebration = true
        
        // Stop the celebration animation after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCelebration = false
        }
    }
    
    private func restartGame() {
        puzzle = [
            [Tile(value: 1), Tile(value: 2), Tile(value: 3)],
            [Tile(value: 4), Tile(value: 5), Tile(value: 6)],
            [Tile(value: 7), Tile(value: 8), Tile()]] // One empty tile to make 8 pieces
        emptyTile = (row: 2, col: 2)
        moveCount = 0
        isSolved = false
        showCelebration = false
        shufflePuzzle()
    }
    
    private func shufflePuzzle() {
        // Simple shuffle to make a solvable puzzle
        for _ in 0..<100 {
            let adjacentTiles = getAdjacentTiles()
            if let randomTile = adjacentTiles.randomElement() {
                moveTile(at: randomTile)
            }
        }
        moveCount = 0
    }
    
    private func getAdjacentTiles() -> [(Int, Int)] {
        var adjacentTiles: [(Int, Int)] = []
        let (emptyRow, emptyCol) = emptyTile
        
        // Check adjacent positions
        let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        for (dRow, dCol) in directions {
            let newRow = emptyRow + dRow
            let newCol = emptyCol + dCol
            if newRow >= 0 && newRow < 3 && newCol >= 0 && newCol < 3 {
                adjacentTiles.append((newRow, newCol))
            }
        }
        return adjacentTiles
    }
}

struct TileView: View {
    let tile: Tile
    
    var body: some View {
        if let value = tile.value {
            Text("\(value)")
                .frame(width: 98, height: 98)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.white, Color(red: 245/255, green: 222/255, blue: 179/255)]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.brown.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(.brown)
                .font(.system(size: 30, weight: .bold))
                .cornerRadius(8)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 98, height: 98)
                .cornerRadius(8)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PuzzleView()
    }
}
