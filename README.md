Array-Model
===

Extension of native Array object to make it a collection model. But it still real Array. So you can you can just wrap any exist Array in your project.

## Installation

via npm

```bash
npm install array-model
```

## Usage

Just create a array, call method `.model()` and you will have great collection object.

Simple example prevents addition of objects with wrong type.

```javascript
var arr = [].model();
arr.on('add', function(val, pos, arr) {
    if (typeof val !== 'number')
        arr.splice(pos, 1);
});

arr.push(42);
console.log(arr.slice());
arr.push('24');
console.log(arr.slice());
arr.push(24);
console.log(arr.slice());
// [42]
// [42]
// [42, 24]
```

Events work great even with assignments.

```javascript
var arr = [1,2,3].model()
arr.on('add', function(val, pos) {
    console.log(val, pos);
});
arr.on('remove', function(val, pos) {
    console.log(val, pos);
});
arr[1] = 4
// 2 1
// 4 1
```

Array-Model provides useful getters for you!

```javascript
var arr = [1,2,3].model();
arr.get(function(val) {
    return val*val;
});
console.log(arr.slice());
console.log(arr[2]);
 // [1,4,9]
 // 9
```

See more examples in `spec.coffee`.

## What Array-Model cannot do for you

Assignment to not exist values. It will not work and probably break your object.

```javascript
var arr = [].model();
arr.on('add', function(val, pos) { // won't be fired
    console.log(val, pos);
});
arr[0] = 'data';
```
