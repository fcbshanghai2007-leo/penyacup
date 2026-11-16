# penyacup.asia 上线指南

网站由三部分组成，全部在海外，免费额度足够第一届使用：

| 部分 | 用途 | 服务 |
| --- | --- | --- |
| 网页托管 | 放网站文件，绑定 penyacup.asia | Vercel |
| 数据库 | 实时比分、进球公益、参赛名单、报名记录、管理员登录 | Supabase |
| 邮件转发 | 报名自动发到 fcbshanghai2007@gmail.com | Formspree |

文件说明：

- `index.html`：网站首页，中英韩三语。
- `admin.html`：管理后台，网址是 penyacup.asia/admin.html，需登录。
- `config.js`：填写 Supabase 和 Formspree 的地址（唯一需要你改的文件）。
- `schema.sql`：数据库结构，在 Supabase 里运行一次。

建议用 fcbshanghai2007@gmail.com 注册以下所有服务，方便球迷会统一管理。

---

## 第 1 步：建数据库（Supabase，约 10 分钟）

1. 打开 supabase.com，注册并点 **New project**。
   - Region 选 **Singapore** 或 **Tokyo**，亚洲各地访问都快。
   - 数据库密码自己保存好。
2. 项目建好后，左侧点 **SQL Editor** → **New query**，把 `schema.sql` 全部内容粘贴进去，点 **Run**。看到 Success 即完成。
3. 左侧点 **Authentication** → **Sign In / Providers**，关闭 **Allow new users to sign up**。这样只有你添加的人能登录后台。
4. 左侧点 **Authentication** → **Users** → **Add user** → **Create new user**，填管理员邮箱和密码，勾选自动确认。需要几位管理员就加几个。
5. 左侧点 **Project Settings** → **API**，复制两项，填进 `config.js`：
   - **Project URL** → `SUPABASE_URL`
   - **anon public** 密钥 → `SUPABASE_ANON_KEY`

> 只填 anon public 密钥。**service_role** 密钥有全部权限，绝不能放进网页。

## 第 2 步：报名自动发邮件（Formspree，约 5 分钟）

1. 打开 formspree.io，用 fcbshanghai2007@gmail.com 注册并验证邮箱。
2. 点 **New Form**，名称填 Asia Penya Cup 报名，收件邮箱选 fcbshanghai2007@gmail.com。
3. 复制表单地址（形如 `https://formspree.io/f/xxxxxxx`），填进 `config.js` 的 `FORM_ENDPOINT`。
4. 在表单设置里把 penyacup.asia 加入允许的域名。

不填这一步也能用：报名照样存进数据库，在后台能看到；只是邮箱收不到通知，报名者会被提示点“发送邮件”。

## 第 3 步：上线网页（Vercel，约 10 分钟）

1. 在 github.com 注册，新建一个仓库（如 `penyacup`），点 **uploading an existing file**，把压缩包里的全部文件拖进去，点 **Commit**。
2. 在 vercel.com 用 GitHub 账号登录，点 **Add New → Project**，选中这个仓库，直接点 **Deploy**。不需要改任何设置。
3. 部署完成后会得到一个 `xxx.vercel.app` 网址，先打开检查：
   - 首页能显示，三语能切换；
   - 打开 `/admin.html`，用第 1 步的管理员账号能登录。

以后要改网站，只需在 GitHub 上替换文件，Vercel 会在一分钟内自动更新。

> 不想用 GitHub 的话，也可以用 Netlify Drop（app.netlify.com/drop），直接把装着这些文件的文件夹拖进网页即可上线，域名绑定方式类似。

## 第 4 步：绑定 penyacup.asia

1. Vercel 项目里点 **Settings** → **Domains**，添加 `penyacup.asia` 和 `www.penyacup.asia`。
2. Vercel 会显示需要添加的 DNS 记录（通常是一条 A 记录和一条 CNAME 记录），**以 Vercel 页面上显示的值为准**。
3. 登录你买域名的地方（域名注册商），进入 penyacup.asia 的 DNS 设置：
   - 先删除或修改旧网站的 A / CNAME 记录；
   - 按 Vercel 给的值添加新记录。
4. 一般几分钟到几小时生效。Vercel 会自动配置 HTTPS 证书。

旧网站的内容会在 DNS 切换后被新网站替代。旧的托管服务可在确认新网站正常后再停用。

## 第 5 步：上线后检查清单

- [ ] 用手机打开 penyacup.asia，检查中、英、韩三种语言。
- [ ] 登录后台，点“填入网站默认名单”→“保存名单”，再为三支队伍上传 logo。
- [ ] 后台添加一场测试比赛，改比分，确认首页比分和进球公益实时变化；测试完删除。
- [ ] 用另一个邮箱提交一次测试报名，确认 fcbshanghai2007@gmail.com 收到邮件、后台能看到记录；测试完在 Supabase → Table Editor → registrations 删除。

## 比赛日怎么用

- 现场工作人员用手机打开 penyacup.asia/admin.html 登录，每进一球改一次比分点“保存”，状态选“进行中”；比赛结束选“完场”。
- 首页的比分、积分榜、进球公益金额会自动更新，各地 Penya 打开网站就能实时看到。
- 配捐金额在后台“进球公益规则”里填写；留空则网站显示“待定”。

## 安全说明

- 访客只能读取比分与名单、提交报名，看不到任何报名记录。
- 只有你在 Supabase 添加的管理员账号能修改数据和查看报名。
- 免费版 Supabase 项目如果连续一段时间无人访问会自动暂停，进入项目后台点恢复即可；比赛前一周请登录检查一次。
