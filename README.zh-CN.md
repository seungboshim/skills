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

### truman

把今天的开发痕迹做成第三人称观察类纪录片剧集。

- 汇总 commit、reflog、Claude 会话里你输入的发言与 shell 历史，再编成剧本
- 季与集数会累积，没做完的事就成为下集预告；同一项反复出现时会写成「连续三集登场」
- 结尾两块（制作笔记、下集预告）只写可观测的信号，可以直接当复盘用
- 采集全部基于本地文件，只读，不联网

### date-sim

在聊天里完整跑一次模拟相亲，用来训练对话习惯。

- 只需选难度、场地和对象，就会进行 8~12 轮。每轮给出好感度变化和一句点评
- 对方身上有一个雷区和一个隐藏需求。需求全程不公开，只在报告里揭晓
- 结束后给出复盘报告：自我陈述占比、提问次数、三个转折点，以及只有一条的下次练习课题
- 次数累积后会和上一次对比，同一条指摘出现三次以上就标记为「顽疾」
- 平淡的回答不会得高分。对方替你把话都接住的设定练不出东西

### prompt-mbti

把你一直以来对智能体说过的话全部数一遍，诊断你的指令习惯。

- 用指令长度、工作时段、要求确认的频率、仓库集中度四条轴，给出 16 型中的一个
- 依据全是真实数字。不用答题，它数的是你已经说过的话
- 还会给出口头习惯和字母缩写（`ㄱㄱ`、`ㅇㅋ`）排行
- 指标距阈值三个百分点以内会标为「边界型」，不硬往一边推
- 不输出指令原文，只给数值与词频，也不联网

### diggz-radio

把当前开发任务和情绪编译成可播放的独立音乐电台。

- 将工作场景与希望音乐带来的方向（push、hold、cool-down）分开判断
- 不按分数罗列歌曲，而是把已验证曲目编辑成 `entry → lock → turn → landing` 能量曲线
- 使用官方 YouTube IFrame Player，点击开始前保持静音
- 不编造曲目、视频 ID 或播放量，也不读取浏览器 Cookie 或使用非官方 Music API

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
/plugin install truman@seungboshim-skills
/plugin install date-sim@seungboshim-skills
/plugin install prompt-mbti@seungboshim-skills
/plugin install diggz-radio@seungboshim-skills
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
