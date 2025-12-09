import { sensor } from '@kit.SensorServiceKit';
import { common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import { curves } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  CameraManager,
  GridLine,
  ImageReceiverManager,
  LevelIndicator,
  PhotoManager,
  PreviewManager,
  VideoManager
} from 'camera';
import CameraConstant from '../constants/Constants';
import { calCameraPoint, getClampedChildPosition, limitNumberInRange, showToast } from '../utils/CommonUtil';
import RefreshableTimer from '../utils/RefreshableTimer';
import PermissionManager from '../utils/PermissionManager';
import ZoomButtonsView from '../views/ZoomButtonsView';
import ModeButtonsView from '../views/ModeButtonsView';
import SettingButtonsView from '../views/SettingButtonsView';
import OperateButtonsView from '../views/OperateButtonsView';
import PreviewViewModel from '../viewmodels/PreviewViewModel';
import { Logger } from 'utils';

@Extend(SymbolGlyph)
function funcButtonStyle() {
  .fontSize(22)
  .fontColor([Color.White])
  .borderRadius('50%')
  .padding(12)
  .backgroundColor('#664D4D4D')
}

const TAG = 'Index'

@Entry
@Component
export struct Index {
  // context：当前组件/页面的 HostContext，通常用于获取能力（Camera、UI 等）和系统服务。
  //
  // applicationContext：整个应用级别的 Context，可以用于注册应用生命周期事件（前台/后台）。
  //
  // windowClass：当前窗口实例（MainWindow），可用于监听窗口尺寸变化、旋转等事件，例如 windowSizeChange。
  private context: Context = this.getUIContext().getHostContext()!;
  private applicationContext = this.context.getApplicationContext();
  private windowClass = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync();
  // VideoManager：管理视频拍摄输出，包括开始/停止录像。
  //
  // PhotoManager：管理拍照输出和 LivePhoto（动态照片）。
  //
  // PreviewManager：管理实时预览输出，onPreviewStart 是回调，用于在每帧预览开始时做 UI 或逻辑处理。
  //
  // ImageReceiverManager：用于接收原始图像帧（PixelMap），可以用于特效或保存。
  //
  // CameraManager：统一管理相机实例，负责启动、停止、切换摄像头，并整合上面 4 个输出管理器。
  @State videoManager: VideoManager = new VideoManager(this.context);
  @State isSinglePhoto: boolean = false;
  @State isLivePhoto: boolean = false;
  private photoManager: PhotoManager = new PhotoManager(this.context, true, this.isSinglePhoto);
  private previewManager: PreviewManager = new PreviewManager(() => {
    this.onPreviewStart()
  });
  private imageReceiverManager: ImageReceiverManager = new ImageReceiverManager(px => {
    this.onImageReceiver(px);
  });
  private cameraManager: CameraManager = new CameraManager(this.context, [this.previewManager,
    this.photoManager, this.videoManager, this.imageReceiverManager]);
  // previewVM：预览 ViewModel，保存当前预览尺寸、缩放、曝光、相机模式等数据。
  //
  // isGridLineVisible：网格线显示状态（取景辅助）。
  //
  // isLevelIndicatorVisible：水平仪/倾斜指示器显示状态。
  //
  // isPreviewImageVisible：拍照后的静态预览是否显示。
  //
  // isFocusBoxVisible：对焦框是否显示。
  //
  // focusBoxPosition & focusBoxSize：对焦框位置和大小。
  //
  // focusBoxTimer：自动隐藏对焦框的定时器，3秒后隐藏。
  @State previewVM: PreviewViewModel = new PreviewViewModel(this.getUIContext());
  @State isGridLineVisible: boolean = false;
  @State isLevelIndicatorVisible: boolean = false;
  @State isPreviewImageVisible: boolean = false;
  @State isFocusBoxVisible: boolean = false;
  @State focusBoxPosition: Edges = { top: 0, left: 0 };
  private focusBoxSize: Size = { width: 80, height: 80 };
  private focusBoxTimer: RefreshableTimer = new RefreshableTimer(() => {
    this.isFocusBoxVisible = false;
  }, 3 * 1000);
  // exposureFontSize：曝光调节提示文字大小。
  //
  // isSleeping：设备进入休眠状态（长时间无操作）。
  //
  // sleepTimer：可刷新定时器，当用户长时间未操作时，自动关闭相机并给预览打模糊。
  private exposureFontSize: number = 24;
  @State isSleeping: boolean = false;
  private sleepTimer?: RefreshableTimer;
  // zoomRange：当前相机可用缩放范围（最小/最大）。
  //
  // zooms：UI 上的缩放档位（1x、5x、10x）。
  //
  // currentZoom：当前实际缩放值。
  //
  // isZoomPinching：是否正在用双指缩放。
  //
  // originZoomBeforePinch：记录双指缩放开始前的缩放值，用于增量计算。
  private zoomRange: number[] = [];
  @State zooms: number[] = [1, 5, 10];
  @State currentZoom: number = 1;
  @State isZoomPinching: boolean = false;
  private originZoomBeforePinch: number = 1; // record zoom after pinch, sale base it.
  // isStabilizationEnabled：是否开启视频/拍照防抖。
  //
  // previewImage：拍照后显示的静态图片，支持 PixelMap 或本地资源字符串。
  //
  // PreviewImageHeight：UI 上显示缩略预览的高度。
  @State isStabilizationEnabled: boolean = false;
  @State previewImage: PixelMap | ResourceStr = '';
  private PreviewImageHeight: number = 80;
  // photoDelayTime & photoRemainder：延迟拍照倒计时相关。
  //
  // isDelayTakePhoto：是否正在倒计时拍照。
  //
  // acc：加速度/重力传感器数据，用于判断设备姿态或稳定性。
  @State photoDelayTime: number = 0;
  @State photoRemainder: number = 0;
  @State isDelayTakePhoto: boolean = false;
  @State acc: sensor.AccelerometerResponse = { x: 0, y: 0, z: 0 } as sensor.AccelerometerResponse;
  // 回调函数，用于在旋转或窗口尺寸变化时重新设置预览尺寸。
  private setPreviewSize: () => void = () => {
    this.previewVM.setPreviewSize();
  }
  // isShowBlack：拍照或切换相机时显示黑色遮罩。
  //
  // captureClickFlag：拍照点击状态，绑定到 Storage，可跨页面/跨组件共享。
  //
  // flashBlackOpacity：黑色遮罩透明度，用于闪光动画或拍照反馈。
  @State isShowBlack: boolean = false;
  @StorageLink('captureClick') @Watch('onCaptureClick') captureClickFlag: number = 0;
  @State flashBlackOpacity: number = 1;

  // 订阅重力（重力传感器）事件以获取设备姿态（addGravityEventListener）
  //
  // 初始化“休眠计时器”，在一段时间无交互时暂停相机（initSleepTimer）
  //
  // 监听应用进入前台/后台以启动/释放相机（registerApplicationStateChange）
  //
  // 监听窗口尺寸/方向变化以调整预览（addOrientationChangeEventListener / removeOrientationChangeEventListener）
  //
  // 在折叠设备状态变化时重启相机（onFoldStatusChange）
  async aboutToAppear() {
    this.addGravityEventListener();
    this.initSleepTimer();
    this.registerApplicationStateChange();
    this.addOrientationChangeEventListener();
    try {
      display.on('foldStatusChange', () => {
        this.onFoldStatusChange()
      });
    } catch (exception) {
      Logger.error(TAG, `onFoldStatusChange failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }

  aboutToDisappear(): void {
    this.removeOrientationChangeEventListener();
  }

  // [Start addGravityEventListener]
  // 订阅重力传感器（Gravity）。回调把采样到的 data 存到 this.acc（通常用于判断设备朝向、抖动、放下/抬起等）。
  //
  // 传入的第三个参数 { interval: 100 * 1000 * 1000 } 看起来是 100ms，
  // 但注意单位：很多原生传感器 API 使用纳秒为单位（100 * 10^6 ns = 100ms），也有用毫秒的实现。
  // 你这段代码注释正确假设为 100ms，但务必确认平台文档。
  addGravityEventListener() {
    try {
      sensor.on(sensor.SensorId.GRAVITY, (data) => {
        this.acc = data;
      }, { interval: 100 * 1000 * 1000 }); // 100ms
    } catch (exception) {
      Logger.error(TAG, `addGravityEventListener failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }

  // [End addGravityEventListener]

  // 监听窗口大小变化（例如旋转、折叠、分屏）并调用 setPreviewSize 重新布局预览。
  addOrientationChangeEventListener() {
    this.windowClass.on('windowSizeChange', this.setPreviewSize);
  }

  removeOrientationChangeEventListener() {
    this.windowClass.off('windowSizeChange', this.setPreviewSize);
  }

  onImageReceiver(pixelMap: PixelMap) {
    this.previewImage = pixelMap;
  }

  // [Start initSleepTimer]
  // 创建一个可刷新（重置）的定时器：30s 无交互后关闭相机并给 preview 打模糊（睡眠）。
  //
  // 通过 UI 的 willClick 事件来刷新定时器 — 用户有交互就延长活跃期。
  initSleepTimer() {
    this.sleepTimer = new RefreshableTimer(() => {
      this.previewVM.openPreviewBlur();
      this.isSleeping = true;
      this.cameraManager.release();
    }, 30 * 1000);
    this.sleepTimer.start();
    const observer = this.getUIContext().getUIObserver();
    observer.on('willClick', () => {
      this.sleepTimer?.refresh();
    });
  }

  // [End initSleepTimer]

  // 折叠设备状态（foldable）变化时重启相机（先释放再启动），并同步设置。
  async onFoldStatusChange() {
    await this.cameraManager.release();
    await this.startCamera();
    this.syncButtonSettings();
  }

  // [Start registerApplicationStateChange]
  // 订阅应用生命周期事件：
  //
  // 进入前台：重启相机并同步按钮设置
  //
  // 进入后台：模糊预览并释放相机
  registerApplicationStateChange() {
    this.applicationContext.on('applicationStateChange', {
      onApplicationForeground: async () => {
        await this.startCamera();
        // [StartExclude registerApplicationStateChange]
        this.syncButtonSettings();
        // [EndExclude registerApplicationStateChange]
      },
      onApplicationBackground: () => {
        // [StartExclude registerApplicationStateChange]
        this.previewVM.openPreviewBlur();
        // [EndExclude registerApplicationStateChange]
        this.cameraManager.release();
      }
    })
  }

  ////
  async startCamera() {
    // cameraPosition：从 PreviewViewModel 拿到当前是前/后摄（枚举值）。
    //
    // sceneMode：拍照或录像场景（用于相机初始化）。
    //
    // this.previewVM.surfaceId：XComponent 提供的 surface id（必须在 XComponent onLoad 时已取得）。
    //
    // this.previewVM.getProfile：传入一个 callback（或函数引用），
    // 用于相机在内部获取 camera.Profile（分辨率 / 格式）。
    // 注意：你传的是函数引用，不是调用结果，
    // 意味着 cameraManager.start 可能在内部调用该函数并传入相机方向参数（cameraOrientation）。
    // 确保 cameraManager.start 的签名与此契合。
    const cameraPosition = this.previewVM.getCameraPosition();
    const sceneMode = this.previewVM.getSceneMode();
    await this.cameraManager.start(this.previewVM.surfaceId, cameraPosition, sceneMode, this.previewVM.getProfile);
  }

  // [End registerApplicationStateChange]

  // 退出
  exitApp() {
    // exitApp() 调用 this.applicationContext.killAllProcesses() 来结束所有进程——相当于优雅或强制退出应用（依赖平台 API）。
    //
    // 该方法返回 Promise，但代码里没有 await，仅在其返回的 Promise 上添加 .catch() 来记录错误。
    // 也就是说 exitApp() 本身是同步返回的（并不会等待杀进程结束）。
    //
    // 日志使用 Logger.error（showToast 这个 tag 可能是拷贝错误，建议改为更合适的 tag）。
    this.applicationContext.killAllProcesses().catch((err: BusinessError) => {
      Logger.error('showToast', `showToast failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  onPreviewStart() {
    this.previewVM.closePreviewBlur();
  }

  // cameraManager.getZoomRange() 返回相机支持的缩放范围，
  // 常见形态可能是 [minZoom, maxZoom] 或更复杂数组（取决于你的实现）。
  //
  // 将返回值保存到 this.zoomRange（用于后续 limitNumberInRange 或 UI 显示）。
  //
  // 如果 minZoom 比 this.zooms[0] 更小，就把 minZoom 插入到 this.zooms 数组开头。
  // this.zooms 估计是你 UI 上用来展示刻度（例如 [1, 2, 3]）的数组。
  initZooms() {
    const zoomRange = this.cameraManager.getZoomRange();
    const minZoom = zoomRange[0];
    this.zoomRange = zoomRange;
    if (minZoom < this.zooms[0]) {
      this.zooms.unshift(minZoom);
    }
  }

  // 从 previewManager 读取支持的帧率集合 frameRates。
  // 假定 frameRates 是一个对象数组，frameRates[0] 带有 .min 和 .max 字段（通常表示支持的帧率范围）。
  //
  // 将 rates 设置为 [min, max]，并把 currentRate 设为 max（优先选择最高帧率以保证流畅）。
  //
  // 调用 previewManager.setFrameRate(maxRate, maxRate)
  // 将帧率设置为最大值（可能是设置给 preview 与录制两个通道的 fps）。
  initRates() {
    const frameRates = this.previewManager.getSupportedFrameRates();
    if (frameRates && frameRates[0]) {
      const minRate = frameRates[0].min;
      const maxRate = frameRates[0].max;
      this.previewVM.rates = [minRate, maxRate];
      this.previewVM.currentRate = maxRate;
      this.previewManager.setFrameRate(maxRate, maxRate);
    }
    ;
  }

  // 设置预览帧率 设置移动照片 设置单张拍照或连续拍照回调
  syncButtonSettings() {
    this.previewManager.setFrameRate(this.previewVM.currentRate, this.previewVM.currentRate);
    // 若 isLivePhoto = true：
    //
    // 按下快门前后录制短视频（类似 iPhone LivePhoto）
    //
    // CameraKit 会在拍照前后短暂录制 YUV / H264 视频
    this.photoManager.enableMovingPhoto(this.isLivePhoto);
    this.photoManager.setPhotoOutputCallback(this.isSinglePhoto);
  }

  flashBlackAnim() {
    this.flashBlackOpacity = 1;
    this.isShowBlack = true;
    animateToImmediately({
      curve: curves.interpolatingSpring(1, 1, 410, 38),
      delay: 50,
      onFinish: () => {
        this.isShowBlack = false;
        this.flashBlackOpacity = 1;
      }
    }, () => {
      this.flashBlackOpacity = 0;
    })
  }

  onCaptureClick(): void {
    this.flashBlackAnim();
  }

  @Builder
  preview() {
    // [Start Stack]
    Stack({
      alignContent: Alignment.Center
    }) {
      // [Start XComponent]
      // [Start XComponent_gesture]
      XComponent({
        type: XComponentType.SURFACE,
        controller: this.previewVM.xComponentController
      })
      // [StartExclude Stack]
      // [StartExclude XComponent_gesture]
        .onLoad(async () => {
          // [StartExclude XComponent]

          // 请求一组摄像头/麦克风/存储等运行时权限（CameraConstant.PERMISSIONS）。
          // 如果用户首次拒绝其中某个权限，打开系统设置尝试二次请求（requestPermissionOnSetting）。
          // 如果权限仍然被拒绝 → 记录错误并抛出（理想情况：让上层 .catch 捕获并执行 exitApp()）。
          // 如果权限全部被授予 → 后续继续初始化预览（获取 surface id、启动相机等）。
          await PermissionManager.request(CameraConstant.PERMISSIONS, this.context)
            .catch(() => {
              this.exitApp()
            });

          // [EndExclude XComponent]
          this.previewVM.surfaceId = this.previewVM.xComponentController.getXComponentSurfaceId();
          this.previewVM.setPreviewSize();
          this.previewVM.xComponentController.setXComponentSurfaceRotation({ lock: true });

          // [StartExclude XComponent]
          // 启动相机，把 Camera 输出绑定到 XComponent 的 surfaceId（预览画面）；
          //
          // 读取相机支持的变焦范围并初始化 UI 中的缩放选项；
          //
          // 读取相机支持的帧率并设置初始帧率。
          await this.startCamera();
          this.initZooms();
          this.initRates();
          // [EndExclude XComponent]
        })
        // [StartExclude XComponent_gesture]
        // [End XComponent]
        .gesture(
          PinchGesture({ fingers: 2 })
            .onActionStart(() => {
              this.originZoomBeforePinch = this.currentZoom;
              this.isZoomPinching = true;
              this.sleepTimer?.refresh();
            })
            .onActionUpdate((event: GestureEvent) => {
              if (this.previewVM.isVideoMode() && this.isStabilizationEnabled) {
                return;
              }
              const targetZoom = this.originZoomBeforePinch * event.scale;
              this.currentZoom = limitNumberInRange(targetZoom, this.zoomRange);
              this.cameraManager.setZoomRatio(this.currentZoom);
            })
            .onActionEnd(() => {
              this.isZoomPinching = false;
            })
        )
        // [End XComponent_gesture]
        .onClick(event => {
          this.isFocusBoxVisible = true;
          const previewSize = this.previewVM.previewSize;
          const cameraPoint = calCameraPoint(
            this.getUIContext().vp2px(event.x),
            this.getUIContext().vp2px(event.y),
            previewSize.width,
            previewSize.height
          );
          this.cameraManager.setFocusPoint(cameraPoint);
          this.cameraManager.setMeteringPoint(cameraPoint);
          this.focusBoxPosition = getClampedChildPosition(this.focusBoxSize, {
            width: this.getUIContext().px2vp(previewSize.width),
            height: this.getUIContext().px2vp(previewSize.height)
          }, event);
          this.focusBoxTimer.refresh();
        })
      // [EndExclude Stack]
      if (this.isGridLineVisible) {
        GridLine()
      }
      // [StartExclude Stack]
      if (this.isLevelIndicatorVisible) {
        LevelIndicator({
          acc: this.acc
        })
      }
      // focus box
      if (this.isFocusBoxVisible) {
        Image($r('app.media.focus_box'))
          .width(80)
          .height(80)
          .position(this.focusBoxPosition)
        SymbolGlyph($r('sys.symbol.sun_max'))
          .fontSize(this.exposureFontSize)
          .fontColor([Color.White])
          .position(this.getExposurePosition())
      }

      if (this.isDelayTakePhoto) {
        Text(`${this.photoRemainder}S`)
          .fontSize(44)
          .fontWeight(FontWeight.Regular)
          .fontColor(Color.White)
      }
      // [EndExclude Stack]

      if (this.isShowBlack) {
        Column()
          .id('black')
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
          .opacity(this.flashBlackOpacity)
      }
    }
    // [End Stack]
    .alignRules({
      middle: { anchor: '__container__', align: HorizontalAlign.Center }
    })
    .width(this.previewVM.getPreviewWidth())
    .height(this.previewVM.getPreviewHeight())
    .margin({ top: this.previewVM.getPreviewTop() })
    .blur(this.previewVM.blurRadius)
    .rotate(this.previewVM.blurRotation)
  }

  // [Start wakeupMask]
  // 用户 点击遮罩 后，会：
  //
  // 退出休眠状态（isSleeping = false）。
  //
  // 刷新休眠定时器（防止再次立即进入休眠）。
  //
  // 重新启动摄像头 (startCamera()).
  //
  // 同步 UI 的按钮状态 (syncButtonSettings()).
  @Builder
  wakeupMask() {
    Column() {
      Text('点击屏幕唤醒相机')
        .fontColor(Color.White)
        .opacity(0.6)
    }
    // [StartExclude wakeupMask]
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.Center)
    // [EndExclude wakeupMask]
    .onClick(async () => {
      this.isSleeping = false;
      this.sleepTimer?.refresh();
      await this.startCamera();
      this.syncButtonSettings();
      // ① this.isSleeping = false;
      //
      // 退出休眠状态。
      //
      // 控制其它 UI 逻辑，如隐藏遮罩、恢复按钮可用状态等。
      //
      // ② this.sleepTimer?.refresh();
      //
      // 使用可选链（?.）防止 timer 为 null 时崩溃。
      //
      // 刷新休眠定时器，避免相机刚启动就再次进入休眠。
      //
      // ③ await this.startCamera();
      //
      // 重新启动摄像头：
      //
      // 创建本地摄像头会话
      //
      // 打开前/后摄
      //
      // 打开预览 Surface
      //
      // 这是最核心的操作。
      //
      // ④ this.syncButtonSettings();
      //
      // 确保 UI 按钮状态与当前相机状态一致，例如：
      //
      // 切换到拍照按钮还是录像按钮？
      //
      // 禁止某些按钮？
      //
      // 显示缩略图？
    })
  }

  // [End wakeupMask]

  // 网格线开关
  // SymbolGlyph(...) 渲染一个系统图标：如果 isGridLineVisible 为 true 则显示“网格”图标，否则显示“网格关闭”图标。
  // 图标通过 $r(...) 读取资源（支持多语言与主题）。
  //
  // .funcButtonStyle()：代表一套封装好的样式（圆形按钮、大小、内边距、阴影等）。
  // 这是一个自定义样式的链式方法，统一按钮外观。
  //
  // .onClick(...)：点击切换 isGridLineVisible 状态（true/false 翻转），并通过 showToast(this.getUIContext(),
  // message) 弹出一个短提示，提示语也用资源 $r(...)（例如 “网格已打开” / “网格已关闭”）。
  @Builder
  gridLineButton() {
    SymbolGlyph(
      this.isGridLineVisible
        ? $r('sys.symbol.camera_assistive_grid')
        : $r('sys.symbol.camera_assistive_grid_slash')
    )
      .funcButtonStyle()
      .onClick(() => {
        this.isGridLineVisible = !this.isGridLineVisible;
        const message = this.isGridLineVisible ? '网格线已开启' : '网格线已关闭';
        showToast(this.getUIContext(), message);
      })
  }

  // 图标固定为“水平仪”符号（sys.symbol.horizontal_level）。
  //
  // 点击切换 isLevelIndicatorVisible（显示或隐藏水平仪），并弹出对应提示（打开/关闭）。
  //
  // 与 gridLineButton 相同的样式与交互逻辑。
  @Builder
  levelButton() {
    SymbolGlyph($r('sys.symbol.horizontal_level'))
      .funcButtonStyle()
      .onClick(() => {
        this.isLevelIndicatorVisible = !this.isLevelIndicatorVisible;
        const message = this.isLevelIndicatorVisible ? '水平仪已开启' : '水平仪已关闭';
        showToast(this.getUIContext(), message);
      })
  }

  // 图标根据 isPreviewImageVisible 切换为“可见/不可见”图标（eye / eye_slash）。
  //
  // 点击切换 isPreviewImageVisible，并显示提示，通常同时控制 previewImageView() 的显示/隐藏（你的 UI 绑定应依赖该 boolean）。
  //
  // 常用于开启/隐藏左下角拍照缩略图或拍照预览。
  @Builder
  previewImageButton() {
    SymbolGlyph(this.isPreviewImageVisible ? $r('sys.symbol.eye') : $r('sys.symbol.eye_slash'))
      .funcButtonStyle()
      .onClick(() => {
        this.isPreviewImageVisible = !this.isPreviewImageVisible;
        const message =
          this.isPreviewImageVisible ? '双路预览已开启' : '双路预览已关闭';
        showToast(this.getUIContext(), message);
      })
  }

  // getPreviewImageWidth()（宽度计算逻辑）
  getPreviewImageWidth() {
    let displayDefault: display.Display | null = null;
    try {
      displayDefault = display.getDefaultDisplaySync();
    } catch (exception) {
      Logger.error(TAG, `getDefaultDisplaySync failed, code is ${exception.code}, message is ${exception.message}`);
    }
    const rotation = (displayDefault?.rotation ?? 0) * 90;
    const ratio = this.previewVM.getPreviewRatio();
    const displayRatio = rotation === 90 || rotation === 270 ? 1 / ratio : ratio;
    return this.PreviewImageHeight / displayRatio;
  }

  getExposurePosition(): Edges {
    const focusBoxLeft = this.focusBoxPosition.left as number;
    const focusBoxTop = this.focusBoxPosition.top as number;
    const exposureWidth = this.exposureFontSize;
    const exposureHeight = this.exposureFontSize;
    const focusBoxWidth = this.focusBoxSize.width;
    const focusBoxHeight = this.focusBoxSize.height;
    const previewWidth = this.getUIContext().px2vp(this.previewVM.previewSize.width);
    const GAP = 10;
    const top = focusBoxTop - exposureHeight / 2 + focusBoxHeight / 2;
    const left = focusBoxLeft > previewWidth / 2
      ? focusBoxLeft - GAP - exposureWidth
      : focusBoxLeft + focusBoxWidth + GAP;
    return { top, left };
  }

  // 创建并返回一个 Image 组件，用来显示 this.previewImage（通常是拍照后的缩略图）。
  //
  // 图片尺寸由 .width(...) 和 .height(...) 指定；高度使用 this.PreviewImageHeight，
  // 宽度通过 getPreviewImageWidth() 计算以保持一定的长宽比。
  //
  // 使用 alignRules 把图片固定在容器的「左下角」（bottom: container bottom，left: container start）。
  //
  // 通过 .margin({ bottom: 10, left: 10 }) 在左下角向内偏移 10（单位与 UI 框架设定一致，通常是 VP）。
  @Builder
  previewImageView() {
    Image(this.previewImage)
      .width(this.getPreviewImageWidth())
      .height(this.PreviewImageHeight)
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })
      .margin({
        bottom: 10,
        left: 10
      })
  }

  // 按钮组容器
  @Builder
  funcButtonsView() {
    Column({ space: 24 }) {
      this.gridLineButton()
      this.levelButton()
      this.previewImageButton()
    }
    .alignRules({
      top: { anchor: 'settingButtonsView', align: VerticalAlign.Bottom },
      right: { anchor: 'settingButtonsView', align: HorizontalAlign.End }
    })
    .margin({
      top: 40,
      right: 10
    })
  }

  build() {
    RelativeContainer() {

      this.preview()

      if (this.isPreviewImageVisible) {
        this.previewImageView()
      }

      this.funcButtonsView()

      SettingButtonsView({
        previewVM: this.previewVM,
        cameraManager: this.cameraManager,
        previewManager: this.previewManager,
        photoManager: this.photoManager,
        videoManager: this.videoManager,
        photoDelayTime: this.photoDelayTime,
        isSinglePhoto: this.isSinglePhoto,
        isLivePhoto: this.isLivePhoto,
        isStabilizationEnabled: this.isStabilizationEnabled
      })

      // 限制 zoom 按钮的出现条件：
      //
      // 不在剩余照片数量限制状态
      //
      // 不在前置摄像头（前置通常无多焦段）
      //
      // 若启用防抖的录像模式，则隐藏 zoom
      if (!this.photoRemainder) {
        if (!this.previewVM.isFront &&
          !(this.isStabilizationEnabled && this.previewVM.isVideoMode())) {
          // 这个组件是摄像头 UI 中的“变焦按钮组”，根据 zooms 数组（如 [0.5, 1, 2, 5]）展示多个圆形按钮。
          // 用户点击按钮即可切换摄像头变焦倍率。
          ZoomButtonsView({
            cameraManager: this.cameraManager,
            zoomRange: this.zoomRange,
            zooms: this.zooms,
            currentZoom: this.currentZoom
          })
        }

        // 显示相机模式切换按钮（拍照 / 视频）
        //
        // 点击后切换相机模式
        //
        // 销毁旧的 Camera 管线并重新启动新的模式
        //
        // 配置新的模式参数（帧率、是否是移动照片模式、单张拍照回调）
        //
        // 同步 UI 设置，例如 PreviewViewModel 更新预览视图大小、场景模式等
        ModeButtonsView({
          previewVM: this.previewVM,
          photoManager: this.photoManager,
          videoManager: this.videoManager,
          cameraManager: this.cameraManager,
          syncButtonSettings: () => {
            this.syncButtonSettings();
          }
        })

        // 组件所做的事情
        //
        // 每个状态字段的作用
        //
        // 各按钮（拍照、录视频、切换镜头等）如何运作
        //
        // 生命周期、UI 构建逻辑
        //
        // 与 CameraManager / PhotoManager / VideoManager / PreviewViewModel 的交互机制
        OperateButtonsView({
          previewVM: this.previewVM,
          cameraManager: this.cameraManager,
          photoManager: this.photoManager,
          videoManager: this.videoManager,
          isDelayTakePhoto: this.isDelayTakePhoto,
          photoDelayTime: this.photoDelayTime,
          photoRemainder: this.photoRemainder,
          syncButtonSettings: () => {
            this.syncButtonSettings();
          }
        })
      }

      if (this.isSleeping) {
        this.wakeupMask()
      }

    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.Black)
    .onClick(() => {
    })
  }
}
