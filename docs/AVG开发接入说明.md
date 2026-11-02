# AVG 开发接入说明

Godot 4.7.2、Dialogic alpha 20、FantasyTemplate。示例路径都在 `game/examples/`，新内容放 `game/content/`。

## 运行与预览

- `启动编辑器.ps1` 打开工程（单窗口模式，文件对话框在编辑器内）。
- F5 运行整个游戏（标题、存档、设置齐全）。
- Dialogic 时间线编辑器里按 **Ctrl+F6** 单独预览当前时间线。预览会先保存时间线；预览不写入已读记录、不触发自动存档，不会影响玩家的继续点和鉴赏解锁。预览没有标题与存档菜单。
- 打开主菜单场景时标签上可能出现 `(*)`，是 Godot 规整场景格式，保存无实际变化。

## 人物、表情、立绘

1. 把有许可的图片放进 `game/content/characters/角色名/`，等待导入。
2. Dialogic → Character → 新建，保存在 `game/content/`。
3. 填 Display Name；Portraits 里的文件夹按钮（Import Images as Portraits）可批量导入图片作为表情。
4. 为每个表情选图，设默认表情、缩放、偏移、镜像。
5. 时间线里用 Join、Text、Update Portrait、Leave。

参考：`examples/characters/EditorExample.dch`（编辑器新建的中文角色）、`examples/characters/Characters/Astrid/Astrid.dch`（多表情）、`examples/timelines/TestTimeline.dtl`（演出）。角色资源名与显示名可以不同。

## 时间线、变量、选择

可视化与文本两种编辑模式可互相切换。文本写法示例：

```text
join 角色名 center
角色名: 这是中文对白。
leave 角色名
- 选项一
	jump 另一条时间线/
- 返回标题
	[signal arg="GAME_END"]
```

变量在 Dialogic → Variables 定义。条件选项：

```text
- 记录结局并返回标题 | [if {PongResult} != "cancel"] [else="0"]
```

`else="0"` 表示条件不成立时隐藏（`1` 为置灰）。选项样式预置了七个按钮，同屏选项超过七个需要在 `DialogicFantasyStyle/FantasyChoices` 里加按钮。

中文字体为 Noto Sans SC；长对白用 `[n]` 分段，文本框自带滚动。

## 背景、声音

- 资源一律用 `res://` 路径，放在 `game/` 内。
- 背景用 Background 事件；示例 `examples/timelines/GalleryExample.dtl` 演示两张背景切换。
- 音频总线：Master／Music／SFX／Voice／UI_SFX。音乐、环境声、音效用 Audio 事件，语音用 Voice 事件。示例 `examples/timelines/AudioExample.dtl`。

## 鉴赏

鉴赏页读取 `content/gallery/` 与 `examples/gallery/` 下的 TimelineMeta（.tres）：

1. 复制一个现有 .tres 到 `content/gallery/`。
2. 在检查器设置 timeline、user_label、thumbnail、timeline_type。
3. 解锁条件是该时间线**第一条文字事件**被读过（全局已读，跨周目保留）。所以回放用的时间线必须有文字事件。

结局、背景回放用 `GAME_END` 返回标题。新游戏会清空本局状态但保留全局解锁。

## 接入小游戏

以 Pong 为例（`examples/minigames/pong` 为官方原版，`examples/integration/` 为连接代码）：

1. 时间线用 Background 事件加载 `pong_background.tscn`，它继承 DialogicBackground 并实例化 Pong。
2. Call 事件执行 `ExampleBridge.play_pong()`，等待场景发出 `finished(result)`。
3. 结果写入 Dialogic 变量 `PongResult`（left／right／cancel），时间线按变量分支。
4. 存档：场景实现 `_get_state()` 与 `_load_state()`，Dialogic 存档时自动把它们放进同一份存档，读档时重建场景并恢复。不需要第二套存档。

新玩法照此写一个继承 DialogicBackground 的场景和一个 autoload 桥接函数即可。操作：左 W/S，右 ↑/↓，Esc 暂停与存档，Backspace 取消。

## 存档、设置、历史

- 每页四槽，共十五页；slot_58 是自动档，slot_59 是快捷档（F5 存、F9 读），保存页不能手动覆盖这两个槽。
- 存档带缩略图、时间、位置；覆盖和删除都有确认。
- 从 `GAME_END` 回到标题会清掉“继续游戏”；直接关窗不会。
- 设置使用 Dialogic 全局设置与 AudioServer。新增需要冷启动保留的 Dialogic 设置项，必须在 `project.godot` 的 `dialogic/settings/` 下声明默认值，否则重启后不会加载。
- 显示模式：0=1152×648、1=全屏、2=1600×900、3=1920×1080。

## 导出

`导出Windows.ps1`，或编辑器 项目 → 导出 → 导出项目（取消“使用调试导出”）。输出到 `dist/windows/`，把 exe、pck、licenses 一起发给玩家即可。导出预设已排除 `Templates/`、README 和未使用的字体音效。

## 外部制作工具

外部工具只交付有许可的图片、音频和 Dialogic 原生 .dtl／.dch。复制进 `game/content/` 后使用，不带入密钥、数据库、缓存或绝对路径，游戏运行时不访问任何本机服务。
