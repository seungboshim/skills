# Claude Code Skills

[한국어](README.md) | [English](README.en.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

[@seungboshim](https://github.com/seungboshim) による Claude Code スキルのコレクションです。

<p align="center">
  <strong>korean-tone は独立したリポジトリに移動しました →
  <a href="https://github.com/fromshim/korean-tone">fromshim/korean-tone</a></strong><br>
  <code>/plugin install korean-tone@fromshim</code>
</p>

---

## スキル一覧

### korean-tone → [fromshim/korean-tone](https://github.com/fromshim/korean-tone)

Claude の韓国語を自然にしつつ、`client_id` のようなコード識別子はそのまま保持します。
執筆スキルと `tone-linter` フックを同梱。現在は独立リポジトリで管理していますが、
このマーケットプレイスからも引き続き導入できます。

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

### handoff

コンテキストが 80% を超えるとハンドオフ文書を作成し、`/clear` 後の新しいセッションへ引き渡す仕組み。

- 自動要約 (compact) ではなく、自分で整理した文書から次のセッションを始める
- 85・90・95% を超えるたびに文書を書き直す — 遅れて整理しても最新の状態が残る
- `/handoff` で好きなタイミングに手動更新できる
- Stop・SessionStart フックが同梱されるため、自動検知は Claude Code プラグインとして導入したときのみ動作する

### tailwind-design-system

Tailwind CSS + Next.js プロジェクト向けのデザインシステム ビルダー・リファクタリングガイド。

- 初期のデザインプロンプティングから style audit、semantic token 定義、共有コンポーネント抽出、マイグレーション、継続的な compliance レビューまで
- 新規プロジェクト (Phase 0: デザインプロンプティング) と既存プロジェクト (Phase 1: style audit) の両方をサポート
- デザイントークン遵守のための ongoing audit モード

### truman

今日の開発の痕跡を三人称の観察ドキュメンタリー風エピソードに仕上げる。

- コミット、reflog、Claude セッションに残った自分の発言、シェル履歴を集めて台本に編集する
- シーズンと話数が積み上がり、終わらなかった作業は次回予告になる。同じ項目が続けて出たら「3 話連続登場」と書く
- 最後の 2 ブロック (制作ノート・次回予告) は観測できた事実だけを書くので、そのまま振り返りに使える
- 収集はすべてローカルファイルで読み取り専用。ネットワークは使わない

### date-sim

チャットで模擬お見合いを最初から最後まで進めながら、会話の癖を訓練する。

- 難易度・場所・相手を決めるだけで 8〜12 ターン進む。毎ターン好感度の変化と一行の講評がつく
- 相手には地雷が 1 つ、隠れたニーズが 1 つある。ニーズは最後まで隠し、レポートで初めて明かす
- 終わったら振り返りレポート。自分の話の比率、質問した回数、分岐点 3 つ、次に練習する課題 1 つ
- 回数が積み上がると前回と比較し、同じ指摘が 3 回以上出たら「慢性化」として表示する
- 無難な返しには点をあげない。相手が全部リードしてくれる設定では訓練にならない

### prompt-mbti

これまでエージェントに投げてきた言葉を全部数えて、指示の癖を診断する。

- 指示の長さ、作業する時間帯、確認を求める頻度、リポジトリの偏りの 4 軸から 16 タイプのいずれかを出す
- 根拠はすべて実測値。設問に答えるのではなく、すでに言った言葉を数える
- 口癖と字母表現 (`ㄱㄱ`、`ㅇㅋ`) のランキングも出る
- しきい値まで 3 ポイント以内なら「境界型」と書く。無理にどちらかへ寄せない
- 指示の原文は出力しない。数値と語の頻度だけ。ネットワークは使わない

### diggz-radio

今の開発作業と気分を、再生できるインディー・ラジオへコンパイルする。

- 作業シーンと、音楽に求める方向（push・hold・cool-down）を分けて判断する
- 検証済みの曲を `entry → lock → turn → landing` のエネルギー曲線に編集する
- 公式 YouTube IFrame Player を使い、開始ボタンを押すまでは再生しない
- 曲名・動画 ID・再生数を創作せず、非公式 API やブラウザ Cookie も使わない

---

## インストール

### プラグインとして導入

Claude Code 専用です。スキルを個別に選んで導入し、`/plugin` で切り替えられます。

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

### skills.sh から導入

Claude Code のほか Codex、Cursor、Antigravity、Amp、Gemini CLI などにも導入されます。
下のコマンドはこのリポジトリのスキルを一度にまとめて取得します。

```bash
npx skills add seungboshim/skills
```

> korean-tone は [fromshim/korean-tone](https://github.com/fromshim/korean-tone) にあります。

## ライセンス

MIT
