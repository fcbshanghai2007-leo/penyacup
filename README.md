# penyacup.asia 维护指南

网站是纯静态页面，由 GitHub Pages 从本仓库 `main` 分支根目录直接发布，没有构建步骤。由三部分组成：

| 部分 | 用途 | 服务 |
| --- | --- | --- |
| 网页托管 | 放网站文件，绑定 penyacup.asia | GitHub Pages |
| 数据库 | 实时比分、进球公益、参赛名单、报名记录、管理员登录 | Supabase |
| 邮件转发（可选，目前未配置） | 报名自动发到 fcbshanghai2007@gmail.com | Formspree |

文件说明：

- `index.html`：网站首页，中文、English、한국어、Español、Français 五语；包含报名和比分逻辑。
- `admin.html`：管理后台，网址是 penyacup.asia/admin.html，需登录。
- `config.js`：Supabase 地址与公开密钥、Formspree 地址（`FORM_ENDPOINT`，目前留空）。
- `CNAME`：绑定 penyacup.asia，不要删除。
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

不填这一步也能用（目前线上就是这样）：报名照样存进数据库，在后台能看到；邮箱收不到通知。

提交后页面按实际结果提示（五种语言）：

| 数据库 | 自动邮件 | 页面提示 |
| --- | --- | --- |
| 成功 | 成功 | 已登记，并已发送至官方邮箱 |
| 失败 | 成功 | 已发送至官方邮箱 |
| 成功 | 失败或未配置 | 已登记，请点“发送邮件”或复制内容手动发送 |
| 失败 | 失败或未配置 | 登记未成功，请手动发送，或稍后再点“提交报名”重试 |

需要手动发送时，页面显示可复制的报名内容；浏览器不允许自动复制时会选中文字，提示手动复制。同一份内容已成功的部分重试时不会重复提交。

## 第 3 步：上线网页（GitHub Pages，已完成）

- 发布方式：GitHub Pages 经典模式（Deploy from a branch），合并到 `main` 后由 GitHub 自动运行“pages build and deployment”，约 1 分钟后线上更新。可在仓库 **Actions** 页查看是否成功。

- 仓库：https://github.com/fcbshanghai2007-leo/penyacup（公开仓库，只含网页文件和公开密钥）
- 设置：仓库 **Settings → Pages**，Source 为 **Deploy from a branch**，分支 `main`，文件夹 `/ (root)`。
- 仓库里的 `CNAME` 文件内容是 `penyacup.asia`，用来绑定域名，**不要删除**。

## 第 4 步：绑定 penyacup.asia（已完成）

域名在阿里云购买，DNS 服务器保持阿里云默认的 `dns13.hichina.com` / `dns14.hichina.com`。
在阿里云 **云解析 DNS → penyacup.asia → 解析设置** 中的记录：

| 主机记录 | 类型 | 记录值 |
| --- | --- | --- |
| @ | A | 185.199.108.153 |
| @ | A | 185.199.109.153 |
| @ | A | 185.199.110.153 |
| @ | A | 185.199.111.153 |
| www | CNAME | fcbshanghai2007-leo.github.io |

- HTTPS 证书由 GitHub 自动签发和续期，**Enforce HTTPS** 已开启；http 和 www 都会自动跳到 https://penyacup.asia。
- 如果证书长时间显示未签发：在 Settings → Pages 里把 Custom domain 清空保存，再重新填 `penyacup.asia` 保存，通常几分钟内就会签发。

## 以后怎么修改网站

`main` 就是线上版本，推送到 `main` 等于直接发布。建议每次修改都走分支和 PR：

```bash
cd ~/penyacup
git switch main && git pull
git switch -c fix/简短说明
# 修改文件后：
git add -A
git commit -m "说明改了什么"
git push -u origin HEAD
gh pr create
```

在 PR 里写清楚改了什么、怎样验证的；确认后合并到 `main`，等 Pages 发布完成，再打开 https://penyacup.asia/ 复核。

本地预览：在仓库目录运行 `python3 -m http.server 8000`，打开 http://localhost:8000 。本地页面会连接线上 Supabase，测试报名请勿用真实资料，测试完到后台删除。

注意：

- 尽量不要在 GitHub 网页上和电脑上同时改文件；如果在网页上改过，先在电脑上 `git pull` 再改。
- 修改了 `schema.sql` 的话，还需要到 Supabase → SQL Editor 里执行对应的改动，网页更新不会自动改数据库。

## 第 5 步：上线后检查清单

- [ ] 用手机打开 penyacup.asia，检查五种语言（重点西语、法语的顶栏和报名提示）。
- [ ] 登录后台，点“填入网站默认名单”→“保存名单”，再为三支队伍上传 logo。
- [ ] 后台添加一场测试比赛，改比分，确认首页比分和进球公益实时变化；测试完删除。
- [ ] 用另一个邮箱提交一次测试报名，确认后台能看到记录、页面提示与实际结果一致（已配置 Formspree 时再确认 fcbshanghai2007@gmail.com 收到邮件）；测试完在 Supabase → Table Editor → registrations 删除。

## 比赛日怎么用

- 现场工作人员用手机打开 penyacup.asia/admin.html 登录，每进一球改一次比分点“保存”，状态选“进行中”；比赛结束选“完场”。
- 首页的比分、积分榜、进球公益金额会自动更新，各地 Penya 打开网站就能实时看到。
- 配捐金额在后台“进球公益规则”里填写；留空则网站显示“待定”。

## 安全说明

- 访客只能读取比分与名单、提交报名，看不到任何报名记录。
- 只有你在 Supabase 添加的管理员账号能修改数据和查看报名。
- 免费版 Supabase 项目如果连续一段时间无人访问会自动暂停，进入项目后台点恢复即可；比赛前一周请登录检查一次。
