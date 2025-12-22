import { http } from '@kit.NetworkKit'
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

const POETRY_URL: string = 'https://suapi.net/api/text/translate'

@ObservedV2
export class HTTPForZhToEn {
  @Trace static  myData: httpForZhToEnType | undefined = undefined
  @Trace static  myData_tran: string = ''
  @Trace static currText: string = ''

  static async  httpForZhToEn(wordOrSentence: string, to: string) {
    HTTPForZhToEn.currText = wordOrSentence
    hilog.info(0x0000, '[publicMainFuncTag]', '\'' + HTTPForZhToEn.currText + '\'')
    hilog.info(0x0000, '[publicMainFuncTag]', '\'' + to + '\'')
    let httpRequest = http.createHttp();
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });
    httpRequest.request(
      POETRY_URL + '?to=' + to + '&text[]=' + wordOrSentence.trim().split(' ').join(''),
      {
        method: http.RequestMethod.GET,
        // 开发者根据自身业务需要添加header字段。
        header: {
          'Content-Type': 'application/json'
        },
      }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析。
        hilog.info(0x0000, '[publicMainFuncTag]', JSON.stringify(data.result))

        let myData: httpForZhToEnType = JSON.parse(data.result.toString()) as httpForZhToEnType
        HTTPForZhToEn.myData = myData
        HTTPForZhToEn.myData_tran = myData.data[0].translations[0].text
        httpRequest.destroy();
      } else {
        hilog.error(0x0000, '[publicMainFuncTag]', JSON.stringify(err))
        console.error('error:' + JSON.stringify(err));
        httpRequest.off('headersReceive');
        httpRequest.destroy();
      }
    }
    );

  }
}

export interface httpForZhToEnType {
  code: string
  data: dataType[]
  msg: string
}

export interface dataType {
  detectedLanguage: detectedLanguage[]
  translations: translationsType[]
}

export interface detectedLanguage {
  language: string
  score: number
}

export interface translationsType {
  text: string
  to: string
}