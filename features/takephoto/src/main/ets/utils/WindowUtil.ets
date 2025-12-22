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

import { display, window } from '@kit.ArkUI';
import { Logger } from 'utils';

const TAG = 'WindowUtil'



// 切换为沉浸式窗口（Immersive Mode）
//
// 根据指定宽高比（ratio）计算屏幕内可容纳的最大展示区域
//
// 获取当前窗口宽高比
class WindowUtil {
  // 进入沉浸式模式（隐藏系统栏 + 全屏）
  static async enterImmersive(window: window.Window): Promise<void> {
    try {
      // 使内容扩展到整个窗体，不再被状态栏/导航栏占位
      await window.setWindowLayoutFullScreen(true);
      // 传入空数组表示禁用所有系统栏（状态栏 + 导航栏）
      //
      // 视觉效果：真正的沉浸式体验（适用于拍照、视频录制、游戏、阅读等）
      await window.setWindowSystemBarEnable([]);
    } catch (exception) {
      Logger.error(TAG, 'Failed to enter immersive. Cause:', JSON.stringify(exception));
    }
  }

  // Given a ratio, obtain the maximum display width and height based on the screen width and height.
  // 根据指定宽高比，计算在当前屏幕中最大可容纳的展示区域
  static getMaxDisplaySize(ratio: number): Size {
    let defaultDisplay: display.Display | null = null;
    try {
      defaultDisplay = display.getDefaultDisplaySync();
    } catch (exception) {
      Logger.error(TAG, `getDefaultDisplaySync failed, code is ${exception.code}, message is ${exception.message}`);
    }
    //const defaultDisplay: display.Display = display.getDefaultDisplaySync();
    //屏幕宽度与高度获取
    const windowWidth: number = defaultDisplay?.width ?? 0;
    const windowHeight: number = defaultDisplay?.height ?? 0;
    const rotation = (defaultDisplay?.rotation ?? 0) * 90;
    // 处理屏幕旋转（横屏时宽高比交换）
    if (rotation === 90 || rotation === 270) {
      ratio = 1 / ratio;
    }
    // Calculate the height based on the screen width.
    // 根据屏幕宽度计算目标高度
    const calculatedHeight = windowWidth * ratio;
    if (calculatedHeight <= windowHeight) {
      return {
        width: windowWidth,
        height: calculatedHeight
      };
    } else {
      return {
        width: windowHeight / ratio,
        height: windowHeight
      };
    }
  }

  // 获取当前屏幕的高宽比（用于相机适配）
  static getWindowRatio(): number {
    try {
      const defaultDisplay: display.Display = display.getDefaultDisplaySync();
      return defaultDisplay.height / defaultDisplay.width;
    } catch (exception) {
      Logger.error(TAG, `getWindowRatio failed, code is ${exception.code}, message is ${exception.message}`);
      return 0;
    }
  }
}

export default WindowUtil;