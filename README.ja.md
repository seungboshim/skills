# Claude Code Skills

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

[@seungboshim](https://github.com/seungboshim) による Claude Code スキルのコレクションです。

## スキル一覧

### feature-flow

画面・機能を最初から最後まで通すサイクルガイド — scope → plan → execute → review → commit → document。

- 9 ステップ、各遷移ごとにユーザーチェックポイント
- 実行中の Karpathy 4 原則 self-monitoring (Think / Simple / Surgical / Goal-driven)
- 任意の文書化ステップ — `_inbox/{research,spec,patch,scratch}` → `research-notes/` / `feature-specs/` への昇格フロー
- プロジェクト非依存 — 既存のコンベンションに合わせます

### feature-flow-superpowers

feature-flow の superpowers 統合版。各 step で対応する superpowers スキルを明示的に呼び出します。

- [superpowers](https://github.com/obra/superpowers) プラグインが必要
- `superpowers:test-driven-development` による TDD-first 実行
- `superpowers:verification-before-completion` による evidence-based 完了
- 4 原則 ↔ TDD のスタイル衝突を明示的に解決

### daily

セッションのオリエンテーション + 作業レコメンド — backlog・最近のパッチノート・git の状態を読み、「今どこにいるか」のマップと優先順位付きの「何をやるか」リストを生成。

- 読み取り専用 — オリエントとレコメンドのみ、ファイルは編集しない
- backlog/patch のコンベンションを発見 (プロジェクト非依存)
- feature-flow のサイクル入口としてペア

### worklog

作業後のドキュメント化の儀式 — 簡潔な release-note パッチノート + (動作が変わった場合) feature-spec 更新 + backlog チェックを一度に。

- フルサイクルから分離 — どんな作業の後でも単独で呼び出せる
- プロジェクト非依存 — ドキュメントのコンベンションを発見
- feature-flow のサイクル出口としてペア

### tailwind-design-system

Tailwind CSS + Next.js プロジェクト向けのデザインシステム ビルダー・リファクタリングガイド。

- 初期のデザインプロンプティングから style audit、semantic token 定義、共有コンポーネント抽出、マイグレーション、継続的な compliance レビューまで
- 新規プロジェクト (Phase 0: デザインプロンプティング) と既存プロジェクト (Phase 1: style audit) の両方をサポート
- デザイントークン遵守のための ongoing audit モード

## インストール

### skills.sh 経由 (任意のエージェント)

```bash
npx skills add seungboshim/skills
```

### Claude Code プラグイン経由

```bash
/plugin marketplace add seungboshim/skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install daily@seungboshim-skills
/plugin install worklog@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```
