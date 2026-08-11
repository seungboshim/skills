# Claude Code Skills

[한국어](README.md) | [English](README.en.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

[@seungboshim](https://github.com/seungboshim) 创建的 Claude Code 技能集合。

<p align="center">
  <strong>korean-tone 已迁移到独立仓库 →
  <a href="https://github.com/fromshim/korean-tone">fromshim/korean-tone</a></strong><br>
  <code>/plugin install korean-tone@fromshim</code>
</p>

---

## 技能列表

### korean-tone → [fromshim/korean-tone](https://github.com/fromshim/korean-tone)

让 Claude 的韩语自然流畅，同时保留 `client_id` 等需要检索的代码标识符。
附带写作技能与 `tone-linter` 钩子。现由独立仓库维护，本市场仍保留入口。

### shimmy-tone

开发博客 (velog) 的写作声音 — 用日常比喻、标题党加反转、梗和 emoji 把难懂的概念讲得有趣。
它叠加在 korean-tone 之上：翻译腔禁令保留，但「少用 emoji」这条护栏被刻意解除。

### feature-flow

从头到尾贯穿一个屏幕/功能的完整周期指南 — scope → plan → execute → review → commit → document。

- 9 个步骤,每次过渡都有用户检查点
- 执行期间的 Karpathy 4 原则 self-monitoring (Think / Simple / Surgical / Goal-driven)
- 可选的文档化步骤 — `_inbox/{research,spec,patch,scratch}` → `research-notes/` / `feature-specs/` 晋级流程
- 项目无关 — 适应你现有的约定

### feature-flow-superpowers

feature-flow 的 superpowers 集成版本。每个 step 显式调用对应的 superpowers 技能。

- 需要 [superpowers](https://github.com/obra/superpowers) 插件
- 通过 `superpowers:test-driven-development` 实现 TDD-first 执行
- 通过 `superpowers:verification-before-completion` 实现 evidence-based 完成
- 显式解决 4 原则 ↔ TDD 风格冲突

### daily

会话定向 + 工作推荐 — 读取 backlog、最近的补丁说明和 git 状态，生成"我在哪里"的概览和按优先级排序的"该做什么"清单。

- 只读 — 仅定向和推荐，不修改文件
- 发现你的 backlog/patch 约定（项目无关）
- 作为 feature-flow 的周期入口配套

### worklog

工作后的文档化流程 — 简洁的 release-note 补丁说明 + (行为变化时) feature-spec 更新 + backlog 勾选，一次完成。

- 与完整周期解耦 — 任何一段工作后都可单独调用
- 项目无关 — 发现你的文档约定
- 作为 feature-flow 的周期出口配套

### handoff

上下文超过 80% 时生成交接文档,`/clear` 后把文档交给新会话。

- 用你整理的文档开始下一个会话,而不是自动摘要 (compact)
- 每次超过 85、90、95% 都会重写文档,迟一点整理也能留下最新状态
- 用 `/handoff` 随时手动刷新
- 附带 Stop、SessionStart 钩子,自动检测仅在作为 Claude Code 插件安装时才生效

### tailwind-design-system

Tailwind CSS + Next.js 项目的设计系统构建器与重构指南。

- 从初始设计提示到 style audit、semantic token 定义、共享组件提取、迁移以及持续的 compliance 审查
- 同时支持新项目 (Phase 0: 设计提示) 与现有项目 (Phase 1: style audit)
- 用于设计令牌合规的 ongoing audit 模式

---

## 安装

### 作为插件安装

仅适用于 Claude Code。可逐个选择技能，并用 `/plugin` 启用或停用。

```bash
/plugin marketplace add seungboshim/skills
/plugin install shimmy-tone@seungboshim-skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install daily@seungboshim-skills
/plugin install worklog@seungboshim-skills
/plugin install handoff@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```

### 通过 skills.sh 安装

除 Claude Code 外，还会安装到 Codex、Cursor、Antigravity、Amp、Gemini CLI 等。
下面的命令会一次性获取本仓库的全部技能。

```bash
npx skills add seungboshim/skills
```

> korean-tone 位于 [fromshim/korean-tone](https://github.com/fromshim/korean-tone)。

## 许可证

MIT
