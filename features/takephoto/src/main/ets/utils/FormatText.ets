/**
 * 格式化文本空格：
 * - 英文：保留单词之间的一个空格，去除多余空格
 * - 中文：去除所有词语之间的空格
 * @param text 输入文本
 * @returns 格式化后的文本
 */
function formatTextSpacing(text: string): string {
  if (!text || text.trim().length === 0) {
    return text;
  }

  // 判断文本是否主要为中文
  const isMainlyChinese = isChineseText(text);

  if (isMainlyChinese) {
    return formatChineseText(text);
  } else {
    return formatEnglishText(text);
  }
}

/**
 * 判断文本是否主要为中文
 * @param text 输入文本
 * @returns 是否为中文文本
 */
function isChineseText(text: string): boolean {
  const chineseCharCount = (text.match(/[\u4e00-\u9fa5]/g) || []).length;
  const englishCharCount = (text.match(/[a-zA-Z]/g) || []).length;

  // 如果中文字符多于英文字符，则认为是中文文本
  return chineseCharCount > englishCharCount;
}

/**
 * 格式化中文文本：去除所有词语之间的空格
 * @param text 中文文本
 * @returns 格式化后的中文文本
 */
function formatChineseText(text: string): string {
  // 去除所有空格
  let result = text.replace(/\s+/g, '');

  // 但保留英文单词之间的一个空格
  result = result.replace(/([a-zA-Z])([\u4e00-\u9fa5])/g, '$1 $2');
  result = result.replace(/([\u4e00-\u9fa5])([a-zA-Z])/g, '$1 $2');

  // 处理标点符号后的空格
  result = result.replace(/([，。！？；：、])\s+/g, '$1');
  result = result.replace(/\s+([，。！？；：、])/g, '$1');

  return result.trim();
}

/**
 * 格式化英文文本：保留单词之间一个空格，去除多余空格
 * @param text 英文文本
 * @returns 格式化后的英文文本
 */
function formatEnglishText(text: string): string {
  // 用正则表达式分割单词（包括中文字符）
  const words = text.match(/([\u4e00-\u9fa5]+|[a-zA-Z]+|[0-9]+|[^\s]+)/g) || [];

  const resultWords: string[] = [];

  for (let i = 0; i < words.length; i++) {
    const currentWord = words[i];
    const nextWord = words[i + 1];

    // 如果是中文，直接添加
    if (/^[\u4e00-\u9fa5]+$/.test(currentWord)) {
      resultWords.push(currentWord);
    }
    // 如果是英文或数字
    else if (/^[a-zA-Z0-9]+$/.test(currentWord)) {
      resultWords.push(currentWord);

      // 如果下一个词存在且也是英文或数字，添加一个空格
      if (nextWord && /^[a-zA-Z0-9]+$/.test(nextWord)) {
        resultWords.push(' ');
      }
    }
    // 其他字符（标点符号等）
    else {
      resultWords.push(currentWord);

      // 如果下一个词是英文，添加一个空格
      if (nextWord && /^[a-zA-Z0-9]+$/.test(nextWord)) {
        resultWords.push(' ');
      }
    }
  }

  return resultWords.join('').replace(/\s+/g, ' ').trim();
}

/**
 * 更简单的实现版本（推荐使用）
 * @param text 输入文本
 * @returns 格式化后的文本
 */
export function smartFormatSpacing(text: string): string {
  if (!text) return text;

  // 1. 首先标准化空格：将多个空格替换为单个空格
  let result = text.replace(/\s+/g, ' ');

  // 2. 处理中英混合的情况
  // 中文字符后跟英文字母：添加空格
  result = result.replace(/([\u4e00-\u9fa5])([a-zA-Z])/g, '$1 $2');
  // 英文字母后跟中文字符：添加空格
  result = result.replace(/([a-zA-Z])([\u4e00-\u9fa5])/g, '$1 $2');

  // 3. 纯中文部分：去除所有空格
  // 将连续的中文字符之间的空格去掉
  result = result.replace(/([\u4e00-\u9fa5])\s+([\u4e00-\u9fa5])/g, '$1$2');

  // 4. 英文部分：确保单词之间只有一个空格
  // 匹配英文单词（可能包含数字和连字符）
  const englishWords = result.match(/\b[a-zA-Z0-9'-]+\b/g) || [];
  for (const word of englishWords) {
    // 确保单词前后有空格（如果不在开头/结尾）
    const regex = new RegExp(`(^|\\s)${word}(\\s|$)`, 'g');
    result = result.replace(regex, ` ${word} `);
  }

  // 5. 再次标准化空格并修剪
  result = result.replace(/\s+/g, ' ').trim();

  // 6. 处理标点符号
  // 中文标点后不要有空格
  const chinesePunctuation = /[，。！？；：、]/g;
  result = result.replace(/\s+([，。！？；：、])/g, '$1');
  result = result.replace(/([，。！？；：、])\s+/g, '$1');

  // 英文标点后通常有一个空格
  const englishPunctuation = /[,\.!?;:]/g;
  result = result.replace(/([,\.!?;:])\s*/g, '$1 ');
  result = result.replace(/\s+([,\.!?;:])/g, '$1');

  return result.replace(/\s+/g, ' ').trim();
}

// 使用示例：
const testCases = [
  "Hello   World   !",  // 英文：多余空格
  "你好   世界   ！",    // 中文：多余空格
  "Hello 世界  World",  // 中英混合
  "  前后 有 空格 色粉 ",   // 前后空格
  "This is a test. 这是一个测试。",  // 中英文句子
  "apple  苹果  banana  香蕉",  // 中英单词交替
  "2024年 1月 1日",     // 中文日期
  "AI  人工智能  技术",  // 中英混合
];

console.log("测试结果:");
testCases.forEach((text, index) => {
  console.log(`原文本 ${index + 1}: "${text}"`);
  console.log(`格式化后: "${smartFormatSpacing(text)}"`);
  console.log("---");
});

// 也可以使用类的方式封装
class TextFormatter {
  /**
   * 智能格式化文本间距
   */
  static format(text: string): string {
    return smartFormatSpacing(text);
  }

  /**
   * 判断文本是否为中文为主
   */
  static isChinese(text: string): boolean {
    const chineseCount = (text.match(/[\u4e00-\u9fa5]/g) || []).length;
    const englishCount = (text.match(/[a-zA-Z]/g) || []).length;
    return chineseCount > englishCount;
  }

  /**
   * 仅格式化英文文本（保留单词间一个空格）
   */
  static formatEnglish(text: string): string {
    return text.replace(/\s+/g, ' ').trim();
  }

  /**
   * 仅格式化中文文本（去除所有空格）
   */
  static formatChinese(text: string): string {
    // 保留中英之间的空格
    let result = text.replace(/([\u4e00-\u9fa5])\s+([\u4e00-\u9fa5])/g, '$1$2');
    result = result.replace(/\s+/g, ' ').trim();
    return result;
  }
}

// 使用示例
const sampleText = "Hello   世界  饿啊是否  阿瓦达 World   ！";
console.log("使用TextFormatter:");
console.log(`原文本: "${sampleText}"`);
console.log(`智能格式化: "${TextFormatter.format(sampleText)}"`);
console.log(`是否为中文为主: ${TextFormatter.isChinese(sampleText)}`);