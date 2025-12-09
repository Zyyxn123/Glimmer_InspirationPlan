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

import { camera } from '@kit.CameraKit';

export interface CreateOutputConfig {
  // cameraManager?: camera.CameraManager
  // 可选。表示一个管理摄像头生命周期或统一调用的管理器实例（例如用于打开/关闭 camera、查询设备等）。
  // 可选的原因是有时只需要 device 即可，或者外部管理器通过其他方式注入。
  //
  // device: camera.CameraDevice
  // 必选。指定目标摄像头设备（例如后置/前置摄像头的抽象对象），通常包含设备 id、能力信息和方法（如 start/stop）。
  // 这是创建输出必需的核心参数。
  //
  // profile: camera.Profile
  // 必选。表示输出的配置档（例如分辨率、帧率、编码设置或流类型：preview/record 等）。
  // Profile 决定最终输出的格式与约束。
  //
  // sceneMode?: camera.SceneMode
  // 可选。场景模式（例如：人像、夜景、运动等），可能影响自动曝光/白平衡/对焦策略或输出 pipeline 的预设参数。
  // 如果不传，使用默认模式或由 device 决定。
  //
  // surfaceId?: string
  // 可选。表示用于渲染或传递数据的 surface（画面输出目标）的标识符，比如 UI Surface 或离屏缓冲区 id。
  // 如果没有 surface，输出可能以内存缓冲的方式交付或仅用于编码。
  cameraManager?: camera.CameraManager;
  device: camera.CameraDevice;
  profile: camera.Profile;
  sceneMode?: camera.SceneMode;
  surfaceId?: string;
}

// [Start OutputManager]
export default interface OutputManager {
  // 可选属性，代表当前由该管理器管理的 CameraOutput 实例
  // （假设 camera.CameraOutput 是由 @kit.CameraKit 提供的输出类型，可能包含开始/停止/配置方法）。
  //
  // 可为空（undefined），表示当前没有已创建或激活的输出。
  output?: camera.CameraOutput;
  //布尔值，用来快速判断输出是否处于激活（正在使用）状态。
  //
  // 一般在 createOutput 成功创建并启动输出后设为 true；在 release 后设为 false。
  //
  // 同步字段，便于调用方快速检查状态。
  isActive: boolean;
  //异步方法：接收上面定义的 CreateOutputConfig，返回一个 Promise，resolve 为 camera.CameraOutput 或 undefined。
  //
  // 语义：
  // 负责：创建并初始化 CameraOutput（例如配置分辨率、绑定 surface、注册回调、启动流等）。
  // 返回：若创建成功，返回 CameraOutput 实例；若失败或不需要返回（例如仅内部管理且外部不需引用），可返回 undefined。
  //
  // 为什么返回 Promise：创建输出通常涉及异步资源（打开设备、申请 surface、编解码器初始化等），因此用异步接口更合理。
  createOutput: (config: CreateOutputConfig) => Promise<camera.CameraOutput | undefined>;
  //异步释放方法：要做的通常包括停止输出流、注销回调、释放硬件/内存资源、清理 output 字段并设置 isActive = false。
  //
  // 返回 Promise<void> 表示释放完成的通知，以便调用方在释放完成后进行下一步（例如销毁 UI）。
  release: () => Promise<void>;
}
// [End OutputManager]