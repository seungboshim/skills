# Claude Code Skills

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

[@seungboshim](https://github.com/seungboshim) 创建的 Claude Code 技能集合。

---

## ⭐ korean-tone — 当 Claude 的韩语读起来像机翻

> **"이 함수에 대해 리팩토링을 진행하겠습니다"**
>
> 这是 Claude 写韩语时的默认腔调。意思没错，但不像人说的话。
> korean-tone 只剥掉这层生硬 — **代码和准确性原封不动。**

### 会变成这样

```diff
- 이 함수에 대해 리팩토링을 진행하겠습니다.  (「就该函数 进行重构」)
+ 이 함수를 리팩토링할게.                     (「我来重构这个函数」)

- handler 가 stub 이었다.
+ 웹훅을 받아놓고 저장을 안 했어. 껍데기만 있고 안이 비어 있던 거지.
  (术语不删除，而是翻译 —「收到了 webhook 却没存。只有壳子，里面是空的」)
```

标识符会保留。`client_id` 仍是 `client_id` — **凡是能在仓库里搜到的名字
(函数、文件、字段、提交) 都是坐标，不是散文。** 硬translate 成「客户标识符」会让人再也找不到它。

Claude 自己的工作术语也会从面向用户的文字中清除：

```diff
- [충돌 A] OCR 품질 게이트를 어떻게 처리할까요?
+ AI 가 손글씨를 잘 읽는지 언제 확인할까요?
  (「如何处理冲突 A 的 OCR 质量门」→「什么时候确认 AI 能否读懂手写字」)
```

### 双层运作

多数风格指南止步于「要这样写」，模型跑偏时没有任何东西能兜住。
korean-tone 在其之上加了一层**检查**。

| 层 | 做什么 | 怎么做 |
|---|---|---|
| **软层** — 技能 | 决定怎么写 | Claude 说韩语时规则始终生效 |
| **硬层** — `tone-linter` 钩子 | 抓住跑偏 | 每次保存韩语 `.md` 都扫描翻译腔 |

规则模式取自韩国国立国语院论文、Toss 技术写作指南、李五德《우리글 바로쓰기》。
分为**误报极低的 error 级**和**按频率判断的 warn 级**。
代码块、行内代码和 URL 会被排除；文件中加 `<!-- tone-lint: off -->` 即可整体跳过。

它不会阻止写入 — 只是告诉 Claude 下一轮该改什么。

### 安装

```bash
/plugin marketplace add seungboshim/skills
/plugin install korean-tone@seungboshim-skills
```

钩子会一并安装。若使用 `npx skills`，钩子需要
[单独注册](skills/korean-tone/hooks/README.md)。

---

## 其他技能

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

### tailwind-design-system

Tailwind CSS + Next.js 项目的设计系统构建器与重构指南。

- 从初始设计提示到 style audit、semantic token 定义、共享组件提取、迁移以及持续的 compliance 审查
- 同时支持新项目 (Phase 0: 设计提示) 与现有项目 (Phase 1: style audit)
- 用于设计令牌合规的 ongoing audit 模式

---

## 安装

### 通过 Claude Code 插件 (推荐)

```bash
/plugin marketplace add seungboshim/skills
/plugin install korean-tone@seungboshim-skills
```

按需选装：

```bash
/plugin install shimmy-tone@seungboshim-skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install daily@seungboshim-skills
/plugin install worklog@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```

### 通过 skills.sh (任意 agent)

```bash
npx skills add seungboshim/skills
```

也可在 Claude Code 之外的 agent 中使用，但 korean-tone 的钩子需要
[单独注册](skills/korean-tone/hooks/README.md)。

## 许可证

MIT
