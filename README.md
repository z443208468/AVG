# 苍岐文字 AVG 开发工程

部署与验收进行中，尚未完成全部交付条件。范围以 [搭建计划](docs/AVG引擎框架搭建执行计划.md) 为准，`cangqi/` 作品仓库保持原状。2026-11-02 用户要求改为后台推进后，停止前台窗口、鼠标和键盘操作。

## 本地入口

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\启动编辑器.ps1
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\启动游戏.ps1
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\导出Windows.ps1
```

脚本通过 `$PSScriptRoot` 定位本地引擎与 game。编辑器入口使用原生 `--single-window --accessibility always`，文件对话框留在编辑器内。当前编辑器已关闭“运行前保存”，以保护已有未保存场景；本轮没有保存或丢弃该场景。

技术预览包为 `dist/windows/CangqiAVG.exe`、同目录 pck 和 licenses。搬迁开发副本在 `staging/relocated-project/`，独立玩家副本在 `staging/standalone-player/`。没有正式剧情内容。

本轮后台构建已从搬迁副本成功导出并同步至 dist/windows；包内原生检查确认六个鉴赏资源、正常卡片尺寸及取消条件选项均已包含。正在运行的 standalone-player 保留本轮界面验收所用的上一份包，未在进程运行期间覆盖；最新条件选项尚未在该运行副本实测。

## 固定上游

| 来源 | 版本／提交 | 用途 |
|---|---|---|
| Godot 官方 Windows 标准版 | 4.7.2.stable.official.ed1daf0bf | 本地便携引擎及匹配导出模板，已核对官方 SHA512 |
| [Dialogic](https://github.com/dialogic-godot/dialogic) | alpha 20，e301e1bb5e62e6de22c6b7748c4372d0570bb4a7 | 剧情、演出、变量、历史、声音及存档 |
| [Dialogic2FantasyTemplate](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate) | 4df229d40bd51e6b751105abb57914722e5d9ec0 | 菜单、分页存读档、设置及阅读样式 |
| [DialogicTemplate](https://github.com/wtmenten/DialogicTemplate) | 9b2a597851085f39f4519f9582976cab5fc3076d | 五个鉴赏组件文件 |
| [Godot 官方 Pong](https://github.com/godotengine/godot-demo-projects/tree/master/2d/pong) | b761b4cd5718a7118f2c95eb55f181d0a5f004f1 | 现成小游戏 |
| [Noto Sans SC](https://github.com/google/fonts/tree/main/ofl/notosanssc) | 本地字体，SIL OFL | 中文 |

许可及署名见 licenses。界面音效／语音使用 Kenney CC0，音乐使用 Kevin MacLeod CC BY 4.0，JAP 背景使用 CC0。许可未确认的 Painterly 背景已归档并退出活动工程；角色沿用模板 MIT 分发声明，依据见 licenses/TEMPLATE-ASSET-SOURCES.md。

## 实际验证结果

区分界面操作与程序检查，不把后台检查算作鼠标键盘验收。

| 功能 | 已取得的证据 |
|---|---|
| 编辑器 | 实际在可视化及文本模式编辑、保存 FrameworkExample；原生新建 EditorExample.dch、填写中文姓名、导入立绘并保存；点击 Play Timeline，预览显示姓名、对白和立绘 |
| 阅读 | 独立包实际点击／回车推进、方向键选择；自动与已读快进停在选择处；历史回看、滚动和 Esc 返回。此前 H 隐藏／恢复及隐藏期间不推进已验证 |
| 人物演出 | 独立包实际运行双人物入退场、镜像、说话者明暗、日落到雪山转场、悲伤／开心／生气表情、分段对白及停顿；输入框接受“中文测试” |
| 设置 | 实际操作全屏及三种窗口尺寸；1600×900 冷启动完整显示。字号 44、自动速度 0.4、两项快进规则及五路音量 0.65／0.5／0.35／0.2／0.1 冷启动保留。文字速度默认声明遗漏已修正，再设 3.24 并冷启动复核滑块；主音量零值和恢复默认已操作，最后还原默认 |
| 手动／分页存档 | slot_0 保存、覆盖确认和读取已验证；独立包在 Pong 暂停后保存 slot_2，实际切换第 2／15／1 页；删除确认框和取消已操作，未提交删除 |
| 快捷／自动档 | 此前 F5／F9、自动档及冷启动继续已验证。本轮独立包双人物舞台 F5 保存，退出后从第 15 页快捷槽恢复同一背景、人物与原对白；原生档内 TextInput 为“中文测试”，Audio 保留当时曲目 |
| Pong 往返 | 独立包通过剧情进入，操作键盘并自然得到左右结果，返回对应对白和各自结局；重试、暂停、Backspace 取消此前已验证 |
| Pong 冷启动 | 独立包读取 slot_2 中途档后自然完成比赛，返回左侧结果；此前 slot_1 在暂停物理条件下五项状态与档内数值严格一致，见 staging/pong-restore-values.log |
| 条件选项 | 最新配置使用原生条件：取消时隐藏记录结局选项。后台解析确认 left／right 显示、cancel 隐藏；这项最新变化尚待界面复核 |
| 历史 | 按 alpha 20 修正 Leave 名称及 all_choices 字典结构。独立包实际显示人物退场、可见选项与选中项加粗，占位文字消失；中文字号和左边距已配置 |
| 鉴赏 | 修正图库锚点布局及卡片零最小尺寸；独立包六张卡正常显示，左右结局跨周目、冷启动保留，未读卡锁定；实际点击右侧结局卡回放后返回标题。此前左侧回放保留继续指针已验证 |
| 背景 | 独立包通过选项实际切换 JAP 日落／雪山，中文对白正常，返回标题成功 |
| 音乐 | 独立包实际进入 Teller／Skye，各自播放、停止、返回标题；Skye 播放后 F5 档内为正确 MP3，停止后 Audio.info 为空。此前真实 WASAPI 检查非静音输出、播放推进及停止，见 staging/music-output.log |
| 语音／音效 | 原生 AudioExample 已验证两次 Voice 事件及 Voice／SFX 非静音输出，见 staging/voice-example-output.log；独立包该入口完整界面流程仍待检查 |
| 搬迁／独立包 | 搬迁副本用自己的引擎和导出模板成功导出。仅含 exe／pck／许可的 standalone-player 已实际完成新游戏、舞台阅读、存读档、Pong 两种结果及结局回放。运行环境仍是本开发机；搬迁副本编辑器的实际编辑／预览尚未完成 |

## 必要修改

- Dialogic Core/DialogicGameHandler.gd：读档等待布局 ready，恢复子系统后启动时间线，修复自动档捕获隐藏文本框；保留原生 DialogicSaveState。
- main_menu.gd：启动加载全局已读；鉴赏回放关闭自动档并保留继续指针，正常读档恢复自动保存。
- 原生 test_timeline_scene.gd：预览先加载已读并关闭自动保存，避免覆盖玩家继续点；修改后实际预览复核待完成。
- project.godot／tab_options.gd：声明 text_speed 默认值供冷启动加载；沿用显示下拉框及 display_mode，设置尺寸后调用 Window.move_to_center。
- 模板控件：中文字体、分轨音量、字号、帮助排版、快捷键、七个原生选择按钮、存档专用槽及名称裁切。
- history_message.gd／tscn：适配 alpha 20 当前事件结构，调整中文字号与边距。
- 鉴赏组件：保留 TimelineMeta／卡片／已读判断；配置 GalleryTab 的 layout_mode=1 与卡片最小尺寸，恢复网格布局。
- integration 中只接 Dialogic Background／Call，映射本玩法的球、方向、速度、球拍并回传 PongResult；无通用小游戏管理器和第二套存档协议。

## 剩余验收与限制

- 搬迁副本编辑器内实际修改、保存、预览；新角色第二种表情配置；预览不改写已读／继续点的实际复核。
- 空存档启动；删除目前仅验证确认与取消；小游戏返回标题再进入及最新取消条件选项的界面复核。
- AudioExample 完整界面流程；全部卡片解锁后的冷启动菜单复核，以及背景／音乐卡回放路径。
- 最新帮助／历史边距、长中文段落及字号上限的完整布局复核；长段落沿用原生滚动文本框。
- 无窗口导入／导出退出码为 0，但有编辑器退出泄漏提示。verbose 定位为 UndoRedo、预览 Node2D／Sprite2D、图标纹理及相关脚本，共 19 个 ObjectDB、4 个 CanvasItem、4 个资源，另有两个 DummyTexture RID；不是旧记录中仅两个 UndoRedo 的状态。多编辑器并存还会出现本地调试 socket 绑定失败。尚未重写上游编辑器清理逻辑。
- 最新源码构建不等于以上界面项通过，不能声称搭建计划全部完成。

用户电脑工作期间只运行后台命令，不激活、点击、关闭或重新启动前台编辑器／玩家窗口。剩余界面项保留待验。

## 接入与本机控制说明

新增人物、时间线、CG／音乐、小游戏状态和导出方式见 [AVG开发接入说明](docs/AVG开发接入说明.md)。外部制作工具留在 Project 外，交付资源落入 game 并用 res:// 引用。

Windows 10 的 Computer Use 截图故障曾修复。原 helper、候选与回退入口在 `C:/Users/Administrator/.codex/tmp/win10-capture-repair-20261102/`；这是非官方本机兼容补丁，原签名失效，未修改游戏引擎、玩家包或系统安全设置。完整先前记录见 `archive/README-before-ui-validation-20261102.md`。交换鼠标键设置保持原状；恢复界面验收时必须重新枚举窗口。
