# BeihangLogin

上网不涉密，涉密不上网！

北航网络认证 CURL 客户端（雾）

If you want to login automatically when the openwrt/lede router boots, add the command to /overlay/upper/etc/rc.local:

```
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.
<blahblah>/login_mod.sh login
exit 0
```

## Usage:

### 登录：

 ```./login.sh login ```

### 注销：

 ```./login.sh logout ```
