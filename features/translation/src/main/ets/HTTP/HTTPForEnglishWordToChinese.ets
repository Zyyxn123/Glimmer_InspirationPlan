import { http } from '@kit.NetworkKit'
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

const POETRY_URL: string = 'https://v2.xxapi.cn/api/englishwords'

@ObservedV2
export class HTTPForEnglishWordToChinese {
  @Trace static  myData: HTTPForEnglishWordToChineseType | undefined = undefined

  static HTTPForEnglishWordToChinese(word: string) {
    hilog.info(0x0000, '[publicTranslationTag]', 'aaa:' + word)
    let httpRequest = http.createHttp();
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });
    httpRequest.request(
      POETRY_URL + `?word=${word}`,
      {
        method: http.RequestMethod.GET,
        // 开发者根据自身业务需要添加header字段。
        header: {
          'Content-Type': 'application/json'
        },
      }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析。
        // hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(data.result))
        let tran: HTTPForEnglishWordToChineseType = JSON.parse(data.result.toString()) as HTTPForEnglishWordToChineseType
        HTTPForEnglishWordToChinese.myData = tran

        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran))
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.code))
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.msg))
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.data.word))
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.data.ukphone)) // 英音音标
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.data.usphone)) // 美音音标
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.data.translations)) // 翻译
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.data.synonyms)) // 近义词
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.data.sentences)) // 例句
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.data.phrases)) // 短语
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.data.relWords)) // 同根词
        hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(tran.data.ukspeech))

        httpRequest.destroy();
      } else {
        console.error('error:' + JSON.stringify(err));
        httpRequest.off('headersReceive');
        httpRequest.destroy();
      }
    }
    );
  }
}

export interface HTTPForEnglishWordToChineseType {
  code: string
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