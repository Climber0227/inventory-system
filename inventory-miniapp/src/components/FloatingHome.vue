<template>
  <view class="float-home" @click="goHome">
    <text class="fh-icon">⌂</text>
  </view>
</template>

<script setup>
function goHome() {
  uni.switchTab({ url: '/pages/home/home' })
}
</script>

<style scoped>
.float-home {
  position: fixed; bottom: 100px; right: 16px;
  width: 44px; height: 44px; border-radius: 22px;
  background: rgba(46,125,50,0.85); color: #fff;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 2px 10px rgba(0,0,0,0.2); z-index: 999;
}
.fh-icon { font-size: 22px; line-height: 1; }
</style>
