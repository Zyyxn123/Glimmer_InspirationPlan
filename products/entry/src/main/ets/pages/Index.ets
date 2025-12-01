import { QuickStart } from 'quickstart'
import { ComponentsSize, ComponentsColor } from 'utils'

@Entry
@Component
struct Index {
  build() {
    Column() {
      QuickStart()
    }
    .width(ComponentsSize.WIDTH_SIZE_MAX)
    .height(ComponentsSize.HEIGHT_SIZE_MAX)
    .backgroundColor(ComponentsColor.BACKGROUND_COLOR_)
  }
}

