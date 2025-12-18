這是一份關於您上傳的 **Nand2Tetris Project 09: Square** 應用程式的代碼分析報告。這組代碼展示了一個基於 Jack 高階語言編寫的互動式圖形程式，以及其對應的虛擬機 (VM) 中介碼。

### 報告標題：Nand2Tetris "Square" 應用程式代碼架構與編譯分析

#### 1. 專案概述

這個專案是一個簡單的圖形遊戲，允許使用者通過鍵盤控制螢幕上的一個黑色方塊。

* **功能**：方塊可以向上下左右移動，並且可以增大或縮小尺寸。
* **架構**：採用了物件導向的設計，分為三個主要類別：`Main` (入口), `SquareGame` (遊戲邏輯/控制器), 和 `Square` (圖形實體/模型)。
* **檔案組成**：包含了高階語言源碼 (`.jack`) 和編譯後的虛擬機代碼 (`.vm`)。

---

#### 2. 詳細代碼分析

##### 2.1 Main 類別 (`Main.jack` & `Main.vm`)

這是程式的進入點。

* **Jack 邏輯**：`Main.main` 函數負責初始化一個 `SquareGame` 實例，執行它，並在遊戲結束後釋放記憶體。
* **VM 實作**：
* `call SquareGame.new 0`：呼叫建構子創建遊戲物件。
* `call SquareGame.run 1`：執行遊戲主迴圈。注意這裡傳入參數 `1` 是因為 `run` 是一個 method，第一個參數隱式地傳入了 `this` 指標 (即剛創建的遊戲物件)。



##### 2.2 SquareGame 類別 (`SquareGame.jack` & `SquareGame.vm`)

這個類別充當「控制器 (Controller)」，負責處理使用者輸入並協調方塊的動作。

* **狀態管理**：
* `field Square square`：持有方塊物件的參照。
* `field int direction`：追蹤目前的移動方向 (0=靜止, 1=上, 2=下, 3=左, 4=右)。


* **遊戲迴圈 (`run` 方法)**：
* 這是整個程式的核心。它使用 `while (~exit)` 進行無限迴圈，直到按下 'q' 鍵。
* **輸入處理**：它不斷輪詢 `Keyboard.keyPressed()`。
* 'z' (ASCII 90) 呼叫 `square.decSize()`。
* 'x' (ASCII 88) 呼叫 `square.incSize()`。
* 方向鍵 (ASCII 130-133) 改變 `direction` 變數。




* **移動邏輯 (`moveSquare` 方法)**：
* 根據 `direction` 的值，呼叫 `Square` 類別對應的 `moveUp`, `moveDown` 等方法。
* 使用 `do Sys.wait(5)` 來控制遊戲速度，避免方塊移動過快。



##### 2.3 Square 類別 (`Square.jack` & `Square.vm`)

這個類別代表螢幕上的圖形實體。

* **屬性**：定義了方塊的 `x`, `y` 座標 (左上角) 和 `size` (邊長)。
* **繪圖原理**：
* `draw()`：設定顏色為黑 (`Screen.setColor(true)`) 並畫出矩形。
* `erase()`：設定顏色為白 (`Screen.setColor(false)`) 並畫出矩形，用於清除軌跡。


* **移動與變形邏輯**：
* 所有的移動 (如 `moveUp`) 或變形 (如 `incSize`) 都遵循 **「擦除 -> 更新座標 -> 重繪」** 的模式。
* **邊界檢查**：例如在 `incSize` 中，會檢查 `(y + size) < 254` 和 `(x + size) < 510` 以確保方塊不會畫出螢幕範圍。


* **VM 代碼對應**：
* `function Square.new 0`：分配記憶體 (`Memory.alloc`) 並初始化欄位 (`this 0`, `this 1`...)。
* `call Screen.drawRectangle 4`：底層呼叫作業系統的螢幕繪圖函數，需要 4 個參數 (x1, y1, x2, y2)。



---

#### 3. Jack 到 VM 的編譯機制解析

這份文件清楚展示了高階 Jack 代碼如何轉換為堆疊式 (Stack-based) 的 VM 代碼。以下是幾個關鍵的轉換範例：

**A. 記憶體存取 (Memory Access)**

* **Jack**: `let size = size + 2;`
* **VM**:
```vm
push this 2      // 將欄位 index 2 (size) 推入堆疊
push constant 2  // 推入常數 2
add              // 相加
pop this 2       // 將結果存回欄位 index 2

```


這顯示了 Jack 編譯器將變數操作轉換為 `push` (讀取) 和 `pop` (寫入) 指令，並使用 `this` 記憶體區段來存取物件的欄位。

**B. 流程控制 (Flow Control)**

* **Jack**: `if (direction = 1) { ... }`
* **VM**:
```vm
push this 1      // 推入 direction
push constant 1
eq               // 判斷是否相等
if-goto IF_TRUE0 // 如果為真，跳轉
goto IF_FALSE0   // 否則跳過
label IF_TRUE0   // 真值區塊標籤
...
label IF_FALSE0  // 結束標籤

```


Jack 的 `if` 語句被轉換為 VM 的 `if-goto` 和 `label` 組合。

**C. 方法呼叫 (Method Call)**

* **Jack**: `do square.draw()`
* **VM**:
```vm
push pointer 0   // 設定 'this' 指標 (在方法內部)
call Square.draw 1 // 呼叫函數，參數數量為 1 (包含隱藏的 'this')
pop temp 0       // 處理 void 方法的回傳值 (丟棄 0)

```


可以觀察到 `Main.vm` 和 `Square.vm` 中頻繁出現 `pop temp 0`，這是因為 Jack 中的 `do` 語句會呼叫函數並忽略其回傳值 (Jack 中 void 函數其實會回傳常數 0)。

#### 4. 總結

這份代碼是 Nand2Tetris 課程中非常經典的範例，它展示了：

1. **物件導向編程**：如何封裝數據 (`Square`) 和行為 (`SquareGame`)。
2. **圖形處理**：基本的動畫原理（清除舊影格、繪製新影格）。
3. **編譯原理**：高階邏輯（迴圈、條件判斷、物件操作）如何被平坦化為簡單的堆疊運算指令。

透過閱讀 `Square.vm` 和 `SquareGame.vm`，您可以清楚地看到編譯器如何管理記憶體區段 (`local`, `argument`, `this`, `pointer`) 以及如何構建函數呼叫堆疊。