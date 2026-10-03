# Antigravity Windows 原生物理隔离多开/双开使用指南

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-blue.svg)](#)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#)
[![Antigravity](https://img.shields.io/badge/Antigravity-Multi--Instance-orange.svg)](#)

针对 Google Antigravity 的企业级 **Windows 原生物理隔离双开/多开** 方案，彻底根治传统单用户多开造成的**凭据管理器串号冲突**与**登录态覆盖**。

---

## 一、 核心机制与原理

1. **真实独立安全标识（SID）**：
   - 基于 Windows 原生独立受限本地用户 `Antigravity2`，拥有独立的 Windows 安全标识符（SID）与独立的 Windows 凭据保险库。
   - 彻底解决共享凭据管理器（`gemini:antigravity`）造成的账号被踢与登录覆盖。
2. **数据收纳与零根目录污染**：
   - 所有副账号的配置、数据、缓存完整收敛于主用户目录下的 `%USERPROFILE%\Antigravity2`（或 `.antigravity-profile2`），不污染 `C:\Users\` 根目录。
3. **固化部署与高容错性**：
   - 运行时核心脚本自动固化于专属数据目录中，桌面快捷方式直接指向固化启动器。
   - 即使后续移动、重命名甚至删除本仓库文件夹，桌面快捷方式依然长效工作。
4. **一键永久免密秒开**：
   - 通过 `runas /profile /savecred` 结合 Windows 凭据保存，首次输入密码后后续直接秒开。
5. **Google OAuth 登录联动**：
   - 内置自动检测系统 Chrome/Edge 浏览器并静默配置副用户协议关联，确保首次授权弹窗顺畅。
6. **零黑窗口与零卡顿**：
   - 采用 Windows 原生 `wscript.exe` 静默引擎，0 秒黑窗口闪烁，彻底移除全盘重复扫描，启动耗时仅需毫秒级。

---

## 二、 目录文件全景介绍与职责划分

当前工程目录下的文件按功能分类介绍如下：

### 1. 核心安装与日常启动类（日常最核心）

| 文件名 | 类型 | 详细功能介绍 |
| :--- | :--- | :--- |
| **`1_Setup_DualUser.bat`** | 批处理 | **【首次必跑】一键环境初始化安装脚本**<br>• 自动弹出 UAC 管理员提权并安全传递用户主目录路径；<br>• 检查并开启系统 `Secondary Logon`（二次登录服务）；<br>• 自动创建受限本地隔离用户 `Antigravity2`（密码永不过期）；<br>• 递归配置父子目录 ACL 遍历权限（彻底避免 Node.js 模块路径解析崩溃）；<br>• 将静默极速启动套件固化解耦部署到常驻目录；<br>• 自动调用 VBS 在桌面生成专属图标。 |
| **`2_Launch_Account2.bat`** | 批处理 | **日常控制台启动器入口**<br>适合排错与调试。通过 `runas /profile /savecred /user:Antigravity2` 调度工作脚本拉起副账号。 |
| **`launch_silent.vbs`** | VBScript | **【静默秒开引擎·宿主端】（当前桌面快捷方式所绑定）**<br>通过 Windows 原生 `wscript.exe`（GUI 无控制台模式）在后台静默下发启动指令，**彻底消灭 CMD 黑窗口弹窗与黑框闪烁**。 |
| **`worker_silent.vbs`** | VBScript | **【静默秒开引擎·副用户端】**<br>在副账号的隔离会话中以隐藏窗口模式（WindowStyle = 0）拉起工作跳板，确保整个启动流程全程 100% 纯净无黑框。 |
| **`internal_worker.bat`** | 批处理 | **隔离环境内部核心跳板**<br>• 动态向上回溯宿主用户根目录；<br>• 注入网络代理环境变量（默认 7890，可配置）；<br>• 自动检测 Chrome/Edge 浏览器并静默注册协议（确保 Google 登录能弹出网页）；<br>• 携带独立 `--user-data-dir` 参数瞬间拉起 `Antigravity.exe`。 |

---

### 2. 维护与自愈辅助类

| 文件名 | 类型 | 详细功能介绍 |
| :--- | :--- | :--- |
| **`修复或创建桌面快捷方式.bat`** | 批处理 | **【便携自愈工具】**<br>如果您以后把当前项目文件夹移动到了其他任意盘符或路径，直接在新目录下**双击它一下**，1 秒内自动根据当前最新物理路径重新刷新校准桌面的快捷方式。 |
| **`重置凭据.bat`** | 批处理 | **凭据清理工具**<br>如果某次输错密码导致 `runas` 提示 `1326 登录失败` 错误，双击该脚本一键调用 `cmdkey` 清除 Windows 凭据管理器中缓存的旧密码，以便重新输入。 |
| **`Create_Desktop_Shortcut.vbs`** | VBScript | **快捷方式底层生成脚本**<br>被安装脚本和修复脚本调用。自动提取 Antigravity 官方高分辨率图标，同时检测 Windows 系统桌面与独立盘桌面（如 `D:\桌面`），双向生成快捷方式。 |
| **`Antigravity_Account2.bat`** | 批处理 | **您的原始旧版脚本（已 100% 完整原样保留）**<br>基于旧式环境变量篡改方案的兼容启动器，保留在目录中供您随时查看、对比与留档。 |

---

### 3. 构建与开发类（面向 GitHub 开源）

| 文件名 | 类型 | 详细功能介绍 |
| :--- | :--- | :--- |
| **`generate_scripts.py`** | Python | **全套工程代码生成器 / 构建脚手架**<br>内置了整个项目所有批处理和 VBS 的源码模板。负责将所有脚本按 Windows CMD 严苛的 **GBK 字符集 + CRLF 换行符** 编译生成，彻底杜绝中文乱码与字符截断。 |
| **`.gitignore`** | Git 配置 | **Git 版本控制忽略文件**<br>在您上传到 GitHub 时，自动过滤临时日志文件（`*.log`）、系统临时文件和调试缓存，保持仓库清爽专业。 |
| **`debug_tools/`** | 文件夹 | **历史调试测试套件归档**<br>存放此前开发过程中用于验证 Electron 协议调用、`ShellExecuteW` 浏览器关联测试的零散调试脚本，已被 `.gitignore` 自动忽略，不影响主干。 |

---

## 三、 组件协作与执行流程图

```text
【初次环境初始化】:
  运行 1_Setup_DualUser.bat
     │
     ├─► 创建受限本地账户 Antigravity2 (独立 SID)
     ├─► 配置目录 ACL 遍历权限 (防 Node EPERM 崩溃)
     ├─► 部署极速启动套件到常驻数据目录
     └─► 调用 Create_Desktop_Shortcut.vbs 生成桌面快捷方式 (绑定 launch_silent.vbs)

【日常无感秒开启动】:
  双击桌面【Antigravity (账号2 - 独立隔离)】
     │
     ▼
  wscript.exe //nologo launch_silent.vbs (0 黑框)
     │
     ▼ (runas /profile /savecred)
  wscript.exe //nologo worker_silent.vbs (0 黑框)
     │
     ▼
  run_account2.bat (设置代理、注册浏览器协议)
     │
     ▼
  Antigravity.exe --user-data-dir=... (瞬间拉起界面)
```

---

## 四、 快速使用步骤

### 第一步：初次安装与初始化（仅需运行一次）
1. 右键点击 `1_Setup_DualUser.bat`，选择【以管理员身份运行】（或直接双击弹出 UAC 提权提示点击【是】）。
2. 脚本会自动完成本地隔离账户创建、存储目录赋权、注册表 Profile 重定向及桌面快捷方式生成。完成后按任意键关闭。

> **默认创建的隔离身份信息**：
> - 用户名：`Antigravity2`
> - 初始密码：`Anti@2026!Pass`（已配置为永不过期）
> - 实际数据存放：`%USERPROFILE%\.antigravity-profile2`（或 `%USERPROFILE%\Antigravity2`）

---

### 第二步：首次启动并记住凭据
1. 双击桌面上的 **【Antigravity (账号2 - 独立隔离)】** 图标。
2. **首次启动**时若控制台黑框提示输入密码，在键盘盲打输入默认密码：`Anti@2026!Pass` 并按回车（输密码时屏幕不显示字符属 Windows 正常安全机制）。
3. 验证通过后，第二个 Antigravity 窗口将立即打开！在新打开的窗口中登录您的第二个 Google / 团队账号。

---

### 第三步：日常使用（永久免密直接秒开）
- 由于启用了 `/savecred` 凭据持久化保存，从第二次启动开始，您**无需再输入任何密码**！
- 配合本次重构的静默引擎，双击图标后**无黑框闪烁、无多余卡顿，1 秒内直接秒开**。

---

## 五、 常见问题与排查 (Troubleshooting)

### Q1：如果我把这个项目文件夹移动到别的地方了，桌面快捷方式会失效吗？
**解答**：
**完全不会失效！**
1. `1_Setup_DualUser.bat` 在首次配置时，已将启动脚本自动部署到了固定常驻数据目录中。快捷方式默认优先绑定该常驻脚本，因此无论您将本仓库文件夹移动到任何盘符、甚至直接删除下载的安装包，桌面快捷方式均不会失效。
2. 如果您希望快捷方式更新绑定到新移动的目录，只需在新目录下双击 **`修复或创建桌面快捷方式.bat`**，1 秒内即可自动完成重新校准。

---

### Q2：我使用的是 Clash Verge / v2rayN，代理端口不是 7890 怎么办？
**解答**：
打开 `internal_worker.bat`，找到【代理配置】区域进行修改：
```bat
REM 若使用 Clash Verge 默认 7897，修改 PROXY_PORT 即可：
set "ENABLE_PROXY=1"
set "PROXY_HOST=127.0.0.1"
set "PROXY_PORT=7897"

REM 若不需要任何代理（直连），请改为：
set "ENABLE_PROXY=0"
```
保存后重新启动副实例即可生效。

---

### Q3：首次输入密码输错了，提示“1326: 用户名未知或密码错误”？
**解答**：
双击本目录下的 **`重置凭据.bat`**，脚本会自动调用 `cmdkey` 清空旧缓存。之后重新双击桌面图标，即可重新输入正确密码：`Anti@2026!Pass`。

---

### Q4：副账号点击 Google 登录时，没有自动弹出浏览器怎么办？
**解答**：
本工具在启动时已内置全自动检测机制：会自动检索系统中的 Google Chrome 及 Microsoft Edge，并为副用户静默注册 `HKCU\Software\Classes\http` 与 `https` 协议，彻底解决登录不弹窗的问题。
