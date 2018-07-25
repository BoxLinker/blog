---
title: HTML 中的 DOCTYPE
date: 2018-03-19 12:50:13
tags:
- HTML
- DOCTYPE
- 前端
---

DOCTYPE 最初是 XML 的概念，用来描述 XML 文档中允许出现的元素，以及各个元素的组成、嵌套规则等等。

在 HTML 中，DOCTYPE 可以出发浏览器的标准模式，如果没有 DOCTYPE 浏览器会进入一种被称为 Quirks 的怪异模式。在怪异模式下，浏览器的盒模型、样式解析、布局等都与标准模式存在差异，而且不同的浏览器的怪异模式的表现又不一样。

所以 HTML 文档中，DOCTYPE 是必不可少的。

# HTML 4 中的 DOCTYPE

在 [http://www.w3.org/TR/1999/REC-html401-19991224/struct/global.html#h-7.2](http://www.w3.org/TR/1999/REC-html401-19991224/struct/global.html#h-7.2) 中指定了 3 种 DOCTYPE：

* 严格模式：<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">。
    该模式不包括所有[废弃元素]以及框架模式种的元素
* 过度模式：<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">。
    包括严格模式 + 废弃元素
* 框架模式：<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">。
    包括过度模式 + frames

浏览器不一定会严格按照 DOCTYPE 指定的规则来渲染，而是会尽量兼容，渲染出开发人员预期的效果。

# HTML 5 种的 DOCTYPE

HTML 5 种 DOCTYPE 声明简化了，只需要 <!DOCTYPE html> 就可以了，大小写不敏感。
