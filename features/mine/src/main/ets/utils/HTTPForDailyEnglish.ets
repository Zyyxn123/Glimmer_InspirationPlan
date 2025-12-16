import { http } from '@kit.NetworkKit'
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

const POETRY_URL: string = 'https://api.t1qq.com/api/tool/daytry'

@ObservedV2
export class HTTPForDailyEnglish {
  @Trace DE: httpRequestForDailyEnglishType | undefined = undefined

  httpRequestForDailyEnglish() {
    let httpRequest = http.createHttp()
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header))
    });
    httpRequest.request(
      POETRY_URL + '?key=ZXOFGo2yJ7f5RDhwMwIRzN0nnA' +
        '&time=today',
      {
        method: http.RequestMethod.GET,
        // 开发者根据自身业务需要添加header字段。
        header: {
          'Content-Type': 'application/json'
        },
      }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析。
        console.info('Resultss:' + JSON.stringify(data.result))
        let res: httpRequestForDailyEnglishType = JSON.parse(data.result.toString()) as httpRequestForDailyEnglishType
        this.DE = res
        httpRequest.destroy()
      } else {
        console.error('error:' + JSON.stringify(err))
        httpRequest.off('headersReceive')
        httpRequest.destroy()
      }
    })
  }
}

export interface httpRequestForDailyEnglishType {
  code: number
  data: dataType
  msg: string
}

export interface dataType {
  tts: string
  content: string
  note: string
  img: string
  picture: string
}