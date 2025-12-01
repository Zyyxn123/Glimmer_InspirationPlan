import { http } from '@kit.NetworkKit'
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const YOUDAO_URL = 'https://openapi.youdao.com/api'

@ObservedV2
export class SpeechToSpeech {
  static salt: string = SpeechToSpeech.generateSalt()
  static sign: string = ''
  static curtime: string = ''
  @Trace static transation: string[] = []

  static generateSalt(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = Math.random() * 16 | 0;
      const v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  static getSign(text1: string): void {
    let input: string = ''
    if (text1.length <= 20) {
      input = text1
    } else {
      input = text1.slice(0, 10) + text1.length + text1.slice(-10)
    }
    SpeechToSpeech.salt = SpeechToSpeech.generateSalt()
    SpeechToSpeech.curtime = Math.floor(Date.now() / 1000).toString()
    console.log(`当前的时间戳信息${SpeechToSpeech.curtime}`)
    const sign1 =
      '279ce263ceeb4d2f' + input + SpeechToSpeech.salt + SpeechToSpeech.curtime + '8tujJX5JDigTJYkCgMpCpiItdfgVkoR1'

    const md = cryptoFramework.createMd('SHA256');
    const data = new Uint8Array(buffer.from(sign1, 'utf-8').buffer);
    md.updateSync({ data });
    const digestResult = md.digestSync();
    SpeechToSpeech.sign = buffer.from(digestResult.data).toString('hex');
  }

  static stringToArrayBuffer(str: string): ArrayBuffer {
    const buf = new ArrayBuffer(str.length);
    const bufView = new Uint8Array(buf);
    for (let i = 0; i < str.length; i++) {
      bufView[i] = str.charCodeAt(i);
    }
    return buf;
  }

  static textToSpeech(text1: string): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      SpeechToSpeech.getSign(text1)
      let httpRequest = http.createHttp()
      httpRequest.request(
        YOUDAO_URL,
        { // zh-CHS
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          expectDataType: http.HttpDataType.STRING,
          extraData:
          'q=' + encodeURIComponent(text1) +
            '&from=auto' +
            '&to=en' +
            '&appKey=279ce263ceeb4d2f' +
            '&salt=' + SpeechToSpeech.salt +
            '&sign=' + SpeechToSpeech.sign +
            '&signType=v3' +
            '&curtime=' + SpeechToSpeech.curtime

        }
      )
        .then(res => {
          if (res.responseCode === 200) {
            hilog.info(0x0000, '[publicHTTPPOST]', JSON.stringify(res.result))
            try {
              let aaa: msg = JSON.parse(res.result.toString()) as msg
              // hilog.info(0x0000, '[publicHTTPPOST]aaa', 'a' + JSON.stringify(aaa))
              hilog.info(0x0000, '[publicHTTPPOST]aaa', 'a' + JSON.parse(res.result.toString()))
              hilog.info(0x0000, '[publicHTTPPOST]aaa', 'ab' + JSON.stringify(aaa.query))
              hilog.info(0x0000, '[publicHTTPPOST]aaa', 'abc' + JSON.stringify(aaa.translation[0]))
              hilog.info(0x0000, '[publicHTTPPOST]aaa', 'abc' + JSON.stringify(aaa.translation))
              // hilog.info(0x0000, '[publicHTTPPOST]aaa', 'awdbyhuawjd')
              SpeechToSpeech.transation = aaa.translation
              return aaa.translation[0]
            } catch (err) {
              hilog.info(0x0000, '[publicHTTPPOST]aaa', 'ab ' + JSON.stringify(err))
              return
            }
          } else {
            reject();
            return
          }
        })
        .catch((err: Error) => {
          reject(`请求失败: ${err.message}`);
        });
    })
  }
}

interface msg {
  query: string
  // isDomainSupport: boolean
  errorCode: string
  // l: string
  tSpeakUrl: string
  requestId: string
  translation: string[]
  // mTerminalDict: string
  dict: string
  // yddict: string
  webdict: string
  // speakUrl: string
  // isWord: boolean
}

// static containsSurrogatePairs(str: string): boolean {
//   for (let i = 0; i < str.length; i++) {
//     const code = str.charCodeAt(i);
//     if (code >= 0xD800 && code <= 0xDFFF) {
//       return true;
//     }
//   }
//   return false;
// }