
@Component
export default struct ClassifyItem {
  classifyName?: ResourceStr;
  @Prop isSelected: boolean = false;
  onClickAction = (): void => {}

  build() {
    Text(this.classifyName)

  }
}