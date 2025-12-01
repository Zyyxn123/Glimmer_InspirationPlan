import ClassifyAlphaListModel from '../Model/ClassifyAlphaListModel';
import RegionListModel from '../Model/RegionListModel';

interface LanguageItem {
  englishName: string;
  chineseName: string;
  code: string;
  supportAutoDetect: boolean;
  id: number; // 连续编号（1开始）
  superId: number; // 1~26 对应首字母A~Z
  superName: string; // 英文名称首字母（大写）
}

@ObservedV2
class ClassifyViewModel {
  @Trace languageList: LanguageItem[] = [
    {
      englishName: "Afrikaans",
      chineseName: "南非荷兰语",
      code: "af",
      supportAutoDetect: true,
      id: 1,
      superId: 1,
      superName: "A"
    },
    {
      englishName: "Albanian",
      chineseName: "阿尔巴尼亚语",
      code: "sq",
      supportAutoDetect: true,
      id: 2,
      superId: 1,
      superName: "A"
    },
    {
      englishName: "Amharic",
      chineseName: "阿姆哈拉语",
      code: "am",
      supportAutoDetect: false,
      id: 3,
      superId: 1,
      superName: "A"
    },
    {
      englishName: "Arabic",
      chineseName: "阿拉伯语",
      code: "ar",
      supportAutoDetect: true,
      id: 4,
      superId: 1,
      superName: "A"
    },
    {
      englishName: "Armenian",
      chineseName: "亚美尼亚语",
      code: "hy",
      supportAutoDetect: false,
      id: 5,
      superId: 1,
      superName: "A"
    },
    {
      englishName: "Azerbaijani",
      chineseName: "阿塞拜疆语",
      code: "az",
      supportAutoDetect: true,
      id: 6,
      superId: 1,
      superName: "A"
    },
    {
      englishName: "Belarusian",
      chineseName: "白俄罗斯语",
      code: "be",
      supportAutoDetect: true,
      id: 7,
      superId: 2,
      superName: "B"
    },
    {
      englishName: "Bangla",
      chineseName: "孟加拉语",
      code: "bn",
      supportAutoDetect: true,
      id: 8,
      superId: 2,
      superName: "B"
    },
    {
      englishName: "Bulgarian",
      chineseName: "保加利亚语",
      code: "bg",
      supportAutoDetect: true,
      id: 9,
      superId: 2,
      superName: "B"
    },
    {
      englishName: "Bosnian (Latin)",
      chineseName: "波斯尼亚语",
      code: "bs",
      supportAutoDetect: true,
      id: 10,
      superId: 2,
      superName: "B"
    },
    {
      englishName: "Catalan",
      chineseName: "加泰隆语",
      code: "ca",
      supportAutoDetect: true,
      id: 11,
      superId: 3,
      superName: "C"
    },
    {
      englishName: "Cantonese (Traditional)",
      chineseName: "粤语",
      code: "yue",
      supportAutoDetect: false,
      id: 12,
      superId: 3,
      superName: "C"
    },
    {
      englishName: "Cebuano",
      chineseName: "宿务语",
      code: "ceb",
      supportAutoDetect: false,
      id: 13,
      superId: 3,
      superName: "C"
    },
    {
      englishName: "Chinese",
      chineseName: "简体中文",
      code: "zh-CHS",
      supportAutoDetect: true,
      id: 14,
      superId: 3,
      superName: "C"
    },
    {
      englishName: "Chinese",
      chineseName: "繁体中文",
      code: "zh-CHT",
      supportAutoDetect: true,
      id: 15,
      superId: 3,
      superName: "C"
    },
    {
      englishName: "Corsican",
      chineseName: "科西嘉语",
      code: "co",
      supportAutoDetect: false,
      id: 16,
      superId: 3,
      superName: "C"
    },
    {
      englishName: "Czech",
      chineseName: "捷克语",
      code: "cs",
      supportAutoDetect: true,
      id: 17,
      superId: 3,
      superName: "C"
    },
    {
      englishName: "Danish",
      chineseName: "丹麦语",
      code: "da",
      supportAutoDetect: true,
      id: 18,
      superId: 4,
      superName: "D"
    },
    {
      englishName: "Dutch",
      chineseName: "荷兰语",
      code: "nl",
      supportAutoDetect: true,
      id: 19,
      superId: 4,
      superName: "D"
    },
    {
      englishName: "Dutch",
      chineseName: "荷兰语",
      code: "nl",
      supportAutoDetect: true,
      id: 20,
      superId: 4,
      superName: "D"
    },
    {
      englishName: "English",
      chineseName: "英语",
      code: "en",
      supportAutoDetect: true,
      id: 21,
      superId: 5,
      superName: "E"
    },
    {
      englishName: "Esperanto",
      chineseName: "世界语",
      code: "eo",
      supportAutoDetect: true,
      id: 22,
      superId: 5,
      superName: "E"
    },
    {
      englishName: "Estonian",
      chineseName: "爱沙尼亚语",
      code: "et",
      supportAutoDetect: true,
      id: 23,
      superId: 5,
      superName: "E"
    },
    {
      englishName: "Filipino",
      chineseName: "菲律宾语",
      code: "tl",
      supportAutoDetect: true,
      id: 24,
      superId: 6,
      superName: "F"
    },
    {
      englishName: "Finnish",
      chineseName: "芬兰语",
      code: "fi",
      supportAutoDetect: true,
      id: 25,
      superId: 6,
      superName: "F"
    },
    {
      englishName: "Fijian",
      chineseName: "斐济语",
      code: "fj",
      supportAutoDetect: false,
      id: 26,
      superId: 6,
      superName: "F"
    },
    {
      englishName: "French",
      chineseName: "法语",
      code: "fr",
      supportAutoDetect: true,
      id: 27,
      superId: 6,
      superName: "F"
    },
    {
      englishName: "Frisian",
      chineseName: "弗里西语",
      code: "fy",
      supportAutoDetect: true,
      id: 28,
      superId: 6,
      superName: "F"
    },
    {
      englishName: "Galician",
      chineseName: "加利西亚语",
      code: "gl",
      supportAutoDetect: true,
      id: 29,
      superId: 7,
      superName: "G"
    },
    {
      englishName: "Georgian",
      chineseName: "格鲁吉亚语",
      code: "ka",
      supportAutoDetect: false,
      id: 30,
      superId: 7,
      superName: "G"
    },
    {
      englishName: "German",
      chineseName: "德语",
      code: "de",
      supportAutoDetect: true,
      id: 31,
      superId: 7,
      superName: "G"
    },
    {
      englishName: "Greek",
      chineseName: "希腊语",
      code: "el",
      supportAutoDetect: true,
      id: 32,
      superId: 7,
      superName: "G"
    },
    {
      englishName: "Gujarati",
      chineseName: "古吉拉特语",
      code: "gu",
      supportAutoDetect: true,
      id: 33,
      superId: 7,
      superName: "G"
    },
    {
      englishName: "Haitian",
      chineseName: "海地克里奥尔语",
      code: "ht",
      supportAutoDetect: true,
      id: 34,
      superId: 8,
      superName: "H"
    },
    {
      englishName: "Hausa",
      chineseName: "豪萨语",
      code: "ha",
      supportAutoDetect: false,
      id: 35,
      superId: 8,
      superName: "H"
    },
    {
      englishName: "Hawaiian",
      chineseName: "夏威夷语",
      code: "haw",
      supportAutoDetect: false,
      id: 36,
      superId: 8,
      superName: "H"
    },
    {
      englishName: "Hebrew",
      chineseName: "希伯来语",
      code: "he",
      supportAutoDetect: true,
      id: 37,
      superId: 8,
      superName: "H"
    },
    {
      englishName: "Hindi",
      chineseName: "印地语",
      code: "hi",
      supportAutoDetect: true,
      id: 38,
      superId: 8,
      superName: "H"
    },
    {
      englishName: "Hindi",
      chineseName: "印地语",
      code: "hi",
      supportAutoDetect: true,
      id: 39,
      superId: 8,
      superName: "H"
    },
    {
      englishName: "Hmong",
      chineseName: "白苗语",
      code: "mww",
      supportAutoDetect: false,
      id: 40,
      superId: 8,
      superName: "H"
    },
    {
      englishName: "Hungarian",
      chineseName: "匈牙利语",
      code: "hu",
      supportAutoDetect: true,
      id: 41,
      superId: 8,
      superName: "H"
    },
    {
      englishName: "Icelandic",
      chineseName: "冰岛语",
      code: "is",
      supportAutoDetect: true,
      id: 42,
      superId: 9,
      superName: "I"
    },
    {
      englishName: "Igbo",
      chineseName: "伊博语",
      code: "ig",
      supportAutoDetect: false,
      id: 43,
      superId: 9,
      superName: "I"
    },
    {
      englishName: "Indonesian",
      chineseName: "印度尼西亚语",
      code: "id",
      supportAutoDetect: true,
      id: 44,
      superId: 9,
      superName: "I"
    },
    {
      englishName: "Irish",
      chineseName: "爱尔兰语",
      code: "ga",
      supportAutoDetect: true,
      id: 45,
      superId: 9,
      superName: "I"
    },
    {
      englishName: "Italian",
      chineseName: "意大利语",
      code: "it",
      supportAutoDetect: true,
      id: 46,
      superId: 9,
      superName: "I"
    },
    {
      englishName: "Japanese",
      chineseName: "日语",
      code: "ja",
      supportAutoDetect: true,
      id: 47,
      superId: 10,
      superName: "J"
    },
    {
      englishName: "Javanese",
      chineseName: "爪哇语",
      code: "jw",
      supportAutoDetect: false,
      id: 48,
      superId: 10,
      superName: "J"
    },
    {
      englishName: "Kannada",
      chineseName: "卡纳达语",
      code: "kn",
      supportAutoDetect: true,
      id: 49,
      superId: 11,
      superName: "K"
    },
    {
      englishName: "Kazakh",
      chineseName: "哈萨克语",
      code: "kk",
      supportAutoDetect: true,
      id: 50,
      superId: 11,
      superName: "K"
    },
    {
      englishName: "Khmer",
      chineseName: "高棉语",
      code: "km",
      supportAutoDetect: true,
      id: 51,
      superId: 11,
      superName: "K"
    },
    {
      englishName: "Klingon",
      chineseName: "克林贡语",
      code: "tlh",
      supportAutoDetect: false,
      id: 52,
      superId: 11,
      superName: "K"
    },
    {
      englishName: "Korean",
      chineseName: "韩语",
      code: "ko",
      supportAutoDetect: true,
      id: 53,
      superId: 11,
      superName: "K"
    },
    {
      englishName: "Kurdish",
      chineseName: "库尔德语",
      code: "ku",
      supportAutoDetect: false,
      id: 54,
      superId: 11,
      superName: "K"
    },
    {
      englishName: "Kyrgyz",
      chineseName: "柯尔克孜语",
      code: "ky",
      supportAutoDetect: true,
      id: 55,
      superId: 11,
      superName: "K"
    },
    {
      englishName: "Lao",
      chineseName: "老挝语",
      code: "lo",
      supportAutoDetect: true,
      id: 56,
      superId: 12,
      superName: "L"
    },
    {
      englishName: "Latin",
      chineseName: "拉丁语",
      code: "la",
      supportAutoDetect: true,
      id: 57,
      superId: 12,
      superName: "L"
    },
    {
      englishName: "Latvian",
      chineseName: "拉脱维亚语",
      code: "lv",
      supportAutoDetect: true,
      id: 58,
      superId: 12,
      superName: "L"
    },
    {
      englishName: "Lithuanian",
      chineseName: "立陶宛语",
      code: "lt",
      supportAutoDetect: true,
      id: 59,
      superId: 12,
      superName: "L"
    },
    {
      englishName: "Luxembourgish",
      chineseName: "卢森堡语",
      code: "lb",
      supportAutoDetect: true,
      id: 60,
      superId: 12,
      superName: "L"
    },
    {
      englishName: "Malagasy",
      chineseName: "马尔加什语",
      code: "mg",
      supportAutoDetect: false,
      id: 61,
      superId: 13,
      superName: "M"
    },
    {
      englishName: "Macedonian",
      chineseName: "马其顿语",
      code: "mk",
      supportAutoDetect: true,
      id: 62,
      superId: 13,
      superName: "M"
    },
    {
      englishName: "Malay",
      chineseName: "马来语",
      code: "ms",
      supportAutoDetect: true,
      id: 63,
      superId: 13,
      superName: "M"
    },
    {
      englishName: "Malayalam",
      chineseName: "马拉雅拉姆语",
      code: "ml",
      supportAutoDetect: true,
      id: 64,
      superId: 13,
      superName: "M"
    },
    {
      englishName: "Maltese",
      chineseName: "马耳他语",
      code: "mt",
      supportAutoDetect: true,
      id: 65,
      superId: 13,
      superName: "M"
    },
    {
      englishName: "Maori",
      chineseName: "毛利语",
      code: "mi",
      supportAutoDetect: false,
      id: 66,
      superId: 13,
      superName: "M"
    },
    {
      englishName: "Marathi",
      chineseName: "马拉地语",
      code: "mr",
      supportAutoDetect: true,
      id: 67,
      superId: 13,
      superName: "M"
    },
    {
      englishName: "Mongolian",
      chineseName: "蒙古语",
      code: "mn",
      supportAutoDetect: true,
      id: 68,
      superId: 13,
      superName: "M"
    },
    {
      englishName: "Myanmar (Burmese)",
      chineseName: "缅甸语",
      code: "my",
      supportAutoDetect: true,
      id: 69,
      superId: 13,
      superName: "M"
    },
    {
      englishName: "Nepali",
      chineseName: "尼泊尔语",
      code: "ne",
      supportAutoDetect: true,
      id: 70,
      superId: 14,
      superName: "N"
    },
    {
      englishName: "Norwegian",
      chineseName: "挪威语",
      code: "no",
      supportAutoDetect: true,
      id: 71,
      superId: 14,
      superName: "N"
    },
    {
      englishName: "Nyanja (Chichewa)",
      chineseName: "齐切瓦语",
      code: "ny",
      supportAutoDetect: false,
      id: 72,
      superId: 14,
      superName: "N"
    },
    {
      englishName: "Pashto",
      chineseName: "普什图语",
      code: "ps",
      supportAutoDetect: true,
      id: 73,
      superId: 16,
      superName: "P"
    },
    {
      englishName: "Persian",
      chineseName: "波斯语",
      code: "fa",
      supportAutoDetect: true,
      id: 74,
      superId: 16,
      superName: "P"
    },
    {
      englishName: "Polish",
      chineseName: "波兰语",
      code: "pl",
      supportAutoDetect: true,
      id: 75,
      superId: 16,
      superName: "P"
    },
    {
      englishName: "Portuguese",
      chineseName: "葡萄牙语",
      code: "pt",
      supportAutoDetect: true,
      id: 76,
      superId: 16,
      superName: "P"
    },
    {
      englishName: "Punjabi",
      chineseName: "旁遮普语",
      code: "pa",
      supportAutoDetect: true,
      id: 77,
      superId: 16,
      superName: "P"
    },
    {
      englishName: "Querétaro Otomi",
      chineseName: "克雷塔罗奥托米语",
      code: "otq",
      supportAutoDetect: false,
      id: 78,
      superId: 17,
      superName: "Q"
    },
    {
      englishName: "Romanian",
      chineseName: "罗马尼亚语",
      code: "ro",
      supportAutoDetect: true,
      id: 79,
      superId: 18,
      superName: "R"
    },
    {
      englishName: "Russian",
      chineseName: "俄语",
      code: "ru",
      supportAutoDetect: true,
      id: 80,
      superId: 18,
      superName: "R"
    },
    {
      englishName: "Samoan",
      chineseName: "萨摩亚语",
      code: "sm",
      supportAutoDetect: false,
      id: 81,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Sanskrit",
      chineseName: "梵语",
      code: "sa",
      supportAutoDetect: false,
      id: 82,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Scots",
      chineseName: "苏格兰盖尔语",
      code: "gd",
      supportAutoDetect: false,
      id: 83,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Serbian (Cyrillic)",
      chineseName: "塞尔维亚语(西里尔文)",
      code: "sr-Cyrl",
      supportAutoDetect: true,
      id: 84,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Serbian (Latin)",
      chineseName: "塞尔维亚语(拉丁文)",
      code: "sr-Latn",
      supportAutoDetect: true,
      id: 85,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Sesotho",
      chineseName: "塞索托语",
      code: "st",
      supportAutoDetect: false,
      id: 86,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Shona",
      chineseName: "修纳语",
      code: "sn",
      supportAutoDetect: false,
      id: 87,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Sindhi",
      chineseName: "信德语",
      code: "sd",
      supportAutoDetect: true,
      id: 88,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Sinhala (Sinhalese)",
      chineseName: "僧伽罗语",
      code: "si",
      supportAutoDetect: false,
      id: 89,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Slovak",
      chineseName: "斯洛伐克语",
      code: "sk",
      supportAutoDetect: true,
      id: 90,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Slovenian",
      chineseName: "斯洛文尼亚语",
      code: "sl",
      supportAutoDetect: true,
      id: 91,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Somali",
      chineseName: "索马里语",
      code: "so",
      supportAutoDetect: true,
      id: 92,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Spanish",
      chineseName: "西班牙语",
      code: "es",
      supportAutoDetect: true,
      id: 93,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Sundanese",
      chineseName: "巽他语",
      code: "su",
      supportAutoDetect: true,
      id: 94,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Swedish",
      chineseName: "瑞典语",
      code: "sv",
      supportAutoDetect: true,
      id: 95,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Swahili",
      chineseName: "斯瓦希里语",
      code: "sw",
      supportAutoDetect: true,
      id: 96,
      superId: 19,
      superName: "S"
    },
    {
      englishName: "Tajik",
      chineseName: "塔吉克语",
      code: "tg",
      supportAutoDetect: true,
      id: 97,
      superId: 20,
      superName: "T"
    },
    {
      englishName: "Tamil",
      chineseName: "泰米尔语",
      code: "ta",
      supportAutoDetect: true,
      id: 98,
      superId: 20,
      superName: "T"
    },
    {
      englishName: "Telugu",
      chineseName: "泰卢固语",
      code: "te",
      supportAutoDetect: true,
      id: 99,
      superId: 20,
      superName: "T"
    },
    {
      englishName: "Thai",
      chineseName: "泰语",
      code: "th",
      supportAutoDetect: true,
      id: 100,
      superId: 20,
      superName: "T"
    },
    {
      englishName: "Tahitian",
      chineseName: "塔希提语",
      code: "ty",
      supportAutoDetect: false,
      id: 101,
      superId: 20,
      superName: "T"
    },
    {
      englishName: "Tongan",
      chineseName: "汤加语",
      code: "to",
      supportAutoDetect: false,
      id: 102,
      superId: 20,
      superName: "T"
    },
    {
      englishName: "Turkish",
      chineseName: "土耳其语",
      code: "tr",
      supportAutoDetect: true,
      id: 103,
      superId: 20,
      superName: "T"
    },
    {
      englishName: "Ukrainian",
      chineseName: "乌克兰语",
      code: "uk",
      supportAutoDetect: true,
      id: 104,
      superId: 21,
      superName: "U"
    },
    {
      englishName: "Urdu",
      chineseName: "乌尔都语",
      code: "ur",
      supportAutoDetect: false,
      id: 105,
      superId: 21,
      superName: "U"
    },
    {
      englishName: "Uzbek",
      chineseName: "乌兹别克语",
      code: "uz",
      supportAutoDetect: true,
      id: 106,
      superId: 21,
      superName: "U"
    },
    {
      englishName: "Vietnamese",
      chineseName: "越南语",
      code: "vi",
      supportAutoDetect: true,
      id: 107,
      superId: 22,
      superName: "V"
    },
    {
      englishName: "Welsh",
      chineseName: "威尔士语",
      code: "cy",
      supportAutoDetect: true,
      id: 108,
      superId: 23,
      superName: "W"
    },
    {
      englishName: "Xhosa",
      chineseName: "南非科萨语",
      code: "xh",
      supportAutoDetect: false,
      id: 109,
      superId: 24,
      superName: "X"
    },
    {
      englishName: "Yiddish",
      chineseName: "意第绪语",
      code: "yi",
      supportAutoDetect: true,
      id: 110,
      superId: 25,
      superName: "Y"
    },
    {
      englishName: "Yoruba",
      chineseName: "约鲁巴语",
      code: "yo",
      supportAutoDetect: true,
      id: 111,
      superId: 25,
      superName: "Y"
    },
    {
      englishName: "Yucatec",
      chineseName: "尤卡坦玛雅语",
      code: "yua",
      supportAutoDetect: false,
      id: 112,
      superId: 25,
      superName: "Y"
    },
    {
      englishName: "Zulu",
      chineseName: "南非祖鲁语",
      code: "zu",
      supportAutoDetect: false,
      id: 113,
      superId: 26,
      superName: "Z"
    },
    {
      englishName: "auto",
      chineseName: "自动识别",
      code: "auto",
      supportAutoDetect: false,
      id: 114,
      superId: 1, // auto 首字母A对应1
      superName: "A"
    },
  ];

  getLinkData(): Array<ClassifyAlphaListModel> {
    let linkDataList: Array<ClassifyAlphaListModel> = [];
    let superId: number = 0;
    this.languageList.forEach((item: LanguageItem) => {
      if (superId !== item.superId) {
        // add the course classify model.
        let classifyItem: ClassifyAlphaListModel = new ClassifyAlphaListModel(item.superId, item.superName, []);
        linkDataList.push(classifyItem);
      }
      // add the course model.
      let courseItem: RegionListModel = new RegionListModel(superId, item.id, item.englishName, item.chineseName, item.code, item.supportAutoDetect);
      linkDataList[linkDataList.length-1].regionList.push(courseItem);
      superId = item.superId;
    });
    return linkDataList;
  }
}

let classifyViewModel = new ClassifyViewModel()

export default classifyViewModel as ClassifyViewModel