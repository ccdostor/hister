> 提醒： 滥用可能导致账户被BAN！！！[Telegram讨论群](https://t.me/starts_sh_group)

* 本项目把V2ray，Shadowsocks，Gost，Brook四种代理工具同时部署到heroku空间，方便客户端各取所需！

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://dashboard.heroku.com/new?template=https://github.com/mixool/heroku)

### 部署服务端

点击上面紫色`Deploy to Heroku`，会跳转到heroku app创建页面，填上app的名字、修改密码、修改UUID、记住路径，当然用默认的也没问题。然后点击下面deploy创建APP，完成后会生成一个域名，到此服务端也就部署完成了。记下域名，后面客户端会用到。

### V2ray客户端使用

下载客户端，比如Windows v2rayN：https://github.com/2dust/v2rayN/releases

选择代理协议 VLESS，然后配置如下：

代理协议：VLESS

* 地址：v2ray.herokuapp.com  //填写heroku生成的域名
* 端口：443
* 默认UUID：8f91b6a0-e8ee-11ea-adc1-0242ac120002
* 加密：none
* 传输协议：ws
* 伪装类型：none
* 路径：/v2raypath
* 底层传输安全：tls

上面需要修改的是UUID和路径，更换UUID页面：https://www.uuidgenerator.net/

### Shadowsocks客户端使用

首先下载 v2ray-plugin 插件到电脑，下载解压后移动到常用文件夹，记住插件所在文件夹路径，待会会用到。

v2ray-plugin 插件下载页：https://github.com/shadowsocks/v2ray-plugin/releases

然后，下载ss客户端，比如[Windows客户端](https://github.com/shadowsocks/shadowsocks-windows/releases/)，这个不多讲。配置如下：

* 服务器地址: shadowsocks-libev.herokuapp.com  //此处填写服务端生成的域名
* 端口: 443
* 密码：password
* 加密：chacha20-ietf-poly1305
* 插件程序：D:\APP\v2ray-plugin_windows_amd64.exe  //此处要填插件在电脑上的绝对路径
* 插件选项: path=/sspath;host=shadowsocks-libev.herokuapp.com;tls //此处改成自己的域名和路径

### Gost客户端使用

首先下载需要的gost客户端：https://github.com/ginuerzh/gost/releases

比如Windows端，选择`gost-windows-amd64-2.11.1.zip` 下载解压，然后记住exe文件在电脑中的绝对路径。

新建一个bat文件，比如`gost.bat` 如下：

`C:\Users\Administrator\App\gost\gost-windows-amd64.exe -L :10998 -F=ss+wss://AEAD_CHACHA20_POLY1305:password@gost.herokuapp.com:443?path=/gostpath`

改成heroku生成的域名和密码，每次点击`gost.bat`运行即可。

### Brook客户端使用

Brook客户端下载：https://github.com/txthinking/brook/releases

比如Windows端，选择`Brook.exe` 下载，运行，选择 `wsserver` 填写：

`wss://brook.herokuapp.com:443/brookpath`

改成heroku生成的域名和你的密码，运行即可。

### Cloudflare Workers反代
```
addEventListener(
    "fetch",event => {
        let url=new URL(event.request.url);
        url.hostname="此处替换成你自己部署的heroku项目域名";
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```

### [LICENSE](https://raw.githubusercontent.com/mixool/heroku/master/LICENSE)
