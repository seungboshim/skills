# Claude Code Skills

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

[@seungboshim](https://github.com/seungboshim) 创建的 Claude Code 技能集合。

## 技能列表

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

### tailwind-design-system

Tailwind CSS + Next.js 项目的设计系统构建器与重构指南。

- 从初始设计提示到 style audit、semantic token 定义、共享组件提取、迁移以及持续的 compliance 审查
- 同时支持新项目 (Phase 0: 设计提示) 与现有项目 (Phase 1: style audit)
- 用于设计令牌合规的 ongoing audit 模式

## 安装

### 通过 skills.sh (任意 agent)

```bash
npx skills add seungboshim/skills
```

### 通过 Claude Code 插件

```bash
/plugin marketplace add seungboshim/skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```
