/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// [Start RefreshableTimer]
class RefreshableTimer {
  // timerId?: number：保存 setTimeout 返回的定时器 id，用于 clearTimeout。
  // 在浏览器/JS 环境中 setTimeout 返回 number。
  //
  // timeout: number：超时时间（毫秒）。
  //
  // callback: () => void：超时触发时执行的回调。
  //
  // isActive: boolean：表示当前是否有未触发的定时器正在运行。
  private timerId?: number;
  private readonly timeout: number;
  private callback: () => void;
  private isActive: boolean = false;

  constructor(callback: () => void, timeout: number) {
    this.callback = callback;
    this.timeout = timeout;
  }


  // start()：启动计时器（先设置 timerId，并把 isActive 设置为 true）。
  // 计时结束时触发 callback() 并把 isActive 置 false。
  //
  // clear()：清除当前计时器并重置状态（将 timerId 设为 undefined，isActive = false）。
  //
  // refresh()：把计时器重置为全新的计时（等于 clear() 然后 start()），常用于“继续延时”。
  //
  // isRunning()：返回是否处于活动计时状态。
  start(): void {
    this.timerId = setTimeout(() => {
      this.callback();
      this.isActive = false;
    }, this.timeout);
    this.isActive = true;
  }

  clear(): void {
    clearTimeout(this.timerId);
    this.timerId = undefined;
    this.isActive = false;
  }

  refresh(): void {
    this.clear();
    this.start();
  }

  isRunning(): boolean {
    return this.isActive;
  }
}
// [End RefreshableTimer]

export default RefreshableTimer;
