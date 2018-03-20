---
title: JavaScript 中的 Promise 简易实现
date: 2018-03-19 13:31:05
tags:
- JavaScript
- 前端
- Promise
- 异步
---

使用 es6 中的 promise 很久了，但是一直也没时间研究一下到底是怎么实现的，今天就抽了点空看了一下 [es6-promise](https://github.com/stefanpenner/es6-promise) 的源码，并从中抽离出了一个简易版本，这个简易版本只是为了说明 promise 的实现原理而已，不能拿来用的。话不多说，直接先上代码：

``` javascript
const PENDING = void 0;
const FULFILLED = 1;
const REJECTED = 2;

const log = console.log;

const objectOrFunction = (x) => {
  let type = typeof x;
  return x !== null && (typeof x === 'object' || typeof x === 'function')
}

const handleMaybeThenable = (promise, value) => {
  const { _state } = value;
  if (typeof value.then === 'function') {
    asap(promise => {
      value.then.call(value, value => {
        resolve(promise, value);
      }, reason => {
        reject(promise, reason);
      });
    }, promise)

  }
};

const resolve = (promise, value) => {
  if (promise == value) {
    //reject
  } else if(objectOrFunction(value)) {
    handleMaybeThenable(promise, value)
  } else {
    fulfill(promise, value);
  }
};
const reject = (promise, reason) => {
  if (promise._state !== PENDING) return;
  promise._result = reason;
  promise._state = REJECTED;
  publish(promise);
};
const fulfill = (promise, value) => {
  if (promise._state !== PENDING) return;
  promise._result = value;
  promise._state = FULFILLED;
  
  if (promise._subscribers.length !== 0) {
    asap(publish, promise);
  }
};
const asap = (callback, arg) => {
  setTimeout(() => {
    callback(arg);
  }, 1);
};

const invokeCallback = (settled, promise, callback, detail) => {
  const value = callback(detail);
  if (promise._state !== PENDING) {
    // noop
  } else if (settled === FULFILLED) {
    resolve(promise, value);
  } else if (settled === REJECTED) {
    reject(promise, value);
  }
};

const publish = (promise) => {
  const subscribers = promise._subscribers;

  const settled = promise._state;
  if (subscribers.length === 0) return;

  let child, callback, detail = promise._result;

  for (let i = 0; i < subscribers.length; i += 3) {
    child = subscribers[i];
    callback = subscribers[i + settled];

    if (child) {
      invokeCallback(settled, child, callback, detail);
    } else {
      callback(detail);
    }
  }
  
  promise._subscribers.length = 0;
};

const subscribe = (parent, child, onFulfillment, onRejection) => {
  const { _subscribers } = parent;
  const { length } = _subscribers;
  _subscribers[length] = child;
  _subscribers[length + FULFILLED] = onFulfillment;
  _subscribers[length + REJECTED] = onRejection;

  if (length == 0 && parent._state) {
    asap(publish, parent);
  }
}

class Promise {
  constructor(resolver){
    this._result = this._state = void 0;
    this._subscribers = [];
    resolver((value) => {
      resolve(this, value);
    },(reason) => {
      reject(this, reason);
    });
  }

  then(onFulfillment, onRejection) {
    const parent = this;
    const child = new this.constructor(() => {});
    const { _state, _result } = parent;
    const { _cState } = child;
    if(_state) {
      const callback = arguments[_state - 1];
      asap(() => invokeCallback(_state, child, callback, _result));
    } else {
      subscribe(parent, child, onFulfillment, onRejection);
    }
    
    return child;
  }
}

// demo
const promise1 = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve('promise1 resolve')
  }, 1000);
})
.then((value)=>{
  console.log(value);
  const promise2 = new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve('promise2 resolve');
    }, 500);
  });
  return promise2;
})
.then((value)=>{
  console.log(value);
  return 'end';
})
.then((value)=>{
  console.log(value);
})
;

```

您可以在 [codpen](https://codepen.io/anon/pen/qoqJGx?editors=1112) 中找到此代码.

这份代码去除了很多校验逻辑，以及 asap 方法的 queue 缓冲等等，所以只是用来说明问题的，基本由一下几部分组成的：
* promise 的状态定义 `PENDING` `FULFILLED` `REJECTED`
* `promise` 类实现
* `then` 方法的实现
* 一些工具方法比如：`resolve` `reject` 等等。

需要说明的是 promise 的初始状态是 `undefined`，resolve 或者 reject 之后状态改变为对应的 `FULFILLED` 或 `REJECTED`。


简单描述一下实现逻辑：promise 的处理函数中可以立即回调 `resolve/reject` 或者是延迟（异步）回调，所以在 `then` 方法的实现中如果 promise 的状态存在，说明处理函数是立即回调，那么就可以立即调用 asap 来处理 callback；如果不存在，说明处理函数异步回调了，那么就把当前要处理的 callback 注册到 subscribers 中，当此 promise 被 resolve 或者 reject 的时候，在最终调用的 fulfill 方法里调用之前注册在 subscribers 中的 callback，最后返回的新建的 child 以达到链式调用的效果。