import { http } from '@kit.NetworkKit'
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

const POETRY_URL: string = 'https://v2.xxapi.cn/api/randomenglishwords'

@ObservedV2
export class HTTPForDailyEnglishWord {
  @Trace DEW: HTTPForDailyEnglishWordType | undefined = undefined

  httpRequestForDailyEnglishWord() {
    let httpRequest = http.createHttp()
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header))
    });
    httpRequest.request(
      POETRY_URL,
      {
        method: http.RequestMethod.GET,
        // 开发者根据自身业务需要添加header字段。
        header: {
          'Content-Type': 'application/json'
        },
      }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析。
        console.info('Resultsss:' + JSON.stringify(data.result))
        let res: HTTPForDailyEnglishWordType = JSON.parse(data.result.toString()) as HTTPForDailyEnglishWordType
        this.DEW = res
        httpRequest.destroy()
      } else {
        console.error('error:' + JSON.stringify(err))
        httpRequest.off('headersReceive')
        httpRequest.destroy()
      }
    })
  }
}


export interface HTTPForDailyEnglishWordType {
  code: number
  data: dataType
  msg: string
}

interface dataType {
  bookId: string
  phrases: phrasesType[]
  relWords: relWordsType[]
  sentences: sentencesType[]
  synonyms: synonymsType[]
  translations: translationsType[]
  ukphone: string
  ukspeech: string
  usphone: string
  usspeech: string
  word: string
}

export interface translationsType {
  pos: string
  tran_cn: string
}

export interface synonymsType {
  Hwds: HwdsTypeAnother[]
  pos: string
  tran: string
}

export interface HwdsTypeAnother {
  word: string
}

export interface sentencesType {
  s_cn: string
  s_content: string
}

export interface phrasesType {
  p_cn: string
  p_content: string
}

export interface relWordsType {
  Hwds: HwdsType[]
  Pos: string
}

export interface HwdsType {
  hwd: string
  tran: string
}