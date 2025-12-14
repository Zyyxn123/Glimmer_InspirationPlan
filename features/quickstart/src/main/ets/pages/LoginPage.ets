import { ComponentsSize, ComponentsColor, ComponentsPictures, LogOrRegPreference, UserBasicMsgPreference } from 'utils'
import { promptAction } from '@kit.ArkUI';
import { SettingViewModel } from 'mine';
import { CPAViewModel } from 'mine/src/main/ets/ViewModel/CPAViewModel';


@Builder
export function LoginPageBuilder() {
  LoginPage();
}


@Component
export struct LoginPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('PageInfos') pageInfo: NavPathStack = new NavPathStack();
  @State isShown_dolphin: boolean = false
  @State isShown_wave_left: boolean = false
  @State isShown_wave_right: boolean = false
  @State isShown_sea: boolean = false
  @State myAccount: string = ''
  @State myPassword: string = ''
  private cpaVM: CPAViewModel = CPAViewModel.Instance()
  private settingVM: SettingViewModel = SettingViewModel.Instance()
  private logOrRegPreference: LogOrRegPreference = LogOrRegPreference.Instance()
  private userBasicMsgPreference: UserBasicMsgPreference = UserBasicMsgPreference.Instance()
  private context: Context = this.getUIContext().getHostContext() as Context
  private intervalId: number | null = null;
  private effect: TransitionEffect = TransitionEffect.asymmetric(
    TransitionEffect.OPACITY.animation({ curve: Curve.EaseIn })
      .combine(TransitionEffect.scale({ x: 0, y: 0 }))
    ,
    TransitionEffect.opacity(0.99)
  )
  private loadingEffect_dolphin: TransitionEffect = TransitionEffect.asymmetric(
    TransitionEffect.rotate({ angle: 30 }).animation({ duration: 900, curve: Curve.EaseOut })
      .combine(TransitionEffect.translate({ x: 110, y: 100 }))
    ,
    TransitionEffect.rotate({ angle: -45 }).animation({ duration: 900, curve: Curve.EaseIn })
      .combine(TransitionEffect.translate({ x: -80, y: 100 }))
  )
  private loadingEffect_wave: TransitionEffect = TransitionEffect.asymmetric(
    TransitionEffect.OPACITY.animation({ duration: 350, curve: Curve.EaseIn })
      .combine(TransitionEffect.scale({ x: 0, y: 0 }))
    ,
    TransitionEffect.OPACITY.animation({ duration: 500, curve: Curve.EaseIn })
      .combine(TransitionEffect.scale({ x: 0, y: 0 }))
      .combine(TransitionEffect.translate({ y: 10 }))
  )

  aboutToAppear(): void {
    if (!this.logOrRegPreference.myPreference) {
      this.logOrRegPreference.initPre(this.context)
    }
    if (!this.userBasicMsgPreference.myPreference) {
      this.userBasicMsgPreference.initPre(this.context)
    }
  }

  build() {
    NavDestination() {
      Column() {
        /**
         * Image
         * */
        Image(ComponentsPictures.LOGIN_COLOR_BACKGROUND)
          .width('90%')
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            centerX: '50%',
            centerY: '50%',
            angle: 30
          })
          .margin({ left: 30, top: 15 })
          .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
        Image(ComponentsPictures.LOGIN_COLOR_WELCOME)
          .width(100)
          .margin({ top: 15, right: 150 })
        Image(ComponentsPictures.LOGIN_COLOR_WELCOME_TWO)
          .width(250)


        Column({ space: 15 }) {
          /**
           * Account
           * */
          Row() {
            Text('账号')
              .fontSize(20)
              .fontWeight(700)
              .padding({ right: 20 })
              .margin({ left: 10, right: 5 })
              .border({ width: { right: 2 }, color: ComponentsColor.a2 })
            TextInput({ placeholder: '仅限a~z、A~Z、0~9', text: $$this.myAccount })
              .backgroundColor(Color.Transparent)
              .maxLength(15)
              .caretStyle({ width: 3, color: ComponentsColor.a2 })
              .onChange((value: string) => {
                const validAccount = value.replace(/[^a-zA-Z0-9]/g, '');
                this.myAccount = validAccount;
              })
              .placeholderFont({ size: 11 })
          }
          .backgroundColor(ComponentsColor.a4)
          .width('80%')
          .height(50)
          .borderRadius(20)
          .transition(this.effect
            .combine(TransitionEffect.move(TransitionEdge.START).animation({ duration: 1000 }))
            .combine(TransitionEffect.translate({ x: 150 })))

          /**
           * Password
           * */
          Row() {
            Text('密码')
              .fontSize(20)
              .fontWeight(700)
              .padding({ right: 20 })
              .margin({ left: 10, right: 5 })
              .border({ width: { right: 2 }, color: ComponentsColor.a2 })
            TextInput({ placeholder: '仅限a~z、A~Z、0~9、*、_', text: $$this.myPassword })
              .width(200)
              .backgroundColor(Color.Transparent)
              .maxLength(15)
              .type(InputType.Password)
              .caretStyle({ width: 3, color: ComponentsColor.a2 })
              .showPasswordIcon(true)
              .placeholderFont({ size: 11 })
              .onChange((value: string) => {
                const validPassword = value.replace(/[^a-zA-Z0-9*_]/g, '');
                this.myPassword = validPassword;
              })
          }
          .backgroundColor(ComponentsColor.a4)
          .width('80%')
          .height(50)
          .borderRadius(20)
          .transition(this.effect
            .combine(TransitionEffect.move(TransitionEdge.END).animation({ duration: 1000 }))
            .combine(TransitionEffect.translate({ x: 150 })))

          /**
           * logic to login in
           * */
          Row({ space: 20 }) {
            Button('登录')
              .width('40%')
              .height(50)
              .backgroundColor(ComponentsColor.a2)
              .transition(TransitionEffect.translate({ y: 300 }).animation({ duration: 1000 })
                .combine(TransitionEffect.scale({ x: 0, y: 0 })))
              .onClick(() => {
                if (this.logOrRegPreference.isHasAcc(this.myAccount)
                  && this.logOrRegPreference.getPsw(this.myAccount) == this.myPassword) {
                  this.getUIContext().getPromptAction().showToast({
                    message: '登陆成功',
                    duration: 2000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 80
                  })
                  AppStorage.set('curAccount', this.myAccount)
                  this.settingVM.setCurACC()
                  this.settingVM.setPsw()
                  this.settingVM.setPh()
                  this.settingVM.setUserName()
                  this.settingVM.setSignature()
                  this.cpaVM.getCurPh()

                  this.isShown_sea = true
                  this.intervalId = setInterval(() => {
                    this.isShown_dolphin = !this.isShown_dolphin
                    this.isShown_wave_left = !this.isShown_wave_left
                    setTimeout(() => {
                      this.isShown_wave_right = !this.isShown_wave_right
                    }, 1200)
                  }, 600)

                  setTimeout(() => {
                    AppStorage.set('LoginState', true)
                    this.isShown_dolphin = false
                    this.isShown_wave_left = false
                    this.isShown_wave_right = false
                    this.isShown_sea = false
                    clearInterval(this.intervalId)
                    this.intervalId = null
                  }, 5500)
                } else {
                  this.getUIContext().getPromptAction().showToast({
                    message: '账号或密码错误',
                    duration: 2000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 80
                  })
                }
              })

            Button('注册')
              .width('40%')
              .height(50)
              .backgroundColor(ComponentsColor.a2)
              .transition(TransitionEffect.translate({ y: 300 }).animation({ duration: 1000 })
                .combine(TransitionEffect.scale({ x: 0, y: 0 })))
              .onClick(() => {
                if (this.myAccount.length == 0 || this.myPassword.length == 0) {
                  this.getUIContext().getPromptAction().showToast({
                    message: '请输入账号或密码',
                    duration: 2000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 80
                  })
                } else if ((this.myAccount.length < 9 || this.myAccount.length > 16)
                  || (this.myPassword.length < 9 || this.myPassword.length > 16)) {
                  this.getUIContext().getPromptAction().showToast({
                    message: '账号密码只能设置9~16位',
                    duration: 2000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 80
                  })
                } else if (this.logOrRegPreference.isHasAcc(this.myAccount)) {
                  this.getUIContext().getPromptAction().showToast({
                    message: '该账号已存在',
                    duration: 2000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 80
                  })
                } else {
                  this.getUIContext().getPromptAction().showToast({
                    message: '注册成功',
                    duration: 1000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 80
                  })
                  this.logOrRegPreference.registerAcc(this.myAccount, this.myPassword)
                  AppStorage.set('curAccount', this.myAccount)
                  this.settingVM.setCurACC()
                  this.settingVM.setPsw()
                  this.settingVM.setPh()
                  this.settingVM.setUserName()
                  this.settingVM.setSignature()
                  this.cpaVM.getCurPh()

                  this.isShown_sea = true
                  this.intervalId = setInterval(() => {
                    this.isShown_dolphin = !this.isShown_dolphin
                    this.isShown_wave_left = !this.isShown_wave_left
                    setTimeout(() => {
                      this.isShown_wave_right = !this.isShown_wave_right
                    }, 1200)
                  }, 600)

                  setTimeout(() => {
                    AppStorage.set('LoginState', true)
                    this.isShown_dolphin = false
                    this.isShown_wave_left = false
                    this.isShown_wave_right = false
                    this.isShown_sea = false
                    clearInterval(this.intervalId)
                    this.intervalId = null
                  }, 5500)
                }
              })
          }
          .width('90%')
          .padding({ left: '10%' })
        }
        .height(180)

        /**
         * loading animation
         * */
        Stack({ alignContent: Alignment.Bottom }) {
          if (this.isShown_sea) {
            Divider()
              .margin({ bottom: 2 })
              .width('100%')
              .strokeWidth(4)
              .color(ComponentsColor.a3)
              .transition(TransitionEffect.OPACITY.animation({ duration: 400 }))
          }

          if (this.isShown_dolphin) {
            Image(ComponentsPictures.LOGIN_UPLOADING_ANIMATION)
              .width(40)
              .transition(this.loadingEffect_dolphin)
              .margin({ bottom: 90 })
          }

          if (this.isShown_wave_left) {
            Image(ComponentsPictures.LOGIN_UPLOADING_ANIMATIONTWO)
              .width(60)
              .margin({ left: 200 })
              .transition(this.loadingEffect_wave)
              .fillColor(ComponentsColor.a3)
          }

          if (this.isShown_wave_right) {
            Image(ComponentsPictures.LOGIN_UPLOADING_ANIMATIONTWO)
              .width(60)
              .margin({ right: 170 })
              .transition(this.loadingEffect_wave.animation({ delay: 600 }))
              .fillColor(ComponentsColor.a3)
          }
        }
        .height(200)

        // 隐私条例
        Button('快捷登录')
          .onClick(() => {
            AppStorage.set('LoginState', true)
          })
      }
      .width(ComponentsSize.WIDTH_SIZE_MAX)
      .height(ComponentsSize.HEIGHT_SIZE_MAX)
      .backgroundColor(ComponentsColor.a5)
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })

  }
}