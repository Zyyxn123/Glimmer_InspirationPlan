import ClassifyAlphaListModel from "../Model/ClassifyAlphaListModel"
import RegionListModel from "../Model/RegionListModel";

@Component
export struct regionItem {
  @State RegionItemStr: string = ''
  item?: RegionListModel

  aboutToAppear() {
    this.item = JSON.parse(this.RegionItemStr) as RegionListModel;
  }


  build() {
    Row({ space: 5}) {
        Text(this.item?.englishName)

        Text(this.item?.chineseName)
        Text(this.item?.code)

    }
    .clip(true)
    .width('100%')

  }
}