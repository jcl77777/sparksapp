# Inspiration Collection App - Component Breakdown for React Native → Swift

## App Architecture

### Main Navigation Structure
- **TabNavigator** with 5 tabs at the bottom
- Each tab has its own view component
- State management for selectedTab and data

---

## Component Hierarchy

```
App
├── TabNavigator (Bottom Navigation)
│   ├── Tab 1: CollectionView
│   ├── Tab 2: TaskListView
│   ├── Tab 3: AddInspirationView
│   ├── Tab 4: DashboardView
│   └── Tab 5: SettingsView
└── Shared Components
    ├── PixelPet (SVG Icon)
    ├── Header (Gradient)
    ├── StatCard
    ├── TagButton
    └── TaskItem
```

---

## 1. CollectionView (收藏)

### Layout Structure
```
View (Container)
├── Header (Gradient: purple → pink)
│   ├── Title: "💡 收藏"
│   └── SegmentedControl
│       ├── Button: "✓ 已整理" (organized)
│       └── Button: "⋯ 待整理" (unorganized)
└── ScrollView
    └── InspirationList
        └── InspirationCard (repeating)
            ├── PixelPet (left)
            └── Content (right)
                ├── Title (bold, monospace)
                ├── Description (gray)
                └── Footer
                    ├── Date badge
                    └── Tag badges
```

### Styling
- **Header**: `backgroundColor: linear-gradient(purple-500, pink-500)`
- **Card**: `border: 4px solid black`, `borderRadius: 8px`, `backgroundColor: white`
- **Font**: `fontFamily: 'monospace'`, `fontWeight: 'bold'`
- **PixelPet**: 32x32 SVG with pixel art cat/star/heart

### Data Model
```javascript
{
  id: number,
  title: string,
  content: string,
  tags: string[],
  date: string,
  pet: 'cat' | 'star' | 'heart',
  organized: boolean
}
```

---

## 2. TaskListView (任務)

### Layout Structure
```
View (Container)
├── Header (Gradient: green → emerald)
│   └── Title: "✓ 任務"
└── ScrollView
    └── TaskList
        └── TaskCard (repeating)
            ├── Checkbox (left)
            │   ├── Border: 4px black
            │   ├── Size: 32x32
            │   └── Background: green when checked
            └── Content (right)
                ├── Title (strikethrough if completed)
                └── DueDate badge
```

### Styling
- **Header**: `backgroundColor: linear-gradient(green-500, emerald-500)`
- **Checkbox**: `width: 32`, `height: 32`, `border: 4px`, `borderRadius: 4px`
- **Completed text**: `textDecorationLine: 'line-through'`, `color: gray`
- **DueDateBadge**: `backgroundColor: blue-100`, `border: 2px blue-300`

### Data Model
```javascript
{
  id: number,
  title: string,
  completed: boolean,
  dueDate: string
}
```

### Interactions
- **onPress checkbox**: Toggle `completed` state
- **Animation**: Checkbox background color transition

---

## 3. AddInspirationView (新增)

### Layout Structure
```
View (Container)
├── Header (Gradient: orange → yellow)
│   └── Title: "➕ 新增靈感"
└── ScrollView
    ├── TypeSelector (Grid 2x2)
    │   ├── Button: "📝 筆記"
    │   ├── Button: "🖼️ 圖片"
    │   ├── Button: "🔗 連結"
    │   └── Button: "🎬 影片"
    ├── InputField (Title)
    │   ├── Label: "📌 標題"
    │   └── TextInput
    ├── InputField (Content)
    │   ├── Label: "✍️ 內容"
    │   └── TextArea (multiline)
    ├── TagSelector
    │   ├── Label: "🏷️ 標籤"
    │   └── TagButtons (wrapping)
    └── SaveButton: "💾 儲存靈感"
```

### Styling
- **Header**: `backgroundColor: linear-gradient(orange-500, yellow-500)`
- **TypeButton**: 
  - Selected: `border: 4px orange`, `backgroundColor: orange-100`
  - Unselected: `border: 4px black`, `backgroundColor: white`
- **InputField**: `border: 4px black`, `padding: 12px`, `fontFamily: monospace`
- **SaveButton**: `backgroundColor: orange-500`, `border: 4px orange-700`

### State
```javascript
{
  selectedType: 'note' | 'image' | 'url' | 'video',
  title: string,
  content: string,
  selectedTags: string[]
}
```

---

## 4. DashboardView (儀表板)

### Layout Structure
```
View (Container)
├── Header (Gradient: blue → cyan)
│   └── Title: "📊 儀表板"
└── ScrollView
    ├── StatsGrid (2x2)
    │   ├── StatCard: Total Inspirations
    │   ├── StatCard: Organized
    │   ├── StatCard: Total Tasks
    │   └── StatCard: Completed
    ├── RemindersSection
    │   ├── Header: "🔔 近期提醒"
    │   └── ReminderCard (repeating)
    │       ├── Title with ⚡
    │       └── Due date
    └── TagsSection
        ├── Header: "🏷️ 熱門標籤"
        └── TagButtons (wrapping)
```

### Styling
- **Header**: `backgroundColor: linear-gradient(blue-500, cyan-500)`
- **StatCard**: 
  - `border: 4px` (color varies: blue/green/orange/purple)
  - `backgroundColor: white`
  - Number: `fontSize: 36`, `fontWeight: bold`, colored
  - Label: `fontSize: 14`, `fontWeight: bold`
- **ReminderCard**: `backgroundColor: yellow-100`, `border: 2px yellow-400`

### Data Calculations
```javascript
{
  totalInspirations: items.length,
  organizedCount: items.filter(i => i.tags.length > 0).length,
  totalTasks: tasks.length,
  completedTasks: tasks.filter(t => t.completed).length
}
```

---

## 5. SettingsView (設定)

### Layout Structure
```
View (Container)
├── Header (Gradient: gray-600 → gray-800)
│   └── Title: "⚙️ 設定"
└── ScrollView
    ├── SettingsList
    │   ├── SettingRow: "🔔 通知設定"
    │   ├── SettingRow: "🌐 語言" → "繁體中文"
    │   ├── SettingRow: "🏷️ 標籤管理"
    │   ├── SettingRow: "🎨 主題設定"
    │   └── SettingRow: "📱 關於應用"
    └── VersionText: "🎮 版本 1.0.0"
```

### Styling
- **Header**: `backgroundColor: linear-gradient(gray-600, gray-800)`
- **SettingRow**: 
  - `border: 4px black`
  - `backgroundColor: white`
  - `flexDirection: row`
  - `justifyContent: space-between`
- **Icon**: `fontSize: 24`
- **Arrow**: "▶" in gray
- **VersionText**: `fontSize: 12`, `color: gray`, `textAlign: center`

---

## Shared Components

### PixelPet Component
```javascript
// SVG-based pixel art
<Svg width={32} height={32}>
  <Rect x={8} y={8} width={2} height={2} fill="#000" />
  <Rect x={6} y={10} width={20} height={2} fill="#f59e0b" />
  // ... more rectangles for pixel art
</Svg>
```

**Variants**: cat (orange), star (yellow), heart (red)

### Header Component
```javascript
<LinearGradient colors={['#color1', '#color2']}>
  <Text style={styles.headerTitle}>{title}</Text>
  {children}
</LinearGradient>
```

**Props**: 
- `colors`: array of 2 colors
- `title`: string
- `children`: optional (for segmented control, etc.)

### TagButton Component
```javascript
<TouchableOpacity style={styles.tagButton}>
  <Text style={styles.tagText}>#{tag}</Text>
</TouchableOpacity>
```

**Style**:
- `backgroundColor: yellow-300`
- `border: 2px black`
- `borderRadius: 16px`
- `padding: 4px 12px`

### StatCard Component
```javascript
<View style={[styles.statCard, { borderColor: color }]}>
  <Text style={[styles.statNumber, { color }]}>{value}</Text>
  <Text style={styles.statLabel}>{label}</Text>
</View>
```

**Props**:
- `value`: number
- `label`: string
- `color`: string (blue/green/orange/purple)

---

## Bottom Tab Navigator

### Structure
```javascript
<View style={styles.tabBar}>
  <TabButton icon="💡" label="收藏" selected={tab === 0} />
  <TabButton icon="✓" label="任務" selected={tab === 1} />
  <TabButton icon="➕" label="新增" selected={tab === 2} />
  <TabButton icon="📊" label="儀表板" selected={tab === 3} />
  <TabButton icon="⚙️" label="設定" selected={tab === 4} />
</View>
```

### Styling
- **TabBar**: 
  - `height: 80px`
  - `backgroundColor: white`
  - `borderTopWidth: 4px`
  - `borderTopColor: black`
  - `flexDirection: row`
- **TabButton**:
  - Selected: color varies by tab
  - Unselected: `color: gray`
  - `fontSize: 24` (icon), `fontSize: 10` (label)
  - `fontFamily: monospace`

---

## Design System

### Colors
```javascript
{
  purple: { start: '#a855f7', end: '#ec4899' },
  green: { start: '#22c55e', end: '#10b981' },
  orange: { start: '#f97316', end: '#fbbf24' },
  blue: { start: '#3b82f6', end: '#06b6d4' },
  gray: { start: '#4b5563', end: '#1f2937' }
}
```

### Typography
- **Font family**: 'Courier New' or system monospace
- **Weights**: bold (700), normal (400)
- **Sizes**: 
  - Header: 24px
  - Body: 14px
  - Label: 12px
  - Stat: 36px

### Spacing
- **Padding**: 16px (standard), 12px (small), 24px (large)
- **Gap**: 12px (between items)
- **Border**: 4px (thick), 2px (thin)
- **Border radius**: 8px (cards), 4px (buttons)

### Shadows
```javascript
{
  shadowColor: '#000',
  shadowOffset: { width: 0, height: 4 },
  shadowOpacity: 0.3,
  shadowRadius: 8,
  elevation: 8
}
```

---

## State Management

### App-level State
```javascript
{
  selectedTab: 0,
  inspirations: Inspiration[],
  tasks: Task[],
  tags: string[]
}
```

### Actions
- `setSelectedTab(index)`
- `toggleTask(id)`
- `addInspiration(data)`
- `updateInspiration(id, data)`
- `deleteInspiration(id)`

---

## Swift/SwiftUI Translation Notes

1. **LinearGradient** → `LinearGradient` in SwiftUI
2. **ScrollView** → `ScrollView` in SwiftUI
3. **TouchableOpacity** → `Button` with custom styling
4. **SVG** → Custom `Shape` or `Path` in SwiftUI
5. **Monospace font** → `.monospaced()` modifier
6. **Border** → `.border()` or `.overlay(RoundedRectangle())`
7. **State** → `@State` and `@Binding`
8. **TabBar** → `TabView` with custom styling

---

## Key Interactions

1. **Tab Navigation**: Change view based on selected tab index
2. **Task Toggle**: Update task.completed on checkbox press
3. **Type Selection**: Highlight selected type in Add view
4. **Segmented Control**: Filter items by organized/unorganized
5. **Active States**: Scale down button on press (0.95 transform)

---

## Animations

1. **Button Press**: Scale to 0.95, duration 0.1s
2. **Checkbox**: Background color fade, duration 0.2s
3. **Tab Switch**: Fade transition between views
4. **Hover (desktop)**: Shadow increase on hover

---

This breakdown provides all the structural, styling, and behavioral information needed to recreate this app in Swift/SwiftUI while maintaining the pixel art aesthetic and function