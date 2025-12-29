import React from 'react';
import { Link } from 'react-router-dom';

const Privacy = () => {
  return (
    <div className="privacy-container">
      <div className="privacy-content">
        <h1>プライバシーポリシー</h1>
        <p className="last-updated">最終更新日: {new Date().toLocaleDateString('ja-JP')}</p>
        
        <section>
          <h2>1. 個人情報の取り扱いについて</h2>
          <p>
            本ウェブサイト（以下「当サイト」）では、ユーザーの個人情報を適切に管理し、保護することを重要視しています。
            当サイトは、ユーザーが入力した情報（目標金額、時給、労働時間など）をブラウザのローカルストレージに保存する場合がありますが、
            これらの情報はユーザーのデバイス内にのみ保存され、当サイトのサーバーに送信されることはありません。
          </p>
        </section>

        <section>
          <h2>2. アクセス解析ツールについて</h2>
          <p>
            当サイトでは、Vercel Analyticsを使用してアクセス解析を行っています。
            このツールは、トラフィックデータの収集のためにCookieを使用する場合があります。
            収集されるデータは匿名化され、個人を特定するものではありません。
          </p>
        </section>

        <section>
          <h2>3. 広告配信について</h2>
          <p>
            当サイトでは、第三者配信の広告サービス（Google AdSense等）を利用する場合があります。
            これらの広告配信事業者は、ユーザーが訪問したウェブサイトの情報に基づいて、
            適切な広告を配信するためにCookieを使用する場合があります。
          </p>
          <p>
            Google AdSenseのCookieを無効にする方法については、
            <a href="https://www.google.com/settings/ads" target="_blank" rel="noopener noreferrer">
              Googleの広告設定ページ
            </a>
            をご確認ください。
          </p>
        </section>

        <section>
          <h2>4. 外部リンクについて</h2>
          <p>
            当サイトから外部のウェブサイトへのリンクを提供している場合がありますが、
            リンク先のウェブサイトにおける個人情報の取り扱いについては、当サイトでは責任を負いかねます。
          </p>
        </section>

        <section>
          <h2>5. プライバシーポリシーの変更について</h2>
          <p>
            当サイトは、法令の変更やサービスの内容変更に伴い、
            本プライバシーポリシーを予告なく変更する場合があります。
            変更後のプライバシーポリシーは、本ページに掲載した時点で効力を生じるものとします。
          </p>
        </section>

        <section>
          <h2>6. お問い合わせ</h2>
          <p>
            本プライバシーポリシーに関するお問い合わせは、
            当サイトの管理者（takotakotako53-at-gmail.com）までご連絡ください。
          </p>
        </section>

        <div className="back-link">
          <Link to="/">← カレンダーに戻る</Link>
        </div>
      </div>
    </div>
  );
};

export default Privacy;

