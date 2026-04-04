## 泡椒音乐api

### 搜索音乐请求

https://pjmp3.com/search.php?keyword=周杰伦

返回html

```html
<!--<!DOCTYPE html>-->
<html lang="zh-CN">
  <head>
    <title>
      周杰伦 - 搜索结果 - 泡椒音乐 - 免费无损音乐MP3、FLAC、WAV在线播放下载网站
    </title>
    <meta charset="UTF-8" />
    <meta name="referrer" content="no-referrer" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, shrink-to-fit=no"
    />
    <meta
      content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0"
      name="viewport"
    />
    <meta
      name="keywords"
      content="周杰伦,周杰伦下载,泡椒音乐,泡椒音乐官网,泡椒音乐网,泡椒音乐下载,无损音乐,歌曲下载,高品质音乐,歌曲搜索,音乐免费下载,MP3下载,flac无损下载,wav下载,收费音乐免费下载,付费音乐免费下载,在线mp3网盘音乐下载网站,在线网盘下载"
    />
    <meta
      name="description"
      content="周杰伦搜索结果,已为你搜索到3308条搜索结果,泡椒音乐 - 在线音乐搜索，可以在线免费下载全网MP3付费歌曲、流行音乐、经典老歌等。曲库完整，更新迅速，试听流畅，支持高品质|无损音质"
    />
    <meta name="msvalidate.01" content="9F867A9A00FAEA0A16065EC41618FF40" />
    <link rel="shortcut icon" type="image/png" href="/logo.png" />
    <link rel="dns-prefetch-control" href="on" />
    <meta http-equiv="ClearSiteData" content='"cache","cookies","storage"' />
    <link rel="dns-resolver" href="https://cloudflare-dns.com/dns-query" />
    <link rel="dns-resolver" href="https://dns.google/dns-query" />
    <link rel="dns-resolver" href="https://dns.alidns.com/dns-query" />
    <link rel="dns-resolver" href="https://doh.pub/dns-query" />
    <link
      href="https://npm.elemecdn.com/aplayer@1.10.1/dist/APlayer.min.css"
      type="text/css"
      rel="stylesheet"
    />
    <link
      href="https://npm.elemecdn.com/bootstrap@4.6.1/dist/css/bootstrap.min.css"
      type="text/css"
      rel="stylesheet"
    />
    <link
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
      type="text/css"
      rel="stylesheet"
    />
    <script
      src="https://npm.elemecdn.com/aplayer@1.10.1/dist/APlayer.min.js"
      type="application/javascript"
    ></script>
    <script
      src="https://npm.elemecdn.com/jquery@3.6.0/dist/jquery.min.js"
      type="application/javascript"
    ></script>
    <script
      src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/4.6.1/js/bootstrap.bundle.min.js"
      type="application/javascript"
    ></script>
    <script type="text/javascript">
      // 跳转提示
      if (is_weixn_qq()) {
        window.location.href =
          "https://c.pc.qq.com/middle.html?pfurl=" + window.location.href;
      }

      function is_weixn_qq() {
        var ua = navigator.userAgent;
        var isWeixin = !!/MicroMessenger/i.test(ua);
        var isQQ = !!/QQ\//i.test(ua);
        if (isWeixin || isQQ) {
          return true;
        }
        return false;
      }
    </script>
    <script>
      var _mtj = _mtj || [];
      (function () {
        var mtj = document.createElement("script");
        if (window.location.host == "music.pjmp3.com") {
          mtj.src = "https://node95.aizhantj.com:21233/tjjs/?k=g8u3uq1q37z";
        } else {
          mtj.src = "https://node91.aizhantj.com:21233/tjjs/?k=jfee1h5kk8a";
        }
        var s = document.getElementsByTagName("script")[0];
        s.parentNode.insertBefore(mtj, s);
      })();
    </script>
    <style>
      :root {
        --bs-primary: #1db954;
        --bs-secondary: #2d4263;
        --bs-dark: #121212;
        --bs-light: #f5f5f5;
        --bs-dark-gray: #282828;
        --bs-light-gray: #b3b3b3;
        --bs-green: #1db954;
      }
      body {
        background-color: var(--bs-dark-gray);
        color: var(--bs-light);
        font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        margin: 0;
        padding: 0;
      }
      .g-container {
        max-width: 1200px;
        margin: 0 auto;
      }
      .bottom-border {
        border-bottom: 0.5px solid #ffffff1a;
      }
      .header {
        background-color: var(--bs-dark);
      }
      .header-container {
        padding: 16px 30px;
        display: flex;
        flex-direction: row;
        justify-content: space-between;
      }
      .logo {
        font-size: 24px;
        font-weight: bold;
        letter-spacing: 2px;
        display: flex;
        align-items: center;
        text-decoration: none;
      }
      .logo:hover {
        text-decoration: none;
      }
      .fa-music {
        color: var(--bs-primary);
      }
      .logo-title {
        color: var(--bs-light);
      }
      .logo-title2 {
        color: var(--bs-primary);
      }
      .header-search-btn {
        padding-right: 20px;
      }
      .body {
        padding: 10px;
      }
      .search {
        width: 100%;
        padding: 20px;
        background-color: var(--bs-dark);
        border-radius: 10px;
        margin-bottom: 10px;
      }
      .search-input-icon {
        position: absolute;
        left: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--bs-light-gray);
      }
      .search-input {
        flex: 1;
        position: relative;
      }
      .search-input input {
        flex: 1;
        padding: 14px 20px 14px 45px;
        border-radius: 8px;
        border: none;
        background-color: var(--bs-dark-gray);
        color: var(--bs-light);
        font-size: 1rem;
        transition: all 0.3s ease;
      }
      .search-input input:focus {
        outline: none;
        box-shadow: 0 0 5px var(--bs-primary);
        background-color: var(--bs-dark-gray);
        color: var(--bs-light);
      }
      .search-btn {
        padding: 8px 25px;
        background: var(--bs-primary);
        color: var(--bs-light);
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        margin-left: 10px;
        white-space: nowrap;
      }

      .cc {
        width: 100%;
        padding: 30px;
        margin: 10px auto;
        background-color: var(--bs-dark);
        border-radius: 10px;
      }
      .cc-header {
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 20px;
      }
      .cc-header-left {
        display: flex;
        flex-direction: row;
        align-items: center;
      }
      .cc-header-icon {
        color: var(--bs-primary);
        font-size: 14px;
      }
      .cc-header-title {
        color: var(--bs-light);
        font-size: 21px;
        font-weight: bold;
        letter-spacing: 3px;
      }
      .cc-header-right {
        color: var(--bs-light);
        font-weight: bold;
        padding: 0 5px;
      }
      .cc-body {
        margin: 0;
        padding: 0;
      }

      /* --- 自定义样式以匹配图片风格 --- */

      /* 弹窗主体背景：深灰 */
      .custom-modal-dark .modal-content {
        background-color: #1f1f1f; /* 接近图片中的深色背景 */
        color: #e0e0e0;
        border: 1px solid #333;
        border-radius: 10px; /* 稍微圆润一点的边角 */
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.7);
      }

      /* 标题栏去线，文字居中 */
      .custom-modal-dark .modal-header {
        border-bottom: none;
        padding-bottom: 0;
        justify-content: center;
      }

      .custom-modal-dark .modal-title {
        font-weight: bold;
        color: #fff;
      }

      /* 内容区域 */
      .custom-modal-dark .modal-body {
        text-align: center;
        padding: 20px 30px;
        font-size: 16px;
        color: #b0b0b0; /* 稍微淡一点的灰色文字 */
      }

      /* 4. 重点：域名显示框样式 */
      .domain-box {
        background-color: #121212; /* 比弹窗背景更深，形成凹陷感 */
        border: 1px dashed #444; /* 虚线边框 */
        border-radius: 8px;
        padding: 15px;
        margin-top: 15px;
        margin-bottom: 5px;
      }

      .domain-label {
        font-size: 13px;
        color: #888;
        margin-bottom: 5px;
        display: block;
      }

      .domain-text {
        color: var(--bs-primary); /* 泡椒绿高亮 */
        font-size: 22px;
        font-weight: bold;
        font-family:
          Consolas, Monaco, "Andale Mono", monospace; /* 等宽字体更像代码/地址 */
        user-select: all; /* 用户点击即可全选，方便复制 */
        word-break: break-all;
      }

      /* 底部按钮栏去线 */
      .custom-modal-dark .modal-footer {
        border-top: none;
        justify-content: center;
        padding-bottom: 25px;
      }

      /* 绿色主按钮 (前往发布页) - 仿照图片中的搜索按钮颜色 */
      .btn-paojiao-green {
        background-color: var(--bs-primary); /* 鲜艳的绿色 */
        border-color: #28c76f;
        color: #fff;
        border-radius: 5px;
        padding: 8px 25px;
        font-weight: 500;
        transition: all 0.3s;
      }

      .btn-paojiao-green:hover {
        background-color: #20a059;
        border-color: #20a059;
        color: #fff;
      }

      /* 次要按钮 (我知道了) */
      .btn-paojiao-secondary {
        background-color: transparent;
        border: 1px solid #555;
        color: #aaa;
        border-radius: 5px;
        padding: 8px 25px;
        margin-left: 15px;
      }

      .btn-paojiao-secondary:hover {
        background-color: #333;
        color: #fff;
        border-color: #777;
      }

      /* 右上角关闭叉号改为白色 */
      .custom-modal-dark .close {
        color: #fff;
        text-shadow: none;
        opacity: 0.7;
        position: absolute;
        right: 15px;
        top: 15px;
        padding: 0;
        margin: 0;
      }

      .custom-modal-dark .close:hover {
        opacity: 1;
      }

      /* --- 新增：搜索框下方的发布页提示条样式 --- */
      .fabu-alert {
        width: 100%;
        padding: 15px 20px;
        background-color: var(--bs-dark); /* 跟搜索框背景一致 */
        border-radius: 10px;
        margin-bottom: 10px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap; /* 手机端自动换行 */
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      }

      .fabu-content {
        display: flex;
        align-items: center;
        flex: 1;
        padding-right: 10px;
      }

      .fabu-text {
        color: var(--bs-light);
        font-size: 15px;
        margin-left: 10px;
      }

      .fabu-link {
        color: var(--bs-primary);
        font-weight: bold;
        margin-left: 5px;
        font-family: Consolas, Monaco, monospace;
        font-size: 16px;
      }

      .fabu-btn {
        background-color: var(--bs-primary);
        color: #fff;
        border: none;
        border-radius: 20px;
        padding: 6px 18px;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s;
        white-space: nowrap;
      }

      .fabu-btn:hover {
        background-color: #1ed760;
        color: #fff;
        text-decoration: none;
        transform: translateY(-1px);
      }

      /* 手机端微调 */
      @media (max-width: 576px) {
        .fabu-alert {
          padding: 12px 15px;
        }
        .fabu-text {
          font-size: 13px;
        }
        .fabu-link {
          font-size: 14px;
        }
      }
    </style>
  </head>
  <body>
    <div class="header sticky-top bottom-border">
      <div class="g-container header-container">
        <a class="logo" href="/">
          <svg
            t="1754035445986"
            class="icon"
            viewBox="0 0 1024 1024"
            version="1.1"
            xmlns="http://www.w3.org/2000/svg"
            p-id="6877"
            width="36"
            height="36"
          >
            <path
              d="M0 0h1024v1024H0z"
              fill="#1DB954"
              fill-opacity=".01"
              p-id="6878"
            ></path>
            <path
              d="M627.2 332.8c38.4 0 71.68 10.24 99.84 25.6 40.96 23.04 56.32 61.44 56.32 107.52 2.56 48.64-12.8 94.72-35.84 135.68-48.64 89.6-120.32 158.72-204.8 212.48-58.88 38.4-122.88 64-189.44 81.92-43.52 12.8-87.04 17.92-130.56 23.04-23.04 2.56-40.96-10.24-46.08-28.16-2.56-17.92 5.12-30.72 17.92-40.96 46.08-40.96 92.16-79.36 135.68-122.88 38.4-35.84 76.8-69.12 102.4-115.2 17.92-28.16 28.16-61.44 33.28-94.72 7.68-43.52 15.36-87.04 43.52-125.44 20.48-30.72 48.64-51.2 87.04-61.44 10.24 2.56 23.04 2.56 30.72 2.56zM645.12 296.96c7.68-10.24 15.36-10.24 25.6-10.24 33.28 2.56 46.08-5.12 53.76-38.4 10.24-46.08 28.16-84.48 64-117.76 7.68-7.68 17.92-15.36 28.16-20.48 2.56-5.12 7.68-5.12 15.36-7.68 12.8-2.56 20.48 7.68 15.36 17.92-5.12 10.24-12.8 20.48-20.48 25.6-35.84 33.28-51.2 76.8-56.32 122.88-2.56 20.48 2.56 40.96 12.8 58.88 5.12 10.24 10.24 20.48 7.68 35.84-38.4-46.08-89.6-58.88-145.92-66.56z"
              fill="#1DB954"
              p-id="6879"
            ></path>
          </svg>
          <span class="logo-title">泡椒</span>
          <span class="logo-title2">音乐</span>
        </a>
        <div class="header-search-btn d-flex flex-row align-items-center">
          <i class="fa fa-search"></i>
        </div>
      </div>
    </div>
    <div class="body g-container">
      <!-- 搜索框 -->

      <!-- 搜索框 -->
      <div class="search">
        <div class="d-flex flex-row align-items-center">
          <div class="search-input">
            <i class="fa fa-search search-input-icon"></i>
            <input
              id="keyword"
              type="text"
              name="keyword"
              value="周杰伦"
              class="form-control mr-2"
              placeholder="请输入搜索内容"
              required
            />
          </div>
          <div id="search-btn" class="search-btn">搜索</div>
        </div>
        <script>
          document
            .getElementById("search-btn")
            .addEventListener("click", function () {
              var keyword = document.getElementById("keyword").value.trim();
              if (keyword) {
                window.location.href =
                  "/search.php?keyword=" + encodeURIComponent(keyword);
              } else {
                alert("请输入搜索内容");
              }
            });

          // 支持回车键搜索
          document
            .getElementById("keyword")
            .addEventListener("keypress", function (event) {
              if (event.key === "Enter") {
                event.preventDefault();
                document.getElementById("search-btn").click();
              }
            });
        </script>
      </div>
      <style>
        .search-count {
          color: var(--bs-primary);
          font-weight: bold;
        }
        .search-result-list-header {
          display: flex;
          flex-direction: row;
          justify-content: space-between;
          color: var(--bs-light-gray);
          font-weight: bold;
          padding: 16px 12px;
        }
        .search-result-list-item {
          padding: 16px 12px;
          color: var(--bs-light) !important;
          display: flex;
          flex-direction: row;
          align-items: center;
          justify-content: space-between;
          text-decoration: none;
        }
        .search-result-list-item:hover {
          text-decoration: none;
          background-color: rgba(255, 255, 255, 0.03) !important;
        }
        .search-result-list-item-img img {
          background-color: var(--bs-primary);
          border-radius: 16px;
          width: 50px;
          height: 50px;
          margin-right: 10px;
        }
        .search-result-list-item-left {
          color: var(--bs-light) !important;
          font-weight: bold;
          flex: 1;
          line-height: 25px;
        }
        .search-result-list-item-left:hover {
          color: var(--bs-primary) !important;
        }
        .search-result-list-item-left-song {
          color: var(--bs-light) !important;
          font-weight: bold;
          font-size: 16px;
        }
        .search-result-list-item-left-singer {
          color: var(--bs-light-gray) !important;
          font-weight: normal;
          font-size: 14px;
        }
        .search-result-list-item-left-tag {
          color: var(--bs-light-gray) !important;
          font-weight: normal;
          font-size: 14px;
          padding: 5px 0;
        }
        .search-result-list-item-dl {
          background-color: var(--bs-primary);
          border-radius: 16px;
          padding: 5px;
          width: 30px;
          height: 30px;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .cc-tab a {
          color: var(--bs-light-gray) !important;
          font-weight: bold;
        }
        .cc-tab .active {
          color: var(--bs-primary) !important;
          font-weight: bold;
        }
      </style>
      <!-- 搜索历史记录-->
      <div class="cc">
        <div class="cc-header">
          <div class="cc-header-left">
            <span class="cc-header-icon"
              ><i class="fa fa-music fa-2x mr-2"></i
            ></span>
            <span class="cc-header-title">搜索结果</span>
          </div>
          <div class="cc-header-right">
            找到 <span class="search-count">3308</span> 首相关的歌曲
          </div>
        </div>

        <div class="cc-tab">
          <ul class="nav justify-content-center">
            <li class="nav-item">
              <a class="nav-link active" href="/search.php?keyword=周杰伦"
                >默认音源</a
              >
            </li>
            <li class="nav-item">
              <a class="nav-link " href="/search.php?keyword=周杰伦&source=1"
                >备用音源</a
              >
            </li>
          </ul>
        </div>

        <div class="cc-body">
          <div class="search-result-list-header bottom-border">
            <div>歌曲信息</div>
            <div>操作</div>
          </div>
          <div class="search-result-list-content">
            <a
              class="search-result-list-item bottom-border"
              href="song.php?id=550531860"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s86/95/3059703046.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">那天下雨了</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=228908"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s3s94/93/211513640.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">晴天</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=94237"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s81/2/3200337129.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">七里香</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=94239"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s81/2/3200337129.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">搁浅</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=440615"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s0/93/1794217775.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">花海</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=324244"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/7/83/4087363627.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">青花瓷</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=550531859"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s86/95/3059703046.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">太阳之子</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=550531862"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s86/95/3059703046.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">七月的极光</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=550531865"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s86/95/3059703046.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">爱琴海</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=550531871"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s86/95/3059703046.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">西西里</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=550531867"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s86/95/3059703046.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">女儿殿下</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=440613"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s0/93/1794217775.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">稻香</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=3195905"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s17/73/2187216026.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">红尘客栈</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=550531864"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s86/95/3059703046.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">I Do</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=3197116"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s17/73/2187216026.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">明明就</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=440616"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s0/93/1794217775.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">兰亭序</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=6871880"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s67/21/834133816.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">
                  一路向北-《头文字D》电影插曲
                </div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=325386987"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s3s60/29/1448169300.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">
                  圣诞星 (feat. 杨瑞代)
                </div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=440623"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s0/93/1794217775.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">
                  说好的幸福呢
                </div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=324243"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/7/83/4087363627.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">
                  蒲公英的约定
                </div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=118987"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s11/89/774616642.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">枫</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=40079875"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/86/93/2359259663.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">
                  等你下课(with 杨瑞代)
                </div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=6187940"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/47/63/494275386.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">
                  手写的从前-优酸乳为爱告白广告曲
                </div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=138246"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/45/96/3463817628.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">退后</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=728676"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s90/63/3806481715.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">
                  我落泪情绪零碎
                </div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=118980"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s11/89/774616642.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">夜曲</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=588552"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s36/70/1529234453.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">爱在西元前</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=118990"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s11/89/774616642.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">发如雪</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=728677"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s90/63/3806481715.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">烟花易冷</div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div></a
            ><a
              class="search-result-list-item bottom-border"
              href="song.php?id=392927"
              ><div
                class="search-result-list-item-img d-flex justify-content-center align-items-center"
              >
                <span
                  ><img
                    src="https://img1.kuwo.cn/star/albumcover/500/s4s43/78/4150270702.jpg"
                /></span>
              </div>
              <div class="search-result-list-item-left">
                <div class="search-result-list-item-left-song">
                  不能说的秘密-《不能说的秘密》电影主题曲
                </div>
                <div class="search-result-list-item-left-singer">周杰伦</div>
              </div>
              <div class="search-result-list-item-dl">
                <i class="fa fa-download"></i></div
            ></a>
          </div>
        </div>
      </div>
    </div>
    <div class="footer"></div>
    <!-- 弹窗 HTML 结构 -->
    <!-- data-backdrop="static" 防止点击背景关闭，强制用户选择 -->
    <div
      class="modal fade custom-modal-dark"
      id="addressModal"
      tabindex="-1"
      role="dialog"
      aria-labelledby="addressModalLabel"
      aria-hidden="true"
      data-backdrop="static"
    >
      <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="addressModalLabel">📢 温馨提示</h5>
            <!-- 如果不想要右上角的X，可以删掉下面这行 button -->
            <button
              type="button"
              class="close"
              data-dismiss="modal"
              aria-label="Close"
            >
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <p>
              因网站近期频繁被恶意投诉，域名可能随时更换。<br />请务必收藏最新的地址发布页！
            </p>

            <!-- 新增：域名显示区域 -->
            <div class="domain-box">
              <span class="domain-label">当前永久发布页地址</span>
              <!-- 请在这里修改你的域名 -->
              <div class="domain-text">pjmp3.de</div>
            </div>
          </div>
          <div class="modal-footer">
            <!-- 按钮 1：前往地址页 -->
            <a
              href="https://pjmp3.de"
              target="_blank"
              class="btn btn-paojiao-green"
            >
              🚀 前往地址发布页
            </a>

            <!-- 按钮 2：我知道了 -->
            <button
              type="button"
              class="btn btn-paojiao-secondary"
              id="btn-iknow"
            >
              我知道了
            </button>
          </div>
        </div>
      </div>
    </div>
    <script>
      $(document).ready(function () {
        // 定义 localStorage 的键名
        const STORAGE_KEY = "address_modal_closed_time";
        // 定义过期时间：2小时 (毫秒)
        const EXPIRE_TIME = 2 * 60 * 60 * 1000;

        // 检查是否需要弹窗
        function checkAndShowModal() {
          const lastClosedTime = localStorage.getItem(STORAGE_KEY);
          const now = new Date().getTime();

          // 如果没有记录，或者 (当前时间 - 上次关闭时间) 大于 2小时
          if (!lastClosedTime || now - lastClosedTime > EXPIRE_TIME) {
            $("#addressModal").modal("show");
          }
        }

        // 执行检查
        checkAndShowModal();

        // 绑定"我知道了"按钮点击事件
        $("#btn-iknow").click(function () {
          // 记录当前时间
          localStorage.setItem(STORAGE_KEY, new Date().getTime());
          // 关闭弹窗
          $("#addressModal").modal("hide");
        });
      });
    </script>
  </body>
</html>
```

## 获取音乐

https://pjmp3.com/song.php?id=550531860

返回html

```html
<script>
  console.log("URL Cache:550531860");
</script>
<!--<!DOCTYPE html>-->
<html lang="zh-CN">
  <head>
    <title>
      那天下雨了 - 周杰伦 - 泡椒音乐 -
      免费无损音乐MP3、FLAC、WAV在线播放下载网站
    </title>
    <meta charset="UTF-8" />
    <meta name="referrer" content="no-referrer" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, shrink-to-fit=no"
    />
    <meta
      content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0"
      name="viewport"
    />
    <meta
      name="keywords"
      content="那天下雨了,周杰伦,泡椒音乐,泡椒音乐官网,泡椒音乐网,泡椒音乐下载,无损音乐,歌曲下载,高品质音乐,歌曲搜索,音乐免费下载,MP3下载,flac无损下载,wav下载,收费音乐免费下载,付费音乐免费下载,在线mp3网盘音乐下载网站,在线网盘下载"
    />
    <meta
      name="description"
      content="那天下雨了,歌手周杰伦,所属专辑《太阳之子》,发布时间2026-03-25,音乐时长03:43,泡椒音乐 - 在线音乐搜索，可以在线免费下载全网MP3付费歌曲、流行音乐、经典老歌等。曲库完整，更新迅速，试听流畅，支持高品质|无损音质"
    />
    <meta name="msvalidate.01" content="9F867A9A00FAEA0A16065EC41618FF40" />
    <link rel="shortcut icon" type="image/png" href="/logo.png" />
    <link rel="dns-prefetch-control" href="on" />
    <meta http-equiv="ClearSiteData" content='"cache","cookies","storage"' />
    <link rel="dns-resolver" href="https://cloudflare-dns.com/dns-query" />
    <link rel="dns-resolver" href="https://dns.google/dns-query" />
    <link rel="dns-resolver" href="https://dns.alidns.com/dns-query" />
    <link rel="dns-resolver" href="https://doh.pub/dns-query" />
    <link
      href="https://npm.elemecdn.com/aplayer@1.10.1/dist/APlayer.min.css"
      type="text/css"
      rel="stylesheet"
    />
    <link
      href="https://npm.elemecdn.com/bootstrap@4.6.1/dist/css/bootstrap.min.css"
      type="text/css"
      rel="stylesheet"
    />
    <link
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
      type="text/css"
      rel="stylesheet"
    />
    <script
      src="https://npm.elemecdn.com/aplayer@1.10.1/dist/APlayer.min.js"
      type="application/javascript"
    ></script>
    <script
      src="https://npm.elemecdn.com/jquery@3.6.0/dist/jquery.min.js"
      type="application/javascript"
    ></script>
    <script
      src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/4.6.1/js/bootstrap.bundle.min.js"
      type="application/javascript"
    ></script>
    <script type="text/javascript">
      // 跳转提示
      if (is_weixn_qq()) {
        window.location.href =
          "https://c.pc.qq.com/middle.html?pfurl=" + window.location.href;
      }

      function is_weixn_qq() {
        var ua = navigator.userAgent;
        var isWeixin = !!/MicroMessenger/i.test(ua);
        var isQQ = !!/QQ\//i.test(ua);
        if (isWeixin || isQQ) {
          return true;
        }
        return false;
      }
    </script>
    <script>
      var _mtj = _mtj || [];
      (function () {
        var mtj = document.createElement("script");
        if (window.location.host == "music.pjmp3.com") {
          mtj.src = "https://node95.aizhantj.com:21233/tjjs/?k=g8u3uq1q37z";
        } else {
          mtj.src = "https://node91.aizhantj.com:21233/tjjs/?k=jfee1h5kk8a";
        }
        var s = document.getElementsByTagName("script")[0];
        s.parentNode.insertBefore(mtj, s);
      })();
    </script>
    <style>
      :root {
        --bs-primary: #1db954;
        --bs-secondary: #2d4263;
        --bs-dark: #121212;
        --bs-light: #f5f5f5;
        --bs-dark-gray: #282828;
        --bs-light-gray: #b3b3b3;
        --bs-green: #1db954;
      }
      body {
        background-color: var(--bs-dark-gray);
        color: var(--bs-light);
        font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        margin: 0;
        padding: 0;
      }
      .g-container {
        max-width: 1200px;
        margin: 0 auto;
      }
      .bottom-border {
        border-bottom: 0.5px solid #ffffff1a;
      }
      .header {
        background-color: var(--bs-dark);
      }
      .header-container {
        padding: 16px 30px;
        display: flex;
        flex-direction: row;
        justify-content: space-between;
      }
      .logo {
        font-size: 24px;
        font-weight: bold;
        letter-spacing: 2px;
        display: flex;
        align-items: center;
        text-decoration: none;
      }
      .logo:hover {
        text-decoration: none;
      }
      .fa-music {
        color: var(--bs-primary);
      }
      .logo-title {
        color: var(--bs-light);
      }
      .logo-title2 {
        color: var(--bs-primary);
      }
      .header-search-btn {
        padding-right: 20px;
      }
      .body {
        padding: 10px;
      }
      .search {
        width: 100%;
        padding: 20px;
        background-color: var(--bs-dark);
        border-radius: 10px;
        margin-bottom: 10px;
      }
      .search-input-icon {
        position: absolute;
        left: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--bs-light-gray);
      }
      .search-input {
        flex: 1;
        position: relative;
      }
      .search-input input {
        flex: 1;
        padding: 14px 20px 14px 45px;
        border-radius: 8px;
        border: none;
        background-color: var(--bs-dark-gray);
        color: var(--bs-light);
        font-size: 1rem;
        transition: all 0.3s ease;
      }
      .search-input input:focus {
        outline: none;
        box-shadow: 0 0 5px var(--bs-primary);
        background-color: var(--bs-dark-gray);
        color: var(--bs-light);
      }
      .search-btn {
        padding: 8px 25px;
        background: var(--bs-primary);
        color: var(--bs-light);
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        margin-left: 10px;
        white-space: nowrap;
      }

      .cc {
        width: 100%;
        padding: 30px;
        margin: 10px auto;
        background-color: var(--bs-dark);
        border-radius: 10px;
      }
      .cc-header {
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 20px;
      }
      .cc-header-left {
        display: flex;
        flex-direction: row;
        align-items: center;
      }
      .cc-header-icon {
        color: var(--bs-primary);
        font-size: 14px;
      }
      .cc-header-title {
        color: var(--bs-light);
        font-size: 21px;
        font-weight: bold;
        letter-spacing: 3px;
      }
      .cc-header-right {
        color: var(--bs-light);
        font-weight: bold;
        padding: 0 5px;
      }
      .cc-body {
        margin: 0;
        padding: 0;
      }

      /* --- 自定义样式以匹配图片风格 --- */

      /* 弹窗主体背景：深灰 */
      .custom-modal-dark .modal-content {
        background-color: #1f1f1f; /* 接近图片中的深色背景 */
        color: #e0e0e0;
        border: 1px solid #333;
        border-radius: 10px; /* 稍微圆润一点的边角 */
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.7);
      }

      /* 标题栏去线，文字居中 */
      .custom-modal-dark .modal-header {
        border-bottom: none;
        padding-bottom: 0;
        justify-content: center;
      }

      .custom-modal-dark .modal-title {
        font-weight: bold;
        color: #fff;
      }

      /* 内容区域 */
      .custom-modal-dark .modal-body {
        text-align: center;
        padding: 20px 30px;
        font-size: 16px;
        color: #b0b0b0; /* 稍微淡一点的灰色文字 */
      }

      /* 4. 重点：域名显示框样式 */
      .domain-box {
        background-color: #121212; /* 比弹窗背景更深，形成凹陷感 */
        border: 1px dashed #444; /* 虚线边框 */
        border-radius: 8px;
        padding: 15px;
        margin-top: 15px;
        margin-bottom: 5px;
      }

      .domain-label {
        font-size: 13px;
        color: #888;
        margin-bottom: 5px;
        display: block;
      }

      .domain-text {
        color: var(--bs-primary); /* 泡椒绿高亮 */
        font-size: 22px;
        font-weight: bold;
        font-family:
          Consolas, Monaco, "Andale Mono", monospace; /* 等宽字体更像代码/地址 */
        user-select: all; /* 用户点击即可全选，方便复制 */
        word-break: break-all;
      }

      /* 底部按钮栏去线 */
      .custom-modal-dark .modal-footer {
        border-top: none;
        justify-content: center;
        padding-bottom: 25px;
      }

      /* 绿色主按钮 (前往发布页) - 仿照图片中的搜索按钮颜色 */
      .btn-paojiao-green {
        background-color: var(--bs-primary); /* 鲜艳的绿色 */
        border-color: #28c76f;
        color: #fff;
        border-radius: 5px;
        padding: 8px 25px;
        font-weight: 500;
        transition: all 0.3s;
      }

      .btn-paojiao-green:hover {
        background-color: #20a059;
        border-color: #20a059;
        color: #fff;
      }

      /* 次要按钮 (我知道了) */
      .btn-paojiao-secondary {
        background-color: transparent;
        border: 1px solid #555;
        color: #aaa;
        border-radius: 5px;
        padding: 8px 25px;
        margin-left: 15px;
      }

      .btn-paojiao-secondary:hover {
        background-color: #333;
        color: #fff;
        border-color: #777;
      }

      /* 右上角关闭叉号改为白色 */
      .custom-modal-dark .close {
        color: #fff;
        text-shadow: none;
        opacity: 0.7;
        position: absolute;
        right: 15px;
        top: 15px;
        padding: 0;
        margin: 0;
      }

      .custom-modal-dark .close:hover {
        opacity: 1;
      }

      /* --- 新增：搜索框下方的发布页提示条样式 --- */
      .fabu-alert {
        width: 100%;
        padding: 15px 20px;
        background-color: var(--bs-dark); /* 跟搜索框背景一致 */
        border-radius: 10px;
        margin-bottom: 10px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap; /* 手机端自动换行 */
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      }

      .fabu-content {
        display: flex;
        align-items: center;
        flex: 1;
        padding-right: 10px;
      }

      .fabu-text {
        color: var(--bs-light);
        font-size: 15px;
        margin-left: 10px;
      }

      .fabu-link {
        color: var(--bs-primary);
        font-weight: bold;
        margin-left: 5px;
        font-family: Consolas, Monaco, monospace;
        font-size: 16px;
      }

      .fabu-btn {
        background-color: var(--bs-primary);
        color: #fff;
        border: none;
        border-radius: 20px;
        padding: 6px 18px;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s;
        white-space: nowrap;
      }

      .fabu-btn:hover {
        background-color: #1ed760;
        color: #fff;
        text-decoration: none;
        transform: translateY(-1px);
      }

      /* 手机端微调 */
      @media (max-width: 576px) {
        .fabu-alert {
          padding: 12px 15px;
        }
        .fabu-text {
          font-size: 13px;
        }
        .fabu-link {
          font-size: 14px;
        }
      }
    </style>
  </head>
  <body>
    <div class="header sticky-top bottom-border">
      <div class="g-container header-container">
        <a class="logo" href="/">
          <svg
            t="1754035445986"
            class="icon"
            viewBox="0 0 1024 1024"
            version="1.1"
            xmlns="http://www.w3.org/2000/svg"
            p-id="6877"
            width="36"
            height="36"
          >
            <path
              d="M0 0h1024v1024H0z"
              fill="#1DB954"
              fill-opacity=".01"
              p-id="6878"
            ></path>
            <path
              d="M627.2 332.8c38.4 0 71.68 10.24 99.84 25.6 40.96 23.04 56.32 61.44 56.32 107.52 2.56 48.64-12.8 94.72-35.84 135.68-48.64 89.6-120.32 158.72-204.8 212.48-58.88 38.4-122.88 64-189.44 81.92-43.52 12.8-87.04 17.92-130.56 23.04-23.04 2.56-40.96-10.24-46.08-28.16-2.56-17.92 5.12-30.72 17.92-40.96 46.08-40.96 92.16-79.36 135.68-122.88 38.4-35.84 76.8-69.12 102.4-115.2 17.92-28.16 28.16-61.44 33.28-94.72 7.68-43.52 15.36-87.04 43.52-125.44 20.48-30.72 48.64-51.2 87.04-61.44 10.24 2.56 23.04 2.56 30.72 2.56zM645.12 296.96c7.68-10.24 15.36-10.24 25.6-10.24 33.28 2.56 46.08-5.12 53.76-38.4 10.24-46.08 28.16-84.48 64-117.76 7.68-7.68 17.92-15.36 28.16-20.48 2.56-5.12 7.68-5.12 15.36-7.68 12.8-2.56 20.48 7.68 15.36 17.92-5.12 10.24-12.8 20.48-20.48 25.6-35.84 33.28-51.2 76.8-56.32 122.88-2.56 20.48 2.56 40.96 12.8 58.88 5.12 10.24 10.24 20.48 7.68 35.84-38.4-46.08-89.6-58.88-145.92-66.56z"
              fill="#1DB954"
              p-id="6879"
            ></path>
          </svg>
          <span class="logo-title">泡椒</span>
          <span class="logo-title2">音乐</span>
        </a>
        <div class="header-search-btn d-flex flex-row align-items-center">
          <i class="fa fa-search"></i>
        </div>
      </div>
    </div>
    <div class="body g-container">
      <style>
        .song {
          padding: 10px;
          display: flex;
          flex-direction: row;
          align-items: center;
          gap: 40px;
        }
        @media (max-width: 768px) {
          .song {
            flex-direction: column;
            align-items: center;
            align-content: center;
          }
          .song-right {
            flex: 1;
            height: 280px;
            display: flex;
            flex-direction: column;
            justify-content: space-around;
            align-items: center;
          }
          .song-title {
            font-size: 24px !important;
          }
          .song-subtitle {
            font-size: 16px !important;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
          }
          .song-info {
            margin: 20px 0;
          }
          .song > .aplayer-narrow {
            width: 280px !important;
            height: 280px !important;
          }
        }
        .song-cover {
          height: 280px;
          flex: 0 0 280px;
          display: flex;
          flex-shrink: 0;
          justify-content: center;
          align-items: center;
          background-image: url("https://img2.kuwo.cn/star/albumcover/500/s4s86/95/3059703046.jpg");
          background-size: cover;
          border-radius: 10px;
          box-shadow: 0 8px 24px rgba(255, 255, 255, 0.3);
        }
        .song-cover:hover {
          transform: scale(1.05);
          box-shadow: 0 10px 20px rgba(255, 255, 255, 0.2);
        }
        #aplayer > .aplayer-body {
          width: 280px;
          height: 280px;
        }
        #aplayer > .aplayer-body > .aplayer-pic {
          width: 280px !important;
          height: 280px !important;
        }
        .song-right {
          flex: 1;
          height: 280px;
          display: flex;
          flex-direction: column;
          justify-content: space-around;
        }
        .song-title {
          color: var(--bs-light);
          font-weight: bold;
          font-size: 48px;
          overflow: hidden;
          white-space: normal;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-box-orient: vertical;
          -webkit-line-clamp: 2;
        }
        .song-subtitle {
          color: var(--bs-light-gray);
          font-size: 24px;
          margin: 0;
          overflow: hidden;
          white-space: normal;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-box-orient: vertical;
          -webkit-line-clamp: 1;
        }
        .song-text {
          color: var(--bs-light-gray);
          margin-right: 20px;
        }
        .song-action {
          display: flex;
          flex-direction: row;
          align-items: center;
          justify-content: left;
        }
        .song-btn {
          display: flex;
          justify-content: center;
          align-items: center;
          width: 150px;
          height: 50px;
          cursor: pointer;
          border-radius: 20px;
          gap: 10px;
        }
        .song-btn-dl {
          background-color: var(--bs-primary);
          color: #000;
          box-shadow: 0 8px 16px rgba(29, 185, 84, 0.3);
          margin-right: 30px;
        }
        .song-btn-dl:hover {
          transform: scale(1.05);
          background-color: #1ed760;
          box-shadow: 0 10px 20px rgba(29, 185, 84, 0.4);
        }
        .song-btn-play {
          background-color: var(--bs-dark-gray);
          color: var(--bs-light-gray);
          border: 2px solid var(--bs-light-gray);
        }
        .song-btn-play:hover {
          border-color: var(--bs-light);
          color: var(--bs-light);
          transform: scale(1.05);
        }
        .song-album-desc {
          color: var(--bs-light-gray);
          font-size: 16px;
          line-height: 1.5;
          padding: 10px;
        }
        .song-album-desc {
          max-height: 120px;
          overflow: hidden;
          position: relative;
          transition: max-height 0.5s ease;
        }
        #album_toggle_btn {
          width: 100%;
          display: block;
          text-align: center;
          margin-top: 15px;
          color: var(--bs-primary);
          cursor: pointer;
          font-weight: 600;
        }
        .song-album-desc.expanded {
          max-height: 1200px;
        }

        .song-album-desc.expanded::after {
          opacity: 0;
        }
        .lyric {
          color: var(--bs-light-gray);
          font-size: 16px;
          line-height: 1.5;
          max-height: 280px;
          overflow: hidden;
          position: relative;
          transition: max-height 0.5s ease;
        }
        .lyric-item {
          text-align: center;
          padding: 5px 0;
        }
        #lyric_toggle_btn {
          width: 100%;
          display: block;
          text-align: center;
          margin-top: 15px;
          color: var(--bs-primary);
          cursor: pointer;
          font-weight: 600;
        }
        .lyric.expanded {
          max-height: 2000px;
        }

        .lyric.expanded::after {
          opacity: 0;
        }
        #captcha-box {
          position: absolute;
          bottom: 20px;
          left: 0;
          right: 0;
          margin: 0 auto;
          width: fit-content;
        }
        .modal-content {
          background-color: var(--bs-dark) !important;
        }
        .dl-card {
          padding: 20px;
          background-color: var(--bs-dark-gray);
          border-radius: 10px;
          color: var(--bs-light);
        }
        .dl-header {
          display: flex;
          padding: 10px;
          margin-bottom: 20px;
          font-size: 22px;
          font-weight: bold;
          color: var(--bs-light);
          align-items: center;
        }
        .dl-header-subtitle {
          color: var(--bs-light-gray);
          font-size: 16px;
          margin: 10px;
          display: none;
        }
        .dl-list {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }
        .dl-list-item {
          padding: 10px;
          border-radius: 5px;
          cursor: pointer;
          text-align: center;
          transition: background-color 0.3s ease;
          background-color: var(--bs-primary);
          box-shadow: 0 8px 16px rgba(29, 185, 84, 0.3);
          color: var(--bs-light);
          font-size: 18px;
          font-weight: bold;
        }
        .dl-list-item:hover {
          transform: scale(1.05);
          background-color: #1ed760;
          box-shadow: 0 10px 20px rgba(29, 185, 84, 0.4);
        }
        .dl-result {
          margin-top: 20px;
          padding: 10px;
          background-color: var(--bs-dark-gray);
          border-radius: 5px;
          color: var(--bs-light);
          font-size: 18px;
        }
        .dl-result a {
          text-decoration: none;
          font-weight: bold;
          cursor: pointer;
        }
      </style>

      <!-- 搜索框 -->

      <!-- 搜索框 -->
      <div class="search">
        <div class="d-flex flex-row align-items-center">
          <div class="search-input">
            <i class="fa fa-search search-input-icon"></i>
            <input
              id="keyword"
              type="text"
              name="keyword"
              value=""
              class="form-control mr-2"
              placeholder="请输入搜索内容"
              required
            />
          </div>
          <div id="search-btn" class="search-btn">搜索</div>
        </div>
        <script>
          document
            .getElementById("search-btn")
            .addEventListener("click", function () {
              var keyword = document.getElementById("keyword").value.trim();
              if (keyword) {
                window.location.href =
                  "/search.php?keyword=" + encodeURIComponent(keyword);
              } else {
                alert("请输入搜索内容");
              }
            });

          // 支持回车键搜索
          document
            .getElementById("keyword")
            .addEventListener("keypress", function (event) {
              if (event.key === "Enter") {
                event.preventDefault();
                document.getElementById("search-btn").click();
              }
            });
        </script>
      </div>
      <div class="cc">
        <div class="cc-body">
          <div class="song">
            <div class="song-cover" id="aplayer"></div>
            <div class="song-right">
              <div class="song-title">那天下雨了</div>
              <div class="song-subtitle">
                <span>周杰伦</span>
                <span>太阳之子</span>
              </div>
              <div class="song-info">
                <span class="song-text"
                  ><i class="fa fa-clock mr-1"></i> 03:43</span
                >
                <span class="song-text"
                  ><i class="fa fa-calendar mr-1"></i> 2026-03-25</span
                >
              </div>
              <div class="song-action">
                <span class="song-btn song-btn-dl" onclick="showDownload()"
                  ><i class="fa fa-download mr-2"></i>下载</span
                >
                <span class="song-btn song-btn-play" onclick="ap.toggle();"
                  ><i class="fa fa-play mr-2"></i>播放</span
                >
              </div>
            </div>
          </div>
        </div>
      </div>

      <!--专辑信息-->
      <div class="cc">
        <div class="cc-header">
          <div class="cc-header-left">
            <span class="cc-header-icon"
              ><i class="fa fa-compact-disc fa-2x mr-2"></i></span
            ><span class="cc-header-title">所属专辑《太阳之子》</span>
          </div>
          <div class="cc-header-right"></div>
        </div>
        <div class="cc-body">
          <div class="song-album-desc" id="song-album-desc">
            万众期盼！雨过天晴 太阳之子以音乐能量的光芒照耀全球！ 周杰伦JAY CHOU
            暌违近四年最新创作专辑 太阳之子 Children of the Sun
            太阳，所到之处即带来光，随性挥洒无与伦比的音乐创意
            太阳之子带领我们探索正能量的跃动，领略音乐最抽象的艺术激荡
            周杰伦暌违近四年以12首全新创作歌曲及特别收录给歌迷的礼物「圣诞星」
            集结成全新专辑《太阳之子》 周杰伦用音乐唤醒每个人心中的趋光性！
            太阳之子行经之路，如云隙透光突破云层
            光束的变化万千，一如他的音乐创作能量的无与伦比
            带给大地温暖的抚慰、炙热的梦想、魔幻的节奏、跃动的旋律
            12首创作宛如画框中一幅幅变化万千的音乐
            以崭新的声线，描绘出心中灿烂多变的阳光
            「太阳之子」是「歌神」张学友对周杰伦的昵称与认证。这个称号源于2023年5月周杰伦在香港举行《嘉年华》演唱会期间，虽遇到狂风暴雨，但只要开唱雨就会停，张学友特地送上印有「太阳之子」的芒果及手写卡片，幽默认证周杰伦的幸运如同「太阳之子」。周杰伦自己也感动表示自己「心里出太阳了」，并打趣说「太阳之子」这个称号他拿走了。
            离2022年发行上一张专辑〈最伟大的作品〉至2026年，在这近四年的时间里，周杰伦放慢生活步调、慢慢写进音乐里，慢慢酝酿歌词、慢慢筹备ＭＶ，宛如创作脑中奇思异想旅程的12幅画作，有庞大到以古典名画融合现代电影感的巨幅印象派油画；到轻巧诙谐挥洒的抽象画、以地名命名的以景写情的随笔素描、工笔勾勒声韵的中国风、狂放的歌德风摇滚、浪漫的异国情调、温柔静谧抒情的插画风格；在熟悉的周式风格音乐底蕴上，增添了令人惊艳的新颖调色。
            独一无二、无法复制的太阳之子音乐光魔法
            唱出12道照亮黑暗的聚光，无论是光与暗的拼斗，或是生命中的闪光时刻
            每一首歌的光线直视各种情感暗面，宛如经历「光的正能量」沉浸式体验
            以歌词勾勒故事情节＆情感对白、以旋律挥洒灵感光线、以编曲构图裱框
            描绘出周杰伦脑中源源不绝的宏大硬核叙事、随性异国写意、轻愁微甜抒情
            【豪华特制实体专辑装帧】
            这次收录12首新歌＋1首彩蛋歌，是一张重磅实体专辑，外盒是欧风古典雕花窗，专辑封面的标准字和外框烫金，营造出「太阳」的闪耀光芒；打开雕花窗外盒后，里面以信封形式的封套包覆了「无框画」封面以及小画板，呈现这次「名画」与「裱褙创作」的专辑概念；里面放置一本线圈装订内页歌词本，以及周杰伦在MV中的精彩写真，CD片还制作成迷你黑胶唱片的模样，让〈太阳之子〉实体专辑极具巧思。
            这不仅是一张实体专辑，更希望具有收藏感，如同这次专辑的穿梭古今、名画，希望这13首充满电影感与戏剧感的音乐作品不只是音乐，而是一种对艺术的感受与体会，能真挚传递到歌迷手中。
            【曲目介绍】  ////名画悬疑史诗光//// 1、太阳之子 Children of the
            Sun  4’57” 词 Lyricist：方文山 Vincent Fang 曲 Composer：周杰伦 Jay
            Chou 制作人 Producer：周杰伦 Jay Chou 编曲 Arrangement：黄雨勋 Yanis
            Huang @Yanis Music 『谁弹奏着灰黑协奏曲 蒙娜丽莎微笑着哭泣
            救赎来临前始终不语』
            同名主打〈太阳之子〉这首歌，就是整张专辑中最巨幅的作品。
            这首歌最与众不同、最特别的地方是周杰伦的脑海里先有了「古典名画＋超酷枪战」的冲突创意，交由知名ＭＶ导演廖人帅撰写ＭＶ脚本，因为周杰伦一直非常热爱艺术，一开始先出了一个功课给导演，就是一、要有很多名画，二、要有很酷的枪战在里面，所以在只有初版DEMO的情况下，导演先发展完成剧本，由周杰伦饰演一名警探，穿梭在各名画场景之中追捕吸血鬼。ＭＶ拍摄制作与音乐创作制作同步进行，拍摄完毕后，方文山再根据ＭＶ初剪画面写词，为这支ＭＶ以文字描述出影像里深埋的核心概念，创下前所未有的创作方式！ＭＶ里致敬三十幅名画，根据剧情走向，画作选择神秘感重、强调光影的人物肖像、或是画风强烈大众熟悉的名画，运用这些名画，变成一个一个ＭＶ分镜，巧妙串连起来又不违和的融入整个剧情中。导演以「真人」演出名画里的人物，加上细腻的化妆、美术、道具、灯光、特效等环节逼近百分百还原画作场景；在选角部分特别在各地寻找出跟名画人物长相非常相近的人，近30几位真人演员饰演，让名画「活」起来，仿佛周杰伦警探掉入了名画的时空里，追捕吸血鬼！
            这次动画团队是全世界前三强、在新西兰的好莱坞御用动画团队Wētā
            Workshop公司，曾做过「阿凡达」、「魔戒」、「猩球崛起」、「怪奇物语」第五季；Wētā
            Workshop公司让真人演出的名画与名画之间转换更流畅；ＭＶ制作费逼近一亿元台币，从2023年12月开会，2025年1月巴黎教堂开拍后，进入后制、2025年4月拍台湾搭景部分，继续后制、2026年3月中才完成，耗时2年3个月的时间，超强团队与破天荒的制作费与漫长的制作时程，也堪称创下华语乐坛ＭＶ新天花板！
            在音乐上周杰伦这次以符合剧情的情绪，用比较狂野略带嘶吼感的唱腔，以及方文山针对ＭＶ剧情故事将这些名画作、画家名，画中意境，重新以文字赋予精神面的层次，让这首歌充满了正能量，传达出ＭＶ最后的这句文案：
            Within every heart lies a dark side, one must choose to live with or
            vanquish it.  ////黑色电影意象 //// 2、西西里 Sicily  3’49” 词
            Lyricist：方文山 Vincent Fang 曲 Composer：周杰伦 Jay Chou 制作人
            Producer：周杰伦 Jay Chou 编曲 Arrangement：黄雨勋 Yanis Huang
            @Yanis Music 『海风刮过了 无人的街道  西西里的夜色 谁在那祷告』
            以阴郁氛围的大编制古典弦乐与拟佛朗明哥风格吉他营造出宿命感的孤寂画风，描绘出意大利的黑手党故乡「西西里」。
            歌曲充满了黑色电影的既视感与意象，方文山的歌词宛如「黑帮文学」，充满考究与隐喻，值得细细品味。「柠檬树的香气」点出了黑手党的罪恶即是从柠檬开始的；歌词以景色来推进歌曲情节：『柠檬树的香气掩盖不了弥漫在人群中的火药味道』；用视觉与嗅觉的冲突来营造紧张气氛『私下的正义在夜里维持秩序／未干的血还有那烟硝味／关于荣耀我转身拒绝再写』隐喻黑手党文化与暴力美学：『子弹穿越有时比誓言
            更直接』：酒窖的红酒隐喻呛声叹息后的血色街道、庄园落叶是事过境迁的苍凉。歌词中提到的「佩尔古萨湖」在西西里是个结合了自然生态和神话故事的重要景点，在这湖边道离别，更增添了这首歌的幽微神秘感的余韵。
            音乐勾勒出整首歌西西里夜色的明暗反差；港边的灯火在打暗号、雨后冲刷了烟硝味，是分镜；副歌歌词则是情节对白；故事以歌词第一句谁在夜色里祷告开始，最后结束在「没有名字的季节」是角色荣耀过后，消逝在无名的时光之中；无论是打暗号的灯火、或是枪的火光，黑色荣耀的余光，最终都会随着岁月消逝。
             ////错过的纯爱雨渍画 //// 3、那天下雨了 The Day It Rained  3’43” 词
            Lyricist：周杰伦 Jay Chou 曲 Composer：周杰伦 Jay Chou 制作人
            Producer：周杰伦 Jay Chou 编曲 Arrangement：林迈可 Michael Lin (VIP
            MUSIC) 『雪白的天空等待彩虹出现  你我的遇见是谁许的愿』
            周杰伦作词作曲的周氏抒情歌「那天下雨了」，是一幅周式纯爱风水彩插画，被雨滴晕染开的水彩颜色，就像年少的暧昧朦胧，错过了就成了未来的浪漫遗憾。
            「你经过花就开，离开雨就来」是这段相遇与错过最美的描绘，原本期待这段相遇是雨后放晴的太阳，带来的是梦幻彩虹的恋曲，但终究是回不去那个下雨天，成了未竟的爱。 
            周杰伦以娓娓道来的方式演唱，以第一人称声音演出这幅以六张插画组成的故事：「现在式偶遇的男女对望」、「男人内心的浪漫幻想」、「学生时期女孩剪下男孩毕业纪念册的照片」、「学生时期的书店女孩借书给男孩」、「学生时期女孩为男孩撑伞」、「现在式的女孩老家三人身影」，那些被男孩遗忘的温柔，现在已经太迟。即使是首写遗憾的歌，旋律却美得令人晕眩，纯爱在岁月的滤镜下，在生命的轨迹里即使错过了爱，也未尝不是一种浪漫？
             ////多情中国风工笔画 //// 4、湘女多情 The Girl from Hunan  3’58” 词
            Lyricist：方文山 Vincent Fang 曲 Composer：周杰伦 Jay Chou 制作人
            Producer：周杰伦 Jay Chou 编曲 Arrangement：黄雨勋 Yanis Huang
            @Yanis Music 『湘女多情 暮色已落地 檐下满园鸟啼 妳却倚窗锁眉不语』
            场景是中国古代的湖南（湘），古人总说湘女多情，倚着窗台等待爱情，暮色照映出心中的思念无处安放，满园鸟啼热闹非凡，更凸显出湘女内心的孤单。
            「湘女多情」该词典故源自娥皇、女英寻夫的《楚辞·九歌》传说，象征坚贞的爱情与对理想的追求，方文山以此为主题，细腻地揉出中国古典与现代的委婉难言的愁绪，只能以景写意。歌词运用了大量的对比，例如：热闹的戏曲／沉默的人、凋落的花／铺满的爱，表达「执着」与「守候」两大主题。整首歌像一幅古代工笔画般，将湘女的惆怅思念之情、戏曲班和鸟的热闹喧哗、落花缤纷的浪漫，加上暮色渲染，成为一幅情长卷轴。
             ////逞强的洒脱喷漆画 //// 5、谁稀罕 Who Cares 4’22”  词
            Lyricist：周杰伦 Jay Chou 曲 Composer：周杰伦 Jay Chou 制作人
            Producer：周杰伦 Jay Chou 编曲 Arrangement：派伟俊 Patrick
            Brasca、吕尚霖 LuuX 『我知道我并没有他好  你说给我的爱会晚一点才到』
            这是一个又逞强又悲屈的现代失恋喷漆画。歌词以「讲反话」表达在爱情关系里的逞强独白，画中陷在三人关系中的配角泄愤式的在每个曾经一起走过的爱情场景里用喷漆写上「谁稀罕」三个字。苦等着那个晚一点到的爱，到最后却依然不是被偏爱的那个，即使这个拥抱总会适时出现，却依然敌不过另外一个人给予的那种童话般、轰轰烈烈的爱，呐喊过后也只能感叹「爱上你是我自找」。
            英式抒情摇滚风格的伤情歌，毫不留情直击人心的歌词和副歌旋律，是周式情歌里最令人折服的情歌魄力，爱就爱了、痛就喊痛，保留给自己的爱情自尊就是那句「谁稀罕」，很潇洒却也令人心疼！
            歌曲一开头就破题以副歌开场，情绪直接拉高拉满，不留余地攻陷内心最脆弱的地方，这也是周氏情歌最难以抵抗的魔力！这首歌像犀利的红外线，照出爱情最卑微的暗处。需要情绪出口的人准备好一起唱「谁稀罕」！！
             ////浪漫极光印象派 //// 6、七月的极光 Aurora in July  2’47” 词
            Lyricist：方文山 Vincent Fang 曲 Composer：周杰伦 Jay Chou 制作人
            Producer：周杰伦 Jay Chou 编曲 Arrangement：派伟俊 Patrick
            Brasca、MaxAidan 『夕阳落在加油站的玻璃上   我们把冒险的地图都带上』
            夕阳时刻是这趟追极光旅程的倒数开始，开车迎向爱情最极致的浪漫高光时刻。当太阳落下之时，极光的绚烂会更鲜明，更特别的是在七月竟然会出现粉色极光，以此为歌名，更增添了这首歌的超现实与梦幻程度，像一幅印象派画风油画，在七月里描绘出来、在生命中留下独特的浪漫感动。
            这首由派伟俊和MaxAidan编曲，是一首充满超现实梦核感氛围的情歌，将这首爱情冒险，变成了梦幻的流光闪烁、在怀里发呆的幸福旅途；以电子合成器烘托周杰伦的独特唱腔，让这首情歌宛如爱情公路电影般，碎拍的节奏与chill流动感无违和的交缠着像是这段旅途中爱情依存陪伴。方文山的歌词，是一场浪漫的爱情壮游：「爱上妳不意外 
            像我对妳的依赖」，沉溺在这场七月的极光之中，感受彼此的光与温度。
            即使当太阳下山了，夜幕低垂时，在七月的极光之中，拥抱爱情等于拥有整个宇宙。
             ////恋恋南欧风情油画 //// 7、爱琴海 Aegean Sea  3’34” 词
            Lyricist：刘畊宏 Will Liu 曲 Composer：周杰伦 Jay Chou 制作人
            Producer：周杰伦 Jay Chou 编曲 Arrangement：派伟俊 Patrick
            Brasca、蒋希谦 Johnpiz 『透明的瓶 闪烁着光
            却装不进你心里向往的地方』
            这不是一首关于重逢的歌，而是一首关于「看着你走远」的风景画。
            歌曲是描画浓郁希腊圣托里尼风情的蓝白色写实风景画，画中以爱琴海沿岸的蓝白色房、伊亚的教堂是故事的背景。如果《西西里》是黑色的宿命，那么《爱琴海》就是一种寄托在美景里「透明的哀伤」。所以周杰伦以一种略带慵懒、像是在海风中自言自语的口吻，唱出了刘畊宏笔下那种关于「错过」的视觉残留记忆。歌词里没有声嘶力竭的挽留，只有在脑中不断回带的风景：从海风推开的窗，到伊亚阶梯上的影子，到处都是思念的足迹，难以抹灭，触景伤情。
            「瓶里的沙」是一种灵魂隐喻，我们都试图用某种仪式，留住当初的爱情信仰与纪念，但当主角寄情的「贝壳」回头望，海洋（现实）早已将那些细碎的温柔一次又一次地冲散遗忘。
            Rap
            部分的节奏感，像是海浪拍打礁石的规律节奏，也像是主角在心底不断回荡的碎念：「傻傻的留住当初的那信仰」。这首歌最残酷的温柔在于，它承认了思念在很远的地方，而我们只能在过去的长廊里，闻着那阵早已消散的发香。
             ////永恒的爱型雕塑//// 8、Ｉ Do 3’36” 词 Lyricist：方文山 Vincent
            Fang 曲 Composer：周杰伦 Jay Chou 制作人 Producer：周杰伦 Jay Chou
            编曲 Arrangement：周杰伦 Jay Chou、派伟俊 Patrick Brasca、吕尚霖
            LuuX 『Baby 想像你在未来的画面  早遇见 我们一定提早相恋』
            如果《爱琴海》是看着风景远去，那么《I
            Do》就是「让风景变成永恒」，是对爱情最真挚的誓约。这是周杰伦最深情真挚的抒情曲风——以电吉他开场，随后加入温暖的摇滚堆叠、环绕拥抱，最后在充满幸福感的坚定鼓点中走向这场见证爱情的高潮情绪。方文山以「坚定的承诺」、「无名指」。从海边的初见到红毯上的誓言，这首歌完成了一场关于爱情的命定与承诺，婚礼是见证爱情的仪式感，无名指是戴上誓言的约定，从你和我变成了「我们」，这场相遇透过「ＩDo」，成为彼此最忠贞而浪漫的一句话。
            「无名指上的永远」与「领带上的温柔」，被周杰伦唱成了一部每个坠入爱情后，相爱的两个人愿意全身心交付给彼此的一部永恒爱情史。
            当旋律停在「幸福停靠的地方」，我们才发现，所有的等待与错过，都是为了能在对的时间，遇见一份能真心对待一生的爱情，一起成为最美的模样。当彼此和对方说出「Ｉ
            Do」就是爱情的高光时刻！ 「在我的生命中
            感谢有妳的出现／妳的无名指上有我承诺的永远」，听完这首歌，心里会涌出一股感动绽放，告诉自己：「还是要相信爱情」！如果身边出现了那位值得守候一生的人，请勇敢说出：「I
            Do.」  ////硬核摇滚叙事彩绘玻璃 //// 9、圣徒 Saint  2 ’55” 词
            Lyricist：黄俊郎 A-Lang 曲 Composer：周杰伦 Jay Chou 制作人
            Producer：周杰伦 Jay Chou 编曲 Arrangement：派伟俊 Patrick Brasca
            『不屈是彩绘玻璃的光辉　迎向阳光色彩最为浓烈』
            这是一首将艺术与音乐视为信仰的作品，以圣徒之名，将音乐纹满整个世界，在追求艺术的路上，怀抱着使命感，脚步从未停止，以旋律跟上岁月同行，在时代不断更迭的路程，不当懦弱的落叶，一年四季无论春夏秋冬变化，骨子里的「刚强」永远不被影响。这是创作者给予自我内心最强大的信心喊话。
            黄俊郎以远方黎明、镜头慢慢拉近到麦田、穹顶、石墙、身处大自然领略「文思泉涌般的我　写下那完美 
             
            老天给予智慧」对于宇宙的灵感提供，期许自己写出大师之作，才能问心无愧。这是「创作圣徒」表现出高信仰的表征。
            即使遇到骤雨，也不会让自己创作能量（桔梗）消亡，夜莺如灵感穿梭林，在这个创作之旅的同路人一写下属于灵感的「仲夏夜的诗篇」。
            歌声捎来力量　唱出希望　用本领凿光　
            笑语驱散忧伤　解开迷惘　我指引方向 困境的斗士不沮丧 
            胆怯的内心更坚强  带领迷途的星芒　大声的欢唱　曙光就在前方
            这段歌词是整张专辑最充满正能量的文字，在漫长无止尽的创作之路，歌声能为黑暗的阻碍凿光，引领大众一起欢唱；最后一段不断重复地大合唱着：跟着唱！和音唱着「哈雷路亚」，仿佛群众们跟随这股充满力量的歌声，隐喻圣徒们的高声欢呼鼓舞！
            编曲以HIP
            HOP与史诗感的营造出「圣徒」感，加上以枪支上膛的音效声，隐喻「战斗」感，营造出圣徒的内心处在迎战自我的一种坚毅与专注，这是一首艺术家对自我价值最惊心动魄、义无反顾的信心喊话、自我宣言！听这首歌，仿佛脑门被音符、歌词、节奏重重一击！敲醒了内心沉睡的创作魂，跟着这道光，寻找属于自我的那个充满才华的自我，尽情发挥它，成为圣徒的一员吧！
             ////鬼灵精怪放克蜡笔画 //// 10、女儿殿下 My Daughter, Your
            Highness  3’44”  词 Lyricist：周杰伦 Jay Chou 曲 Composer：周杰伦
            Jay Chou 制作人 Producer：周杰伦 Jay Chou 编曲 Arrangement：黄雨勋
            Yanis Huang @Yanis Music O.S.：Jay’s daughter 『疯疯癫癫 Hey
            风度翩翩 Hey 陪我家公主玩变化万千 Hey』
            这首充满鬼灵精怪、俏皮疯癫的放克风格将女儿称之为「女儿殿下」，将这位女儿殿下的喜怒哀乐，情绪变化无常、无厘头，转化成趣味又生活化的歌词、以及穿插超萌的小女孩口白，巧妙加入歌曲的轻快节奏之中，后段又转化成又是撒娇、无辜、又突然崩溃的小女孩口气，让人觉得又好气又可爱，与周杰伦慵懒率性形成强烈对比，把生活中突发的各种亲子互动以充满音乐性的放克曲风活灵活现的描绘出来！
            疯疯癫癫还是风度翩翩？真的是每一个亲子之间最饶富趣味的日常，突然间理智线断掉，下一妙又甜蜜想念，黄雨勋大师的编曲更让这首歌完全跳脱「亲子感」，精彩的间奏爵士钢琴的灵动感，充满了鬼灵精怪、完全将生活感用音乐提升到艺术层面！
            「我疯了吗！」非常适用于对付这位难搞又可爱的「公主殿下」时，在内心的呐喊，但是又要耐着性子哄着、疼着，这就是最温馨欢乐的音乐转化！
               ////十九世纪混现代的淘金版画 //// 11、淘金小镇 Gold Rush Town 
            4’10” 词 Lyricist：方文山 Vincent Fang 曲 Composer：周杰伦 Jay Chou
            制作人 Producer：周杰伦 Jay Chou 编曲 Arrangement：周杰伦 Jay
            Chou、派伟俊 Patrick Brasca、吕尚霖 LuuX
            方文山以宛如电影脚本的歌词，搭配周杰伦的曲，谱写出一部关于淘金小镇的故事。整首歌宛如电影般的蒙太奇，第一段歌词以充满西部开拓感的描写出时空环境，以「口哨声」、「酒馆敲杯声」、「马蹄铁」与「穿马刺的鞋跟」这些声音来营造出一种不安、躁动且充满野性的氛围；写
            幽暗的「矿坑」、摇晃的「煤油灯」对比「金河」与「闪着光的眼」，运用了文字明暗对比强化了淘金者在绝望与希望之间挣扎的心境。「有人筛选泥土却筛选出孤独」点出了人性亮点，到底我们汲汲营营的淘出的是金或者可能一无所获，但是「踩在坚硬的路不服也不喊苦」，也代表着顽强，也是一种生命里的「金」。
            周杰伦以一种豪爽潇洒的态度，诠释这个高维度视角的人生体悟，既充满了娱乐性更充满了他独有的音乐哲学。就像创作一部十九世纪电影或画作一样，投射在自我内心时，「轻轻的戴上，静静的欣赏」和「狂欢」、「呐喊」的强烈对比，其实就是追寻梦想的过程，这种只属于自己一个人的胜利，梦想就是我们想淘的金，不管如何，只要继续唱着歌，趁着月色，有酒喝就喝得爽快！
             ////舒适悠闲的民谣素描//// 12、乡间的路  Country Road  3’22” 词
            Lyricist：方文山 Vincent Fang 曲 Composer：周杰伦 Jay Chou 制作人
            Producer：周杰伦 Jay Chou 编曲 Arrangement：派伟俊 Patrick
            Brasca、蒋希谦 Johnpiz
            这首歌结合了乡村的清新、民谣的悠扬，以及饶舌的舒适悠闲，带着这种悠闲，一起上路感受这一路带有复古滤镜的公路短片，捕捉青春的纯粹爱恋与遗憾。
            方文山为这首歌描述的故事，一样先以儿时的树、小木屋、谷仓、草堆、货卡...这些视觉景象，将我们从喧嚣的都市带往静谧的乡间。沿途风景宛如一幅幅水彩画、淡妆、一卡车的玫瑰花，还能闻到牧草香、花香；午后微风在耳鬓吹拂着，描绘出乡间的路途中快要满溢出来的幸福感觉！
            周杰伦以旋律加中段的饶舌、再到后段大合唱，带动了心中最初的悸动、翻涌了回忆、浪漫、幸福、香气、混杂在一起的那些过往，与现在交错重叠的心情。青春这条乡间的路上，是一层又一层的颜料涂抹、涂掉再画上的过程，从未消逝过，心里的话，就藏在这些树梢、飘荡的花瓣里，希望能够传递的心情，即使世界不断变动，这些纯粹的初心，变成了一幅画、一首歌，永远吟唱着。
          </div>
          <div id="album_toggle_btn">展开全部</div>
        </div>
      </div>
      <!--歌词-->
      <div class="cc">
        <div class="cc-header">
          <div class="cc-header-left">
            <span class="cc-header-icon"
              ><i class="fa fa-music fa-2x mr-2"></i
            ></span>
            <span class="cc-header-title">歌词</span>
          </div>
          <div class="cc-header-right"></div>
        </div>
        <div class="cc-body">
          <style></style>
          <div class="lyric" id="lyric">
            <div class="lyric-item">那天下雨了 - 周杰伦</div>
            <div class="lyric-item">词：周杰伦</div>
            <div class="lyric-item">曲：周杰伦</div>
            <div class="lyric-item">车子缓缓的开 你慢慢走来</div>
            <div class="lyric-item">我竟然看着你发呆</div>
            <div class="lyric-item">你尴尬Say个Hi 没位坐下来</div>
            <div class="lyric-item">我想叫旁边的离开</div>
            <div class="lyric-item">我车票都还在 心却在窗外</div>
            <div class="lyric-item">因为你已下了站台</div>
            <div class="lyric-item">远远的看着你点点头车已开</div>
            <div class="lyric-item">你一句话我爬窗离开</div>
            <div class="lyric-item">你证件掉了出来 我才明白</div>
            <div class="lyric-item">是那隔壁班的女孩</div>
            <div class="lyric-item">这么多年彼此竟然没认出来</div>
            <div class="lyric-item">是你变美还是我变帅</div>
            <div class="lyric-item">你经过花就开 离开雨就来</div>
            <div class="lyric-item">这里适合谈个恋爱</div>
            <div class="lyric-item">如果我要一个梦幻的开场白</div>
            <div class="lyric-item">没有比你更美的对白</div>
            <div class="lyric-item">雪白的天空等待彩虹出现</div>
            <div class="lyric-item">（彩虹出现）</div>
            <div class="lyric-item">你我的遇见是谁许的愿</div>
            <div class="lyric-item">（谁许的愿）</div>
            <div class="lyric-item">黑黑的夜空繁星变得耀眼</div>
            <div class="lyric-item">（变得耀眼）</div>
            <div class="lyric-item">因为你出现在我身边</div>
            <div class="lyric-item">你老家有点远 但我有点闲</div>
            <div class="lyric-item">也许能陪你走一圈</div>
            <div class="lyric-item">把你的父母都见 吃几口麻酱面</div>
            <div class="lyric-item">也许还能打个几圈 （我胡了）</div>
            <div class="lyric-item">乡间的麦芽田 害羞的脸</div>
            <div class="lyric-item">你提到多年前的暗恋</div>
            <div class="lyric-item">你剪下校园毕业册的那一页</div>
            <div class="lyric-item">是因为我在照片里面</div>
            <div class="lyric-item">雪白的天空等待彩虹出现</div>
            <div class="lyric-item">（彩虹出现）</div>
            <div class="lyric-item">你我的遇见是谁许的愿</div>
            <div class="lyric-item">（谁许的愿）</div>
            <div class="lyric-item">黑黑的夜空繁星变得耀眼</div>
            <div class="lyric-item">（变得耀眼）</div>
            <div class="lyric-item">因为你出现在我身边</div>
            <div class="lyric-item">原来多年前在那个书店</div>
            <div class="lyric-item">借我课本的是你</div>
            <div class="lyric-item">原来看我被雨淋的那天</div>
            <div class="lyric-item">帮我撑伞也是你</div>
            <div class="lyric-item">翘课的那一天 花落那一天</div>
            <div class="lyric-item">教室那间我已看见</div>
            <div class="lyric-item">消失的下雨天 我想再淋一遍</div>
            <div class="lyric-item">我应该对你唱着晴天</div>
            <div class="lyric-item">送你到家门外 我才明白</div>
            <div class="lyric-item">原来你早已有人疼爱</div>
            <div class="lyric-item">如果回到过去那一个下雨天</div>
            <div class="lyric-item">我会为了你把伞撑开</div>
            <div class="lyric-item">如果回到过去那一个下雨天</div>
            <div class="lyric-item">我绝不再 转身离开</div>
          </div>
          <div id="lyric_toggle_btn">展开全部</div>
        </div>
      </div>

      <div
        class="modal fade"
        id="dlModal"
        tabindex="-1"
        role="dialog"
        aria-labelledby="dlModalTitle"
        aria-hidden="true"
      >
        <div class="modal-dialog modal-dialog-centered" role="document">
          <div class="modal-content">
            <div id="captcha-box"></div>
            <div class="dl-card">
              <div class="dl-header">
                <i class="fa fa-download mr-2"></i>请选择音质
              </div>
              <span class="dl-header-subtitle">当前还可下载9999+首歌曲</span>
              <div class="dl-list">
                <div class="dl-list-item" onclick="dl('550531860','flac');">
                  无损音质
                </div>
                <div class="dl-list-item" onclick="dl('550531860','320');">
                  高品质
                </div>
                <div class="dl-list-item" onclick="dl('550531860','128');">
                  低品质
                </div>
              </div>
              <div class="dl-result" id="dl-result"></div>
            </div>
          </div>
        </div>
      </div>

      <link href="/tac/css/tac.css" type="text/css" rel="stylesheet" />
      <script src="/tac/js/load.min.js"></script>
      <script src="/tac/js/tac.min.js"></script>
      <script>
        const ap = new APlayer({
          container: document.getElementById("aplayer"),
          mini: true,
          audio: [
            {
              name: "那天下雨了",
              artist: "周杰伦",
              url: "https://lv-sycdn.kuwo.cn/19119a9516632cc3141974c9589ee87b/69d08b74/resource/1307392909/trackmedia/M500000RExN94I2yHN.mp3",
              cover:
                "https://img2.kuwo.cn/star/albumcover/500/s4s86/95/3059703046.jpg",
            },
          ],
        });

        const lyric = document.getElementById("lyric");
        const lyric_toggle_btn = document.getElementById("lyric_toggle_btn");

        lyric_toggle_btn.addEventListener("click", function (e) {
          e.preventDefault();
          lyric.classList.toggle("expanded");

          if (lyric.classList.contains("expanded")) {
            lyric_toggle_btn.textContent = "收起";
          } else {
            lyric_toggle_btn.textContent = "展开全部";
          }
        });
        const album = document.getElementById("song-album-desc");
        const album_toggle_btn = document.getElementById("album_toggle_btn");

        album_toggle_btn.addEventListener("click", function (e) {
          e.preventDefault();
          album.classList.toggle("expanded");

          if (album.classList.contains("expanded")) {
            album_toggle_btn.textContent = "收起";
          } else {
            album_toggle_btn.textContent = "展开全部";
          }
        });

        function showDownload() {
          $("#dl-result").html("");
          $(".dl-list").show();
          $(".dl-header-subtitle").hide();
          $("#dlModal").modal("show");
        }

        function getMusicUrl(captchaId, id, br) {
          // 在执行登录时，将验证码token传过去进行二次校验
          $.get(
            "/captcha/check/getMusicUrl?captchaId=" +
              captchaId +
              "&id=" +
              id +
              "&br=" +
              br,
            (res) => {
              // console.log(res);
              if (res.code === 200) {
                // 验证成功，返回音乐下载链接
                $(".dl-list").hide();
                $(".dl-header-subtitle").show();
                let url = res.result
                  .replace(/(\w+)\.sycdn\.kuwo\.cn/g, "$1-sycdn.kuwo.cn")
                  .replace(/^http:\/\//, "https://");
                $("#dl-result").html(
                  '<a href="' +
                    url +
                    '" target="_blank" referrer="no-referrer">鼠标右键点击链接另存为</a>',
                );
              } else {
                // 验证失败，显示错误信息
                $("#dl-result").html(
                  '<div class="">获取失败,请重试或者去 <a href="http://mp3b.com" target="_blank">另一个音乐下载网站</div>',
                );
              }
            },
          );
        }

        function dl(id, br) {
          // config 对象为TAC验证码的一些配置和验证的回调
          const config = {
            // 生成接口 (必选项,必须配置, 要符合tianai-captcha默认验证码生成接口规范)
            requestCaptchaDataUrl: "/captcha/gen",
            // 验证接口 (必选项,必须配置, 要符合tianai-captcha默认验证码校验接口规范)
            validCaptchaUrl: "/captcha/check",
            // 验证码绑定的div块 (必选项,必须配置)
            bindEl: "#captcha-box",
            // 验证成功回调函数(必选项,必须配置)
            validSuccess: (res, c, tac) => {
              // 销毁验证码服务
              tac.destroyWindow();
              // console.log("验证成功，后端返回的数据为", res);
              // 调用登录方法
              this.getMusicUrl(res.data, id, br);
            },
            // 验证失败的回调函数(可忽略，如果不自定义 validFail 方法时，会使用默认的)
            validFail: (res, c, tac) => {
              console.log("验证码验证失败回调...");
              // 验证失败后重新拉取验证码
              tac.reloadCaptcha();
            },
            // 刷新按钮回调事件
            btnRefreshFun: (el, tac) => {
              console.log("刷新按钮触发事件...");
              tac.reloadCaptcha();
            },
            // 关闭按钮回调事件
            btnCloseFun: (el, tac) => {
              console.log("关闭按钮触发事件...");
              tac.destroyWindow();
            },
          };
          // 一些样式配置， 可不传
          let style = {
            // 按钮样式
            // btnUrl: "https://minio.tianai.cloud/public/captcha-btn/btn3.png",
            // 背景样式
            // bgUrl: "https://minio.tianai.cloud/public/captcha-btn/btn3-bg.jpg",
            // logo地址
            // logoUrl: "https://minio.tianai.cloud/public/static/captcha/images/logo.png",
            // 滑动边框样式
            // moveTrackMaskBgColor: "#121212",
            // moveTrackMaskBorderColor: "#121212"
          };

          // -------------- 拉起TAC验证码 -----------------

          // 参数1： tac文件的URL地址前缀， 目录里包含 tac的js和css等文件，
          //      比如参数为: http://xxxx/tac/, 该js会自动加载 http://xxxx/tac/js/tac.min.js 、http://xxxx/tac/css/tac.css等
          //      具体的js文件可以在 https://gitee.com/tianai/tianai-captcha-web-sdk/releases/tag/1.2 下载
          // 参数2： tac验证码相关配置
          // 参数3： tac窗口一些样式配置
          window
            .initTAC("/tac", config, style)
            .then((tac) => {
              tac.init(); // 调用init则显示验证码
            })
            .catch((e) => {
              console.log("初始化tac失败", e);
            });
        }
      </script>
    </div>
    <div class="footer"></div>
    <!-- 弹窗 HTML 结构 -->
    <!-- data-backdrop="static" 防止点击背景关闭，强制用户选择 -->
    <div
      class="modal fade custom-modal-dark"
      id="addressModal"
      tabindex="-1"
      role="dialog"
      aria-labelledby="addressModalLabel"
      aria-hidden="true"
      data-backdrop="static"
    >
      <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="addressModalLabel">📢 温馨提示</h5>
            <!-- 如果不想要右上角的X，可以删掉下面这行 button -->
            <button
              type="button"
              class="close"
              data-dismiss="modal"
              aria-label="Close"
            >
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <p>
              因网站近期频繁被恶意投诉，域名可能随时更换。<br />请务必收藏最新的地址发布页！
            </p>

            <!-- 新增：域名显示区域 -->
            <div class="domain-box">
              <span class="domain-label">当前永久发布页地址</span>
              <!-- 请在这里修改你的域名 -->
              <div class="domain-text">pjmp3.de</div>
            </div>
          </div>
          <div class="modal-footer">
            <!-- 按钮 1：前往地址页 -->
            <a
              href="https://pjmp3.de"
              target="_blank"
              class="btn btn-paojiao-green"
            >
              🚀 前往地址发布页
            </a>

            <!-- 按钮 2：我知道了 -->
            <button
              type="button"
              class="btn btn-paojiao-secondary"
              id="btn-iknow"
            >
              我知道了
            </button>
          </div>
        </div>
      </div>
    </div>
    <script>
      $(document).ready(function () {
        // 定义 localStorage 的键名
        const STORAGE_KEY = "address_modal_closed_time";
        // 定义过期时间：2小时 (毫秒)
        const EXPIRE_TIME = 2 * 60 * 60 * 1000;

        // 检查是否需要弹窗
        function checkAndShowModal() {
          const lastClosedTime = localStorage.getItem(STORAGE_KEY);
          const now = new Date().getTime();

          // 如果没有记录，或者 (当前时间 - 上次关闭时间) 大于 2小时
          if (!lastClosedTime || now - lastClosedTime > EXPIRE_TIME) {
            $("#addressModal").modal("show");
          }
        }

        // 执行检查
        checkAndShowModal();

        // 绑定"我知道了"按钮点击事件
        $("#btn-iknow").click(function () {
          // 记录当前时间
          localStorage.setItem(STORAGE_KEY, new Date().getTime());
          // 关闭弹窗
          $("#addressModal").modal("hide");
        });
      });
    </script>
  </body>
</html>
```
