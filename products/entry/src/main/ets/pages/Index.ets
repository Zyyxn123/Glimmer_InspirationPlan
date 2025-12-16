import { QuickStart } from 'quickstart'
import { ComponentsSize, ComponentsColor, LogOrRegPreference } from 'utils'

@Entry
@Component
struct Index {
  private logOrRegPreference: LogOrRegPreference = LogOrRegPreference.Instance()

  aboutToAppear(): void {
    AppStorage.setOrCreate('curAccount', this.logOrRegPreference.getCurAcc())
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

