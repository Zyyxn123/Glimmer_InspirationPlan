import { ComponentsColor } from "utils"

@Component
export struct NameAndSign {
  @State userName: string = '默认用户名'
  @State signature: string = '人生如逆旅，我亦是行客'

  build() {
    Row({ space: 15 }) {
      Text(this.userName)
        .fontSize(this.userName.length < 5 ? 24 : 18)
        .fontColor(ComponentsColor.AZURITE_DARK_6TH)

      Text(this.signature)
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