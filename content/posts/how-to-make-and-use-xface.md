+++
title = "如何制作 X-Face 风格头像"
author = ["fuloido"]
date = 2025-02-17T01:23:06+08:00
lastmod = 2025-03-15T15:14:25+08:00
tags = ["Emacs", "nerd"]
draft = false
+++

一开始是在 _emacs-china_ 上水论坛时，经常能看到像素极低、纯黑白的头像、却又很带感的头像。后来[发现](https:emacs-china.org/t/topic/3118)原来叫 `X-face` ，大概是邮件／新闻组时代流行的头像。

> 翻到 [DarkSun转的一篇老文章](https://blog.csdn.net/lujun9972/article/details/46002803)，提到了 [X-Face](https://en.wikipedia.org/wiki/X-Face) 这个邮件／新闻组时代很流行的东西。就和现在的 Gravatar 差不多。甚至以前的 IRC 也能显示 X-face 头像。

`X-face` 是邮件 header 部分嵌入的一段代码，在读入邮件时转换为 _48x48_ 的 bitmap。可以通过 [Online X-Face Converter](https://www.dairiki.org/xface/xface.php) 直接转换。然而，如果你的图片是彩色的、分辨率过高，直接转换的效果很不好。

这里参考了 [emacs-china 上的一个教程](https://emacs-china.org/t/x-face/28144)，分享一下作为 `gimp` 苦手的制作过程。

1.  图像-&gt;模式-&gt;灰度：将彩色的图片去色便于后续通过 **阈值** 分割像素，当然最好用本来就是黑白的图片。
2.  颜色-&gt;阈值：这一步将黑白像素分离，只要有线条即可，后续通过滤镜加粗线条。这里建议可以分图层处理，比如说眼睛部分和头发部分，往往当眼睛部分已经全为黑色像素时头发的线条还未区分。
3.  图像-&gt;模式-&gt;索引：将图片变为 _black and white pattle(1bit)_
4.  滤镜-&gt;常规-&gt;腐蚀：将线条加粗，一般需要多次使用这个滤镜。
5.  图像-&gt;缩放：缩放为 48x48 ，插值方法一般不限。

据 [LdBeth](https://emacs-china.org/t/x-face/28144/2)，x-face 没有确切的解码标准，甚至因为作者技术问题和导致仿造实现时出了偏差，有些实现是相互不兼容的，现在一般用 compface 这个具体实现。这里直接使用 _compface_ 提供的 `xbm2xface` 脚本即可。或者直接使用 [Online X-Face Converter](https://www.dairiki.org/xface/xface.php) encode一下。


## 为 WanderLust 设置 X-Face 邮件头 {#为-wanderlust-设置-x-face-邮件头}

_WanderLust_ 自动读取 `~/.xface` ，如果需要显示 X-Face 则需要额外的包，参考了 `doom emacs` ，添加：

```elisp
  ;; Use x-face only when compface installed
  (when (modulep! +xface)
    (autoload 'x-face-decode-message-header "x-face-e21")
    (setq wl-highlight-x-face-function 'x-face-decode-message-header))
```

顺便一提， `Homebrew` 目前不提供 `compface` 这个包，这里参考 [Linux® From Scratch](https://www.linuxfromscratch.org/blfs/view/git/general/compface.html) 手动构建了这个程序。你可能需要：

```shell
sed -e '/compface.h/a #include <unistd.h>' \
    -i cmain.c                             \
    -i uncmain.c
```

才能构建成功。
