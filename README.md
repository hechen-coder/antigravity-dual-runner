# Antigravity Windows Multi-Instance Dual Runner (Physical Isolation)

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-blue.svg)](#)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#)
[![Antigravity](https://img.shields.io/badge/Antigravity-Multi--Instance-orange.svg)](#)

[中文使用指南 (Chinese Guide)](README_使用指南.md) | [English Documentation](#english-guide)

---

## 简体中文

针对 Google Antigravity 的企业级 **Windows 原生物理隔离多开/双开** 工具包。

### 核心亮点
* **彻底根治“账号窜位”**：依托 Windows 原生 `runas` 独立用户身份隔离，拥有独立的 Windows 安全标识符（SID）与独立的凭据保险库，彻底解决共享凭据管理器（`gemini:antigravity`）造成的串号与登录态覆盖。
* **数据目录整洁收纳**：所有副账号的配置、数据、缓存完整收敛于主用户目录下的 `%USERPROFILE%\Antigravity2`（或 `.antigravity-profile2`），不污染 `C:\Users\` 系统根目录。
* **长效便携与解耦安装**：运行时启动核心固化部署于常驻目录，**即使后续将本 Git 仓库或安装文件夹随意移动、重命名甚至删除，桌面快捷方式依然正常工作**。
* **一键永久免密秒开**：通过 Windows 凭据管理保存登录状态，仅需首次输入一次密码，后续直接双击秒开。
* **0 黑窗口与 0 卡顿引擎**：采用 Windows 原生 `wscript.exe` 静默引擎，0 秒黑窗口闪烁，彻底移除全盘重复扫描，启动耗时仅需毫秒级。
* **Google OAuth 登录无缝联动**：内置自动检测宿主 Chrome/Edge 浏览器并静默配置副用户协议关联，确保首次授权弹窗 100% 顺畅。

### 目录文件清单与功能介绍

| 类别 | 文件名 | 详细功能介绍 |
| :--- | :--- | :--- |
| **核心安装** | `1_Setup_DualUser.bat` | **【首次必跑】一键环境初始化安装脚本**（自动 UAC 提权、配置用户、权限、注册表与快捷方式） |
| **日常启动** | `2_Launch_Account2.bat` | 日常控制台启动器入口（通过 `runas /savecred` 唤起副账号，适合排错调试） |
| **静默引擎** | `launch_silent.vbs` | **【静默秒开引擎·宿主端】（桌面快捷方式所绑定）**，彻底消灭 CMD 黑窗口弹窗 |
| **静默引擎** | `worker_silent.vbs` | **【静默秒开引擎·副用户端】**，以隐藏窗口模式在隔离会话中拉起主程序 |
| **工作跳板** | `internal_worker.bat` | 隔离环境内部执行跳板（注入代理、注册浏览器协议、携带独立 profile 启动程序） |
| **便携自愈** | `修复或创建桌面快捷方式.bat` | **【一键自愈】** 移动文件夹后双击 1 秒自动根据最新路径刷新校准快捷方式 |
| **维护排错** | `重置凭据.bat` | 凭据清理工具（若密码输错，一键清除已缓存的 Windows 凭据以便重新输入） |
| **辅助生成** | `Create_Desktop_Shortcut.vbs` | 快捷方式底层生成脚本（自动绑定官方图标，兼容系统桌面与 `D:\桌面`） |
| **原始保留** | `Antigravity_Account2.bat` | 原始基于环境变量方案的旧版启动脚本（100% 原样保留留档） |
| **脚手架** | `generate_scripts.py` | 全套工程代码生成与构建脚本（以 GBK/CRLF 格式规范编译输出） |

### 快速开始
1. 以管理员身份运行 `1_Setup_DualUser.bat` 完成一次性初始化。
2. 双击桌面的【Antigravity (账号2 - 独立隔离)】图标，首次启动在黑框盲打输入默认密码：`Anti@2026!Pass` 并回车。
3. 随后即可秒开第二个 Antigravity 实例并独立登录副账号。

详细说明与排错指引请查阅 [README_使用指南.md](README_使用指南.md)。

---

## English Guide

An enterprise-grade, physically-isolated multi-instance runner for Google Antigravity on Windows 10 & 11.

### Why Physical Isolation?
Unlike conventional multi-instance workarounds that only modify environment variables (e.g. `USERPROFILE` or `APPDATA`), Antigravity relies on Electron, Chromium DPAPI, and the Windows Credential Manager to persist authentication tokens. Under the same Windows user account, all processes share the exact same Security Identifier (SID) and Credential Vault (`gemini:antigravity`), which inevitably leads to session collisions and account overrides.

This project creates a lightweight, restricted local Windows account combined with `runas /savecred` and registry profile redirection:
1. **Zero Credential Collision**: Independent Windows SID and dedicated Windows Credential Vault.
2. **Clean Storage**: Data cleanly isolated in `%USERPROFILE%\Antigravity2`.
3. **Decoupled Runtime**: Moving or deleting the repository folder will NOT break your desktop shortcut.
4. **Permanent Passwordless Launch**: Enter the password once on first launch; subsequent launches are instant.
5. **Zero Console Window (Silent)**: Powered by `wscript.exe` background execution without annoying black CMD popups.
6. **Seamless OAuth**: Automatically registers default browser protocols for OAuth authorization popups.

### File Structure & Roles

| Category | File Name | Description |
| :--- | :--- | :--- |
| **Installer** | `1_Setup_DualUser.bat` | One-click administrator setup script (creates account, sets permissions & shortcuts) |
| **Launcher** | `2_Launch_Account2.bat` | Standard console launcher via `runas /savecred` |
| **Silent Runner** | `launch_silent.vbs` | Host-side silent launcher attached to the desktop shortcut (no black CMD window) |
| **Silent Runner** | `worker_silent.vbs` | Worker-side silent runner executing inside the isolated session |
| **Worker** | `internal_worker.bat` | Core worker trampoline (configures proxy, registers browser protocol, launches app) |
| **Self-Healing** | `修复或创建桌面快捷方式.bat` | Portable shortcut repair tool (updates shortcut target in 1 second if folder moved) |
| **Maintenance**| `重置凭据.bat` | Clear saved Windows credentials in case of wrong password |
| **Helper** | `Create_Desktop_Shortcut.vbs` | Generates desktop shortcut with official high-resolution icon |
| **Legacy** | `Antigravity_Account2.bat` | Legacy environment-variable based runner (preserved for reference) |
| **Generator** | `generate_scripts.py` | Project scaffold & compiler exporting scripts in standard GBK/CRLF format |

### Quick Start
1. Run `1_Setup_DualUser.bat` as Administrator.
2. Double-click the desktop shortcut `Antigravity (账号2 - 独立隔离)`. On the first launch, type the default password: `Anti@2026!Pass` and press Enter.
3. Enjoy your isolated second Antigravity instance!

For troubleshooting, proxy configuration, and FAQs, refer to [README_使用指南.md](README_使用指南.md).

---

## License
MIT License.
