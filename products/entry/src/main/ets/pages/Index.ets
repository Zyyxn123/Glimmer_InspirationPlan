import { QuickStart } from 'quickstart'
import { ComponentsSize, ComponentsColor, LogOrRegPreference } from 'utils'

@Entry
@Component
struct Index {
  private logOrRegPreference: LogOrRegPreference = LogOrRegPreference.Instance()

  aboutToAppear(): void {
    AppStorage.setOrCreate('curAccount', this.logOrRegPreference.getCurAcc())
    AppStorage.setOrCreate('totalSearchNum', this.logOrRegPreference.getCurAccTotalSearchNum())
    AppStorage.setOrCreate('totalStudyNum', this.logOrRegPreference.getCurAccTotalStudyNum())
    AppStorage.setOrCreate('totalLivenessPer', this.logOrRegPreference.getCurAccTotalLivenessPer())
  }
  aboutToDisappear(): void {
    this.logOrRegPreference.setCurAccTotalSearchNum(AppStorage.get('totalSearchNum')!)
    this.logOrRegPreference.setCurAccTotalStudyNum(AppStorage.get('totalStudyNum')!)
    this.logOrRegPreference.setCurAccTotalLivenessPer(AppStorage.get('totalLivenessPer')!)
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

