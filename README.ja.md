# Claude Code Skills

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

[@seungboshim](https://github.com/seungboshim) による Claude Code スキルのコレクションです。

---

## ⭐ korean-tone — Claude の韓国語が機械翻訳っぽいとき

> **"이 함수에 대해 리팩토링을 진행하겠습니다"**
>
> Claude が韓国語で書くと、こういう文になる。意味は合っているのに、人が書いた感じがしない。
> korean-tone はその硬さだけを取り除く — **コードと正確さはそのままに。**

### こう変わる

```diff
- 이 함수에 대해 리팩토링을 진행하겠습니다.  (「この関数について リファクタリングを実施します」)
+ 이 함수를 리팩토링할게.                     (「この関数をリファクタリングするね」)

- handler 가 stub 이었다.
+ 웹훅을 받아놓고 저장을 안 했어. 껍데기만 있고 안이 비어 있던 거지.
  (専門用語は消さずに通訳する —「webhook を受け取って保存していなかった。
   殻だけあって中身が空だったわけ」)
```

識別子は残る。`client_id` は `client_id` のまま — **リポジトリで検索できる名前
(関数・ファイル・フィールド・コミット) は座標であって、訳す対象ではない。**

Claude 自身の作業語彙もユーザー向けの文面から取り除く:

```diff
- [충돌 A] OCR 품질 게이트를 어떻게 처리할까요?
+ AI 가 손글씨를 잘 읽는지 언제 확인할까요?
  (「衝突 A の OCR 品質ゲートをどう処理しますか」→「AI が手書きをちゃんと読めるか
   いつ確認しますか」)
```

### 二層で動く

多くのスタイルガイドは「こう書け」で終わり、モデルがぶれても捕まえられない。
korean-tone はその上に**検査層**を重ねる。

| 層 | 何を | どうやって |
|---|---|---|
| **ソフト** — スキル | 書き方を決める | Claude が韓国語で話すとき常に適用 |
| **ハード** — `tone-linter` フック | ぶれを捕まえる | 韓国語 `.md` を保存するたびに翻訳調をスキャン |

パターンは国立国語院の論文、Toss のテクニカルライティングガイド、イ・オドク『우리글 바로쓰기』
から抽出。**誤検出のほぼない error 級**と**頻度で判断する warn 級**に分かれる。
コードブロック・インラインコード・URL は除外、`<!-- tone-lint: off -->` でファイル単位の無効化も可能。

書き込みをブロックはしない — 次のターンで直せるよう Claude に伝えるだけ。

### インストール

```bash
/plugin marketplace add seungboshim/skills
/plugin install korean-tone@seungboshim-skills
```

フックも一緒に入る。`npx skills` を使う場合はフックの
[個別登録](skills/korean-tone/hooks/README.md)が必要。

---

## その他のスキル

### shimmy-tone

開発ブログ (velog) の執筆ボイス — 日常的な比喩、釣りタイトルとどんでん返し、ミームと絵文字で
難しい概念を楽しく教える。korean-tone の上に重なる個人向けスキルで、翻訳調の禁止は維持しつつ
「絵文字は控えめに」のガードだけを意図的に外す。

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

---

## インストール

### Claude Code プラグイン経由 (推奨)

```bash
/plugin marketplace add seungboshim/skills
/plugin install korean-tone@seungboshim-skills
```

必要なものだけ選んで:

```bash
/plugin install shimmy-tone@seungboshim-skills
/plugin install feature-flow@seungboshim-skills
/plugin install feature-flow-superpowers@seungboshim-skills
/plugin install daily@seungboshim-skills
/plugin install worklog@seungboshim-skills
/plugin install tailwind-design-system@seungboshim-skills
```

### skills.sh 経由 (任意のエージェント)

```bash
npx skills add seungboshim/skills
```

Claude Code 以外のエージェントでも使える。ただし korean-tone のフックは
[個別登録](skills/korean-tone/hooks/README.md)が必要。

## ライセンス

MIT
