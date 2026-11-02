# AVG 开发接入说明

适用本地 Godot 4.7.2、Dialogic alpha 20 与 FantasyTemplate。功能验证范围以根 README 为准；文档介绍接口不代表全部验收通过。

## 打开与运行

运行根目录“启动编辑器.ps1”，工程在 game/project.godot。本地入口启用 Godot 原生单窗口模式，创建人物或导入图片时，文件框留在编辑器窗口内。

进入 Dialogic 面板编辑时间线。F5 运行整个游戏，Dialogic 的 Play Timeline 单独预览当前时间线。单独预览没有正式标题、暂停或存档菜单；其原生场景现先加载已读记录，并关闭自动保存，避免覆盖玩家进度。该修正还需实际预览复核。

当前编辑器的“编辑器设置 → 运行 → 自动保存 → 运行前保存”已关闭，以保留已有未保存场景。确认自己的场景后可自行恢复默认；不要为运行示例盲目保存或丢弃其他场景。

“启动游戏.ps1”用本地引擎运行正式主场景。“导出Windows.ps1”调用本地匹配模板导出 exe／pck，并复制 licenses。只发玩家目录即可，无需编辑器、外部工作台或数据库。

## 新增人物、表情和图片

1. 将有许可的图片复制到 game/Assets/Characters/角色名，等待 Godot 导入。
2. 在 Dialogic 新建 Character，保存到 game/content/characters。
3. 填写 Display Name；Portraits 的文件夹按钮为“Import Images as Portraits”。在文件框选择实际图片缩略图后按 Open，默认表情会写入角色资源。
4. 给各表情选择本地图片，配置默认表情、比例、偏移与镜像。
5. 时间线使用 Join、Text、Update Portrait、Leave。

本轮通过编辑器真实创建的例子为 content/EditorExample.dch，中文显示名“示例人物”，默认表情 Imported Portrait，引用 Assets/ImportedPortrait.png。该图复制自模板 Astrid/happy.png，沿用模板许可，具体来源见 licenses/TEMPLATE-ASSET-SOURCES.md。

多表情配置参考 TestStuff/Assets/Characters/Astrid/Astrid.dch、Lucas/Lucas.dch；演出参考 TestStuff/TestTimeline.dtl。原生 dch 是 Godot Variant 文本，不是普通 JSON。角色资源标识与显示姓名不同。

## 时间线、变量与选择

同一 dtl 可用可视化及文本编辑器编辑。可视化／文本切换会调用原生保存；Play Timeline 也会先保存当前时间线。本轮两种编辑模式和预览均已实际使用。

FrameworkExample 是技术选单，PongExample 是小游戏结果分支。变量沿用 Dialogic 的 Variables 配置，当前有 PongResult 与 TextInput。引用及跳转使用本地资源标识。

```text
join EditorExample center
EditorExample: 这是中文人物对白。
leave EditorExample
- 进入小游戏
	jump PongExample/
- 返回标题
	[signal arg="GAME_END"]
```

PongResult 取 left／right／cancel。结果时间线使用原生 if／elif／else；记录结局选项使用原生条件及可见性：

```text
- 记录本次结局并返回标题 | [if {PongResult} != "cancel"] [else="0"]
```

else=0 表示条件不成立时隐藏。后台已验证左右结果显示、取消隐藏，最新条件仍待界面复核。FantasyChoices 场景已配置七个原生 ChoiceButton；再增加同时出现的选项时，应按 Dialogic 样式规则配置足够的按钮。

中文使用 Noto Sans SC。文本框保留模板的原生滚动功能；过长对白可用 Dialogic 的 [n] 分段。字号上限和长段落布局尚需完整验收。

## 背景、声音及鉴赏

资源全部使用 res:// 路径。当前背景在 Assets/Backgrounds/JAP，采用 CC0 日落和雪山；许可未确认的旧 Painterly 已退出活动工程。GalleryExample 直接用原生 Background 与 Choice 事件切换变体。

声音沿用 Godot 总线 Master／Music／SFX／Voice／UI_SFX。音乐与环境音、音效用 Dialogic Audio 事件，语音用 Voice 事件；文件在 game 内落地。AudioExample 使用 Kenney CC0 男女声 Ready 和非循环 SFX。来源、配音署名及许可随 licenses 交付。

鉴赏使用 wtmenten/DialogicTemplate 的 TimelineMeta 资源。复制 content/gallery 下的 tres，在检查器设置 timeline、user_label、thumbnail、timeline_type=CG。系统按时间线首条文字事件的全局已读状态解锁，故回放时间线必须有文字事件。

六个当前条目分别为人物演出、背景变体、Teller／Skye 音乐、左右结局。音乐回放的播放／停止仍用原生 Audio 事件；结局与背景回放以 GAME_END 返回标题。主菜单启动时加载全局已读，结束时保存；鉴赏回放关闭自动存档并保留原继续指针。

图库嵌入模板时必须保留 GalleryTab 的锚点布局（layout_mode=1）及卡片最小尺寸；缺少这两项会出现资源已加载但页面空白。当前已修正并实际显示卡片。

全局记录使用 Dialogic 原生存储；新游戏清理本局状态，不另建解锁管理器。独立包已验证两种结局跨周目与冷启动保留、锁定卡和右侧回放；全部条目的最终冷启动回放复核仍待完成。

## 接入现成小游戏

minigames/pong 是官方现成 Pong，保留原运动与碰撞代码。

1. Background 事件实例化 integration/pong_background.tscn。
2. 场景继承 DialogicBackground，内部实例化 Pong。
3. Call 事件执行 ExampleBridge.play_pong()，等待 finished。
4. 连接代码将 left／right／cancel 写入 PongResult，恢复对白框。
5. 原生时间线根据结果进入对白、重试或结局。

左侧 W/S、右侧上下键；Esc 打开模板暂停／存档，Backspace 取消。不要把本玩法字段推广成新的通用小游戏管理器。

Dialogic Backgrounds 调用场景 _get_state()，将球位置、方向、速度和两个球拍位置装入同一份 DialogicSaveState。读取时重建场景并调用 _load_state()。没有第二份存档文件或新协议；其他玩法只映射自身恢复所需状态。

独立包已实际得到左右结果并回到对应结局，slot_2 中途档冷启动后继续完成；此前暂停物理核对 slot_1 的五项数值完全一致，记录见 staging/pong-restore-values.log。

## 存档、设置与历史

手动存档沿用模板每页四槽，共十五页。最后两槽为 slot_58 自动档和 slot_59 快捷档；保存页禁止手动覆盖专用槽，读取页可读取。F5／F9 是原生 Button Shortcut，不是另一套存档机制。

打开菜单前使用 Dialogic.Save.take_thumbnail()，保存写入原生缩略图、时间和位置。独立包实际显示了人物与小游戏缩略图。覆盖确认已使用；删除目前仅验证确认框和取消，未提交删除。

DialogicGameHandler.load_full_state 已修正为等待布局 ready、恢复子系统再启动时间线，防止自动档抢先捕获隐藏文本框。舞台快捷档经独立包冷启动恢复了日落、双人物和原对白；原生档内 TextInput 为“中文测试”。

设置仍用模板控件、Dialogic 全局设置和 AudioServer。text_speed 必须在 project.godot 的 dialogic/settings 下声明默认值，否则虽然写入全局文件，冷启动不会被 Settings 子系统重新加载。当前已声明，并完成修正后的实际冷启动检查。

显示索引为 0=1152×648、1=全屏、2=1600×900、3=1920×1080。窗口模式设置尺寸后调用 Window.move_to_center。全部显示选项已实际操作，字号、自动速度、跳过规则和五路音量已修改并冷启动复核，最后恢复默认。

历史沿用模板列表。alpha 20 的人物退场 mode 为 Leave，选择历史 all_choices 为字典数组；history_message.gd 已据当前上游结构修正，保留可见性、禁用及选择加粗。独立包实际历史中已不再出现原占位文字。

## 搬迁与外部内容

staging/relocated-project 含独立引擎、导出模板及工程；其导出入口已成功构建。staging/standalone-player 只含发行文件，已实际完成 AVG／Pong 代表性完整循环。搬迁编辑器中实际修改、保存、预览仍待完成，运行环境仍为本开发机。

无窗口导入／导出仍有编辑器退出资源泄漏警告，准确范围见根 README，不能写成“没有任何警告”。后台检查和成功导出不能替代剩余界面验收。

外部工具交付有许可的图片、音频及 Dialogic 原生人物／时间线。复制进 game/Assets、game/content 后使用；不复制密钥、数据库、缓存或外部绝对路径，不实时依赖 localhost 服务。Windows 沿用上游 Assets 大小写。cangqi 原文仓库不迁移、不改写。

用户工作期间只运行后台命令；不为验收激活、点击、关闭或重新启动前台程序。待用户允许连续占用界面后，再复核 README 中明确列出的剩余操作。
