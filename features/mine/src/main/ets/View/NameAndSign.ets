import { ComponentsColor } from "utils"
import { SettingViewModel } from "../ViewModel/SettingViewModel"

@Component
export struct NameAndSign {
  private settingVM: SettingViewModel = SettingViewModel.Instance()

  build() {
    Row({ space: 15 }) {
      Text(this.settingVM.userName)
        .width(120)
        .fontSize(this.settingVM.userName.length < 5 ? 24 : 18)
        .fontColor(ComponentsColor.AZURITE_DARK_6TH)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis})

      Text(this.settingVM.signature)
        .width(120)
        .backgroundColor(ComponentsColor.AZURITE_BRIGHT_5TH)
        .fontColor(ComponentsColor.AZURITE_BRIGHT_1ST)
        .fontSize(10)
        .borderRadius(13)
        .height(25)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis})
        .padding({ left: 5, right: 5})
    }
    .margin({ left: 15, top: 15})
  }
}