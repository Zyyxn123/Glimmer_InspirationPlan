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

import { Point } from '@kit.TestKit';
import { camera } from '@kit.CameraKit';
import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'utils';

// 将 src 限在 range[0] 到 range[1] 之间（闭区间）。若 src 小于最小值返回最小值；
// 若大于最大值返回最大值；否则返回原值。
//
// 如果 range 长度小于 2（无效范围），直接返回原值（不做限制）。
export function limitNumberInRange(src: number, range: number[]) {
  if (range.length < 2) {
    return src;
  }
  if (src < range[0]) {
    return range[0];
  }
  if (src > range[1]) {
    return range[1];
  }
  return src;
}

// find start index the target in which range
// eg： target: 1.5   arr: [0, 1, 5, 10]  return 1
// 给定一个数列 arr（表示分界点），找到 target 落在哪一段区间的起始索引。
//
// 例如例子里：区间分界点 [0,1,5,10] 表示区间 [0,1), [1,5), [5,10), [10,∞)。target=1.5 属于 [1,5)，
// 返回该区间起始索引 1。
//
// 若 target >= arr[last]，直接返回最后索引（表示最后一段）。
export function findRangeIndex(target: number, arr: number[]) {
  if (arr.length === 0) {
    return -1;
  }
  if (target >= arr[arr.length - 1]) {
    return arr.length - 1;
  }
  return [...arr].sort((a, b) => a - b).findIndex((n, i) => {
    return target >= n && target < arr[i + 1];
  });
}

// Math floor float by digit
// eg: toFixed(9.97, 1) -> 9.9
// 将数字向下（floor）截断到指定小数位数，然后返回一个固定小数位数的字符串。
//
// 与 Number.prototype.toFixed 不同的是：这里是向下截断（向下取整），而 toFixed 会四舍五入。
export function toFixed(num: number, digit: number): string {
  const scale = 10**digit;
  return (Math.floor(num * scale) / scale).toFixed(digit);
}

// [Start getClampedChildPosition]
// cal absolute position in parent area
// 给定父容器尺寸 parentSize 和子元素尺寸 childSize，以及希望子元素中心在 point（相对于父容器坐标系）的位置，
// 函数返回合法的 { left, top }，使得子元素完全留在父容器内部（不会超出边界）。
//
// 算法思路：将 point 作为子元素中心，计算左上角 (left,top)，
// 然后将其限制在合法的范围 [0, parentSize - childSize]。
export function getClampedChildPosition(childSize: Size, parentSize: Size, point: Point): Edges {
  // center point
  let left = point.x - childSize.width / 2;
  let top = point.y - childSize.height / 2;
  // limit in left
  if (left < 0) {
    left = 0;
  }
  // limit in right
  if (left + childSize.width > parentSize.width) {
    left = parentSize.width - childSize.width;
  }
  // limit in top
  if (top < 0) {
    top = 0;
  }
  // limit in bottom
  if (top + childSize.height > parentSize.height) {
    top = parentSize.height - childSize.height;
  }
  return { left, top };
}

// [End getClampedChildPosition]
// 使用 UIContext.getPromptAction().openToast(...) 去显示一个 Toast 提示，
// 并在调用失败时捕获 BusinessError 并记录日志。
//
// 参数包含 message, duration, alignment, offset，都设置了默认值。
export function showToast(
  UIContext: UIContext,
  message: ResourceStr = '',
  duration = 2000,
  alignment = Alignment.Top,
  offset: Offset = { dx: 0, dy: 300 }
) {
  UIContext.getPromptAction().openToast({
    message,
    duration,
    alignment,
    offset
  }).catch((err: BusinessError) => {
    Logger.error('showToast', `showToast failed, code is ${err.code}, message is ${err.message}`);
  });
}

// [Start calCameraPoint]
// 将屏幕事件坐标 (eventX, eventY)（像素）映射为摄像头坐标系中的归一化点 (camera.Point，通常 x/y ∈ [0,1]）。
//
// 考虑了屏幕旋转（display.getDefaultDisplaySync().rotation
// 返回 0..3，乘 90 得到角度）来校正触摸与摄像头坐标间的变换。
export function calCameraPoint(eventX: number, eventY: number, width: number, height: number): camera.Point {
  let displayDefault: display.Display | null = null;
  try {
    displayDefault = display.getDefaultDisplaySync();
  } catch (exception) {
    Logger.error('calCameraPoint', `calCameraPoint failed, code is ${exception.code}, message is ${exception.message}`);
  }
  const displayRotation = (displayDefault?.rotation ?? 0) * 90;
  if (displayRotation === 0) {
    return { x: eventY / height, y: 1 - eventX / width };
  }
  if (displayRotation === 90) {
    return { x: 1 - eventX / width, y: 1 - eventY / height };
  }
  if (displayRotation === 180) {
    return { x: 1 - eventY / height, y: eventX / width };
  }
  return { x: eventX / width, y: eventY / height };
}

// [End calCameraPoint]