---
title: JavaScript 中的 Promise
date: 2018-03-19 13:31:05
tags:
- JavaScript
- 前端
- Promise
- 异步
---

# 浏览器支持和 Polyfil

在 Chrome 32、Opera 19、Firefox 29、Safari 8 和 Microsoft Edge 中，promise 默认启用。


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