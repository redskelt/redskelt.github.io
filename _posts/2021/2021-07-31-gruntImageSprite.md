---
layout: post
title:  "CSS 이미지 스프라이트(Image Sprite)"
date:   2021-07-31 16:26:02 +0900
categories: [css]
---

---


1. **node js** 설치
2. **npm**(**node package manager**) 설치
3. **npm**으로 **grunt-cli**를 설치
```js
$ npm install -g grunt-cli
```
4. 프로젝트 지정 - **폴더 생성**
```js
$ mkdir ImageSpriteTest
```
5. 프로젝트의 **root folder** 이동
```js
$ cd ImageSpriteTest
```
6. **package.json** 
```js
$ npm init
```
7. **gruntfile.js** 파일 추가
```js
module.exports = function (grunt) {
  // Configure grunt
  grunt.initConfig({
    sprite:{
      all: {
        src: "icons/*.png",  //하나의 이미지로 합칠 대상 이미지들  
        dest: "sprites/icons.png", //합쳐진 이미지 
        destCss: "css/sprites.css" //합쳐진 이미지 위치 css
      }
    }
  });

  // Load in "grunt-spritesmith"
  grunt.loadNpmTasks("grunt-spritesmith");
};
```
8. **Grunt** 설치
```js
$ npm install grunt --save-dev
```
9. **grunt-spritesmith** 플러그인 설치
```js
$ npm install grunt-spritesmith
```
10. **Run** the grunt sprite task
```js
$ grunt sprite
```
11. **Result**

**ImageSpriteTest/sprites/icons.png**   
![SpriteImage](/static/img/posts/2021/20210730_icons.png)

**ImageSpriteTest/css/sprites.css**    
```css
.icon-menu_title_0 {
  background-image: url(../sprites/icons.png);
  background-position: 0px 0px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_1 {
  background-image: url(../sprites/icons.png);
  background-position: -49px 0px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_10 {
  background-image: url(../sprites/icons.png);
  background-position: 0px -48px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_11 {
  background-image: url(../sprites/icons.png);
  background-position: -49px -48px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_2 {
  background-image: url(../sprites/icons.png);
  background-position: -98px 0px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_3 {
  background-image: url(../sprites/icons.png);
  background-position: -98px -48px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_4 {
  background-image: url(../sprites/icons.png);
  background-position: 0px -96px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_5 {
  background-image: url(../sprites/icons.png);
  background-position: -49px -96px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_6 {
  background-image: url(../sprites/icons.png);
  background-position: -98px -96px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_7 {
  background-image: url(../sprites/icons.png);
  background-position: -147px 0px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_8 {
  background-image: url(../sprites/icons.png);
  background-position: -147px -48px;
  width: 49px;
  height: 48px;
}
.icon-menu_title_9 {
  background-image: url(../sprites/icons.png);
  background-position: -147px -96px;
  width: 49px;
  height: 48px;
}
```
