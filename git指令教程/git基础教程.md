\# 前置（只需要做一次）

先配置 git 用户名邮箱（和 github 邮箱一致）

```bash

git config --global user.name "你的github用户名"

git config --global user.email "你的github邮箱"

```



> 两种场景：

> 场景A：本地已经有文件夹代码，推到你刚建的空 github repo（最常用）

> 场景B：直接把 github 仓库下载到本地（clone）



\## ✅ 场景A：本地已有项目，上传到新建的 Github 仓库

1\. 终端进入你的项目文件夹

```bash

cd /你的项目路径

```

2\. 初始化本地git仓库（生成隐藏 `.git`）

```bash

git init

```

3\. 把所有文件加入暂存区

```bash

git add .

\# 只加单个文件：git add test.py

```

4\. 提交到本地版本库，写备注

```bash

git commit -m "初次提交 init"

```

5\. 重命名主分支为 `main`（github 默认是 main）

```bash

git branch -M main

```

6\. 关联远程仓库（复制你仓库的 HTTPS / SSH 链接替换地址）

```bash

git remote add origin \[https://github.com/](https://github.com/)用户名/仓库名.git

```

> 查看远程地址：`git remote -v`

> 地址写错了更换：`git remote set-url origin 新地址`

7\. \*\*第一次推送\*\*（`-u` 记住关联，之后不用再加）

```bash

git push -u origin main

```



\## ✅ 场景B：直接克隆你新建的仓库到本地（仓库是空/有readme都可以）

```bash

git clone \[https://github.com/](https://github.com/)用户名/仓库名.git

cd 仓库名

```

克隆完自动关联 origin，之后改完代码直接：

```bash

git add .

git commit -m "更新说明"

git push

```



\# 📌 后续日常循环（记住这4条就够用）

```bash

git status          # 查看哪些文件改了（强烈建议经常看）

git add .           # 把改动放进暂存

git commit -m "备注"# 保存本地版本

git push            # 上传到github

```



\# 📌 拉取远程更新（比如网页上改了readme，或者多设备写代码）

```bash

git pull origin main

```



\# ⚠️ 常见坑提醒

1\. 建仓库的时候\*\*不要同时勾选 Add a README\*\*，否则第一次push会冲突；如果已经勾选了，第一次push用：

```bash

git push -u origin main --allow-unrelated-histories

```

2\. HTTPS 方式现在要用 \*\*Personal access token(PAT)\*\* 代替密码；推荐配置 SSH key，免密推送

3\. 新建 `.gitignore` 文件，写上不需要上传的文件（`node\_modules/`、`\_\_pycache\_\_/`、`.env`、日志、编译产物）



\# 简易分支常用（后面会用到）

```bash

git branch                  # 看本地分支

git switch -c dev           # 创建并切到 dev 分支

git switch main             # 切回主分支

git merge dev               # 在main分支合并dev

```





你想要的话，我可以给你：

\- SSH免密配置步骤

\- .gitignore 模板（Python / JS / C++任选）

\- 冲突处理、版本回退命令



你现在是【本地已有代码上传】还是【clone仓库】？

































\# Git SSH 完整推送教程（Windows PowerShell，适配你现在这个仓库）

> 好处：\*\*以后 push / pull 不用网页登录、不用token，避开你刚才 socks5 + ServicePointManager 的报错\*\*

> 前提：你能正常访问 github（需要代理就保持代理，SSH协议不会触发刚才那个.NET代理bug）



\## 1. 生成 SSH 密钥（只做一次）

打开 PowerShell，直接运行：

```powershell

ssh-keygen -t ed25519 -C "你github注册用的邮箱"

```

\- 回车，\*\*不要改保存路径\*\*（默认 `C:\\Users\\你的用户名\\.ssh\\id\_ed25519`）

\- 提示 `Enter passphrase`：

&#x20; - 想要免密：直接连续两次回车（推荐本地自用）

&#x20; - 想要密钥密码：自己设置一个密码，之后每次用ssh都要输



> ⚠️ 如果你的系统很老不支持 ed25519，换成这个：

> ```powershell

> ssh-keygen -t rsa -b 4096 -C "你github邮箱"

> ```



\## 2. 拿到公钥，复制

```powershell

cat \~/.ssh/id\_ed25519.pub

```

输出一整串以 `ssh-ed25519` 开头、末尾是你邮箱的文本，\*\*全选复制\*\*（不要多加空格换行）



\## 3. 把公钥添加到 GitHub 网页

1\. 打开 github：右上角头像 → Settings → \*\*SSH and GPG keys\*\*

2\. 点 \*\*New SSH key\*\*

3\. Title：随便写（比如 `Windows-laptop`）

4\. Key type：Authentication key

5\. 把刚才复制的公钥粘贴到大框里 → Add SSH key

6\. 确认一下github密码/二次验证



\## 4. 测试连通性（非常重要）

PowerShell执行：

```powershell

ssh -T git@github.com

```

第一次会问：

```

Are you sure you want to continue connecting (yes/no/\[fingerprint])?

```

输入 `yes` 回车



✅ 成功提示类似：

```

Hi 你的github用户名! You've successfully authenticated, but GitHub does not provide shell access.

```

这句话是正常的！代表ssh连通成功。



> 如果这里连不上，是代理问题：需要给ssh单独配置代理，我后面给你配置。



\## 5. 把你现在这个仓库，从 HTTPS 改成 SSH 地址（你当前这个 matlab\_upload 仓库）

先看现在远程地址：

```powershell

git remote -v

```

现在应该是 https 开头的。替换成ssh链接：

```powershell

git remote set-url origin git@github.com:你的github用户名/matlab\_upload.git

```

> 格式固定：`git@github.com:用户名/仓库名.git`，在仓库主页绿色Code按钮里切换到SSH就能看到



再核对一下，确认已经换成ssh：

```powershell

git remote -v

```

输出应该是：

```

origin  git@github.com:xxx/matlab\_upload.git (fetch)

origin  git@github.com:xxx/matlab\_upload.git (push)

```



\## 6. 推送（和之前命令一样，但是走ssh了！）

```powershell

git push -u origin main

```

✅ 成功之后，\*\*以后日常更新只需要\*\*

```powershell

git add .

git commit -m "备注"

git push

```

不再弹出网页认证，不再碰到刚才那个 socks5 的报错！



\---

\# 【可选：如果你必须开socks代理才能连上github】

SSH 默认不走系统代理，需要单独配置ssh代理：

新建/编辑文件 `C:\\Users\\你的用户名\\.ssh\\config`（没有后缀，叫config）

写入下面内容（socks5地址按你的代理软件改，一般是 `127.0.0.1:7890`）

```

Host github.com

&#x20; HostName github.com

&#x20; User git

&#x20; ProxyCommand nc -x 127.0.0.1:7890 %h %p

```

保存，再重新 `ssh -T git@github.com` 测试。



\---

\# 常见坑

1\. 提示 `Permission denied (publickey)`：

&#x20;  - 公钥没复制全、或者贴错到GPG key里面了（必须选SSH key）

2\. 生成密钥后关闭了PowerShell，直接重新测试连接即可，密钥是存在`.ssh`文件夹永久保存

3\. 之前的https缓存、token全部不受影响，只是这个仓库切换传输方式



你先执行第一步生成密钥，有哪一步报错直接贴给我。

