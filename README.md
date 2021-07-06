# BeihangLogin

上网不涉密，涉密不上网！

北航网络认证 CURL 客户端（雾）

2019-08-28 更新：由于新版网络认证上线，旧版脚本已无法使用，是时候更换`login-v2.sh`了 :-D

## 用户名和密码的存放
请将 `account.example` 文件复制为 `account` 文件，并存放于脚本同目录，然后在其中输入你的学号和密码。

## 检测并自动登录

两个 try-connect 脚本可以检测当前是否已登录，如果没有登录就自动登录。

* `try-connect.sh` 通过 ping 百度来检测登录状态
* `try-connect-v2.sh` 通过访问网关 API 来检测登录状态

## Usage:

### 登录：

 ```./login-v2.sh login ```

### 注销：

 ```./login-v2.sh logout ```

-------
### Python 版

隔壁BIT用的是一个版本srun

https://github.com/RogerYong/bit_srun

### Rust 版
来自Rynco

https://github.com/01010101lzy/buaa-portal-login
