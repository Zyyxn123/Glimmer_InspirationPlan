import { QuickStart } from 'quickstart'
import { ComponentsSize, ComponentsColor, LogOrRegPreference } from 'utils'
import { hilog } from '@kit.PerformanceAnalysisKit'

let date = new Date()

@Entry
@Component
struct Index {
  private logOrRegPreference: LogOrRegPreference = LogOrRegPreference.Instance()

  aboutToAppear(): void {
    this.logOrRegPreference.initPre(this.getUIContext().getHostContext() as Context)
    this.logOrRegPreference.setCurAccDate()
    AppStorage.setOrCreate('curAccSignInDateCount', this.logOrRegPreference.getCurAccSignInDateCount())
    AppStorage.setOrCreate('curAccount', this.logOrRegPreference.getCurAcc())
    AppStorage.setOrCreate('totalSearchNum', this.logOrRegPreference.getCurAccTotalSearchNum())
    AppStorage.setOrCreate('totalStudyNum', this.logOrRegPreference.getCurAccTotalStudyNum())
    if (date.toISOString().split('T')[0].toString() !== this.logOrRegPreference.getCurAccDate()) {
      this.logOrRegPreference.setIsFirstSignState(true)
      this.logOrRegPreference.setCurAccTotalLivenessPer(0)
      AppStorage.setOrCreate('totalLivenessPer', this.logOrRegPreference.getCurAccTotalLivenessPer())
      AppStorage.setOrCreate('curDate', this.logOrRegPreference.getCurAccDate())
    } else {
      this.logOrRegPreference.setIsFirstSignState(false)
      AppStorage.setOrCreate('totalLivenessPer', this.logOrRegPreference.getCurAccTotalLivenessPer())
      AppStorage.setOrCreate('curDate', this.logOrRegPreference.getCurAccDate())
    }
  }

  aboutToDisappear(): void {
    this.logOrRegPreference.setCurAccTotalSearchNum(AppStorage.get('totalSearchNum')!)
    this.logOrRegPreference.setCurAccTotalStudyNum(AppStorage.get('totalStudyNum')!)
    this.logOrRegPreference.setCurAccTotalLivenessPer(AppStorage.get('totalLivenessPer')!)
    this.logOrRegPreference.setCurAccDate()
    this.logOrRegPreference.setIsFirstSignState(false)
    // this.logOrRegPreference.setCurAccSignInDateCount()
  }

  build() {
    Column() {
      QuickStart()
    }
    .width(ComponentsSize.WIDTH_SIZE_MAX)
    .height(ComponentsSize.HEIGHT_SIZE_MAX)
    .backgroundColor(ComponentsColor.BACKGROUND_COLOR_)
  }
}

