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

import { abilityAccessCtrl, Context, Permissions } from '@kit.AbilityKit';
import { Logger } from 'utils';

const TAG = 'PermissionManager';

// [Start request_permissions]
class PermissionManager {
  // atManager：静态持有一个 AtManager 实例（来自 abilityAccessCtrl.createAtManager()），
  // 用于与能力/权限系统交互。静态创建可以复用同一个 manager。
  private static atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

  // request 方法（异步）接收 permissions（字符串数组）和 context（Ability/AbilityContext）。
  static async request(permissions: Permissions[], context: Context) {
    try {
      const data = await PermissionManager.atManager.requestPermissionsFromUser(context, permissions);
      const grantStatus: number[] = data.authResults;
      const deniedPermissions = permissions.filter((_, i) => grantStatus[i] !== 0);
      for (const permission of deniedPermissions) {
        const secondGrantStatus = await PermissionManager.atManager.requestPermissionOnSetting(context, [permission]);
        if (secondGrantStatus[0] !== 0) {
          Logger.error(TAG, 'permission denied');
          throw new Error('permission denied');
        }
      }
    } catch (exception) {
      Logger.error(TAG, `request failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }
}

// [End request_permissions]

export default PermissionManager;

// 调用 requestPermissionsFromUser(context, permissions) —— 触发系统权限弹窗（第 1 次请求）。
// data.authResults 是一个 number[]，每个元素代表对应权限的授权状态（通常 0 表示已授予，非 0 表示拒绝或其它状态）。
//
// 用 grantStatus 过滤出首次被拒绝的权限 deniedPermissions。
//
// 对于每个被拒绝的权限，调用 requestPermissionOnSetting(context, [permission]) —— 一般会打开系统设置页面或弹窗引导用户手动去“设置中允许”。
// 它返回一个数组 secondGrantStatus，同样检查下标 0 的值是否为 0（0 表示授权成功）。
//
// 如果 secondGrantStatus[0] !== 0，说明用户在设置里也没有允许该权限，
// 这里 Logger.error 记录并 throw new Error('permission denied') —— 终止流程并向上抛出异常。
//
// try/catch：包裹整个流程，如果任何 await 抛异常，会落到 catch，并使用 Logger.error 打印 exception.code / exception.message。