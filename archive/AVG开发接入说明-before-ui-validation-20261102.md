# AVG 开发接入说明

适用当前 Project 中的 Godot 4.7.2、Dialogic alpha 20 与 FantasyTemplate。此文描述现有编辑入口与连接方式；功能验证状态以根 README 为准，未验证项不据此视为完成。

## 打开和运行

运行根目录 `启动编辑器.ps1`，工程文件在 `game/project.godot`。进入编辑器的 Dialogic 面板；F5 运行整个游戏，时间线编辑器的播放按钮用于单独预览时间线。单独预览使用 Dialogic 自带预览场景，不包含正式标题及暂停菜单，因此菜单和保存检查必须使用 F5。

`启动游戏.ps1` 使用本地引擎直接运行正式主场景。`导出Windows.ps1` 导出到 `dist/windows`，同时复制当前第三方许可。预览包不是正式剧情发布包。

## 新增角色与表情

1. 把角色图片复制到 `game/Assets/Characters/<角色名>/`。
2. 在 Dialogic 编辑器新建角色资源，保存到 `game/content/characters/`，填写显示名和角色标识。
3. 在角色 Portraits 配置中添加表情，选用本地图片，并设置默认表情、比例与偏移。
4. 在时间线加入 Join、Text、Update Portrait、Leave 事件。

现成配置参考 `TestStuff/Assets/Characters/Astrid/Astrid.dch`。`.dch` 使用 Godot Variant 格式，不应当作普通 JSON 文件用 JSON 工具覆盖。字符标识和显示姓名不同，中文显示名可以修改，时间线引用应对应编辑器中的角色标识。

## 新增时间线和分支

在 Dialogic 新建 Timeline，保存到 `game/content/`。同一 `.dtl` 可用可视化事件或文本方式编辑。可运行的技术入口是 `FrameworkExample.dtl`，小游戏时间线是 `PongExample.dtl`。新增资源后由 Dialogic 编辑器登记资源目录，优先通过编辑器选择目标时间线，避免拼错标识。

当前文本格式示例：

```text
这里是一段旁白。
label Choice
- 进入小游戏
    jump PongExample/
- 返回标题
    [signal arg="GAME_END"]
```

上例缩进仅用于展示，工程现有文件使用 Tab。变量在 Dialogic 的 Variables 配置中建立，当前结果变量为 `PongResult`（`left`、`right`、`cancel`）。分支语法和上游事件格式以现有 `PongExample.dtl` 为例。

## 背景、音频与鉴赏条目

背景事件可以显示本地图片，也可以实例化继承 DialogicBackground 的场景。人物、背景、音频引用全部使用 `res://`。

音乐、音效使用 Dialogic Audio 事件；当前总线为 Master、Music、SFX、UI_SFX、Voice。语音播放器已连接 Voice 总线。声音文件复制到游戏内后，在事件编辑器中选择文件，不引用外部工作台 URL。

鉴赏条目沿用 wtmenten/DialogicTemplate 的 TimelineMeta 资源。复制 `content/gallery/backgrounds.tres`，在 Godot 检查器中修改 timeline、user_label 和 thumbnail。timeline_type 为 CG。画廊通过 Dialogic 原生解析找到时间线第一条文字事件，并根据这条事件的已读记录判断解锁。时间线必须包含文字事件；开头可以先切换背景或播放音乐。条目回放应指向独立时间线，不应把不同条目都指向同一条长剧情。当前 GAME_END 调用 Dialogic 原生已读记录保存，再返回标题。

变体示例使用 `GalleryExample.dtl` 的背景事件与选择事件。音乐示例为 MusicTeller／MusicSkye，播放与停止均为原生 Audio 事件；结局示例为 EndingLeft／EndingRight，由 Pong 结果分支进入。它们和 CG 示例复用同一种卡片与已读判断。左侧结局已经实测：完成结局后开始新游戏，重启，卡片保持解锁，回放两句后返回标题，再继续到原 FrameworkExample 示例选单；latest_save_slot 保持 slot_58，已读结局记录保留，运行日志无脚本错误（staging/gallery-history-fix.log）。其余卡片尚未全部验证。

主菜单初始化时调用 Dialogic.History.load_visited_history()。这是全局已读记录的必要接线：只在打开鉴赏时加载会使“重启后先继续游戏”的自动保存将空内存记录写回。全局存储仍使用 Dialogic 原生接口。

背景变体运行实测：从 FrameworkExample 进入 GalleryExample，分别选择第一张黄昏背景与第二张星空背景；两次 F5 生成的原生缩略图显示不同背景及对应中文对白，随后从选单返回标题成功。全局已读文件包含 GalleryExample 第一条文字及两条变体文字，原 EndingLeft 记录仍保留。该结果证明示例切换与返回，不代替重启后从鉴赏卡片进入的验证；音乐播放／停止仍待实际操作。

Teller 音乐交互实测：进入 MusicTeller 后选择“播放”，UIA 出现 music 播放器，F5 保存的 Audio.info.music.path 为对应 MP3；选择“停止”后，重新观察窗口，music 播放器节点消失。停止后的 F5 因窗口连续无法激活而未执行，不能把旧快捷档当成停止后的状态。此次实际声音输出、返回标题和 Skye 条目仍未验证。

## 插入现成小游戏

本工程示例直接复用 Godot 官方 `2d/pong`，文件位于 `minigames/pong/`。玩法脚本保留上游实现；场景中的资源路径改为本地目录。

连接顺序：

1. 时间线 Background 事件实例化 `integration/pong_background.tscn`。
2. 该场景继承 DialogicBackground，内部实例化原 Pong 场景。
3. Call 事件执行 `ExampleBridge.play_pong()`，等待场景 finished 信号。
4. 连接代码把 left／right／cancel 写入 Dialogic 的 PongResult，恢复对白框。
5. 原时间线通过条件事件选择结果对白，可跳回开始位置重试。

正式新玩法应有自己的 Godot 场景和结果信号，再调用相同的上游扩展接口。不要修改 Dialogic 核心或把 Pong 专用字段当作通用小游戏协议。

## 小游戏存档状态

Dialogic 的 Backgrounds 子系统调用场景 `_get_state()`，把返回字典装入同一份 DialogicSaveState；读取时重新创建场景，再调用 `_load_state()`。Pong 示例映射球位置、运动方向、速度及两个球拍位置。连接代码不写第二份存档文件。

开发新小游戏时只填写该玩法恢复所必需的真实状态。Pong 已实测在场地中保存至 slot_1，关闭进程后通过“继续游戏”恢复场地，并继续回到结果剧情；当前版本另以该真实中途档做原生恢复检查：在暂停物理的条件下，球位置 (326.7136, 217.488)、方向 (0.994621, 0.103578)、速度 109.571488000002、左拍位置 (67.6285, 192.594)、右拍位置 (563.815, 188.919) 全部与档内值严格相等。随后解除暂停，Pong 自然结束，finished 与 PongResult 均为 left，回到 PongExample 事件 4 和左侧获胜对白。该次运行无窗口，日志为 staging/pong-restore-values.log；临时检查脚本已删除。这只验证本示例，其他小游戏仍需接入自己的状态。

手动槽沿用模板分页。第 15 页最后两个位置为自动档 slot_58 和快捷档 slot_59。保存页会显示专用槽名称并禁用手动覆盖；读取页可读取已有的自动档和快捷档。自动档使用 Dialogic 文字事件触发模式；快捷保存覆盖独立快捷槽，快捷读取读取该槽。小游戏中可通过 Esc 进入正式暂停／保存菜单，Backspace 经 InputMap 的 `cancel_minigame` 动作取消并返回剧情。保存页日期和位置通过 Save.saved 信号写入模板元信息。

## 已验证的设置操作

快捷存读档：F5／F9 使用 Godot 原生 Button Shortcut 调用原有按钮，槽位仍为 slot_59。读档时恢复自动存档并清除鉴赏回放标记。已实测保存完整对白、推进到选择、F9 恢复原对白，以及关闭进程后“继续游戏”恢复对白。原生缩略图包含文本框与正文。运行记录：staging/load-order-fix.log、staging/load-order-cold.log。

兼容修补：Dialogic alpha 20 的 Core/DialogicGameHandler.gd 中，load_full_state 原来连接新布局 ready 信号后立即启动时间线；自动存档可能抢先保存尚未恢复的隐藏文本框。现改为等待 ready、恢复子系统，再启动时间线。存档格式和各子系统保持上游实现。此修改后已用真实 slot_1 中途档复核五项状态及自然结束返回剧情，见“小游戏存档状态”。

设置实测：在运行窗口中把对白字号从 38 调为 42、音乐音量从 0.8 调为 0.6，关闭进程并重启后，设置页保留两个值。“恢复默认”还原为 38 和 0.8。随后从标题的读取进度页选择手动存档 1，恢复到原左侧获胜对白。此次运行日志为 `staging/settings-persistence.log`，未出现脚本错误；这不代表其余设置和所有存档操作已全部验证。

## 搬迁与独立玩家启动

显示尺寸配置：OptionsTab 原有 Setting_Display 下拉框增加窗口 1152×648、1600×900、1920×1080，继续使用模板已有 display_mode 持久化字段，索引 1 仍为全屏。tab_options.gd 的既有显示回调直接设置 Godot Window.mode／size，打开设置页时选中已保存的索引，恢复默认回到 1152×648。接口依据 Godot 官方 Window 文档：https://docs.godotengine.org/en/stable/classes/class_window.html#class-window-property-size 。临时图形运行检查实际得到三个对应尺寸，保存值分别为 0、2、3，最后恢复原设置；日志 staging/window-size-check.log。此检查调用正式设置回调，未模拟鼠标或键盘，不算完成菜单实际选择和冷启动验证；临时脚本已删除。Windows 包已重新导出。

2026-11-02 将包含 Kenney 原包 WAV 音效替换的当前 game、许可、文档及入口同步至 staging/relocated-project，排除原工程 .godot 缓存；使用副本自带的引擎和导出模板运行副本导出入口，成功生成 Windows 包。导入与导出仍各有两个编辑器 UndoRedo 对象的退出泄漏警告。

再把该包的 CangqiAVG.exe、CangqiAVG.pck 和 licenses 单独复制至 staging/standalone-player，从该目录启动 180 帧。实际日志显示 NVIDIA GeForce RTX 5080 的 OpenGL 3.3 Compatibility 图形后端，进程退出码为 0，没有资源或脚本错误，日志为 staging/standalone-player/startup.log。这证明当前玩家包可以从独立目录完成图形启动，不代替编辑器操作或 AVG／小游戏完整交互验证；运行环境仍是本开发机。

## 外部内容交付

声音技术示例：从 FrameworkExample 选择“试听语音与分轨音效”，进入 content/AudioExample.dtl。该时间线直接使用 Dialogic 的 Voice 事件（bus="Voice"）和 Audio 事件（bus="SFX"、loop="false"），现成英文男女声 Ready 短句来自 Kenney CC0 Voiceover Pack；配音人员和原始许可保存在 licenses/Kenney-Voiceover-Credits.txt、Kenney-Voiceover-License.txt。无需新的播放脚本。重播用本时间线标签，结束沿用 GAME_END。原生图形运行按文本事件顺序推进，已记录两次 voiceline_started、正确 Voice 总线和 Voice／SFX 非静音峰值，日志 staging/voice-example-output.log，无资源或脚本错误；临时检查脚本已删除。该项证明时间线与音频路由，不等于鼠标／键盘操作和语音音量／静音检查已完成。

背景替换（2026-11-02）：原 Painterly 背景发布页持续无法取得具体条款，已完整移至 archive/Painterly-unverified-20261102。活动工程的 TestTimeline、GalleryExample 及六张鉴赏卡片改用 JAP 发布的 CC0 原图 sunsetintheswamp.png／coldmountain.png，文件位于 Assets/Backgrounds/JAP，署名见 licenses/JAP-BACKGROUND-CREDITS.md。没有修改图片。原生 Dialogic 图形运行已检查两张背景及中文对白，渲染图为 staging/jap-sunset-render.png、staging/jap-mountain-render.png，日志为 staging/jap-background-render.log；临时运行脚本已删除。检查使用正式背景 API，不代替鼠标／键盘菜单操作；原技术档若存有旧 Painterly 路径，应重新进入背景示例。当前 Windows 包已重新导出。搬迁副本随后同步了本次背景替换、分辨率设置、AudioExample 语音示例和默认 Voice 总线，再次使用副本引擎导出；独立玩家目录的包已更新，NVIDIA OpenGL 图形启动 180 帧退出码 0，无资源或脚本错误。副本编辑器成功启动，但窗口控制仍报 failed to activate captured window，未完成编辑操作。

外部制作工具只负责交付图片、音频及 Dialogic 原生角色／时间线资源。将文件复制到 `game/Assets/` 和 `game/content/` 后，在 Godot 内等待导入、确认引用并运行。交付文件包含其许可和署名；`licenses/` 为发行许可副本目录。

不把外部工具数据库、API 密钥、缓存或绝对路径复制进游戏。Windows 不区分大小写，本工程统一使用模板已有的 `Assets/` 拼写。`cangqi/` 是既有作品仓库，本次没有迁移或修改其中的原文。


音乐输出补充验证：使用当前工程的 Dialogic.Audio.update_audio 接口与真实 WASAPI 驱动运行，两首音乐均在 Music 总线上播放超过 2.9 秒，Master 总线峰值分别为 -8.36 dB（Teller）与 -15.91 dB（Skye）；调用原生停止后 is_channel_playing 为 false，Audio.info 为空。日志：staging/music-output.log。该结果验证解码、播放、路由和停止，不代替尚未完成的全部鉴赏菜单交互；临时运行脚本已删除。


右侧结果补充验证：临时无窗口运行保持官方球运动与碰撞脚本不变，仅把左球拍初始位置设到 y=16，使球自然越过左侧边界；finished=right、PongResult=right，时间线显示“右侧获胜”。日志 staging/pong-right-result.log。没有直接调用结束函数或伪造结果变量，未修改正式玩法场景；该项验证原生碰撞到剧情分支的连接，不代替玩家输入整局检查。临时脚本已删除。
