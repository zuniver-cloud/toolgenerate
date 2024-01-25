package com.fy.tool.toolmaker.util;

import net.sourceforge.pinyin4j.PinyinHelper;
import net.sourceforge.pinyin4j.format.HanyuPinyinCaseType;
import net.sourceforge.pinyin4j.format.HanyuPinyinOutputFormat;
import net.sourceforge.pinyin4j.format.HanyuPinyinToneType;
import net.sourceforge.pinyin4j.format.HanyuPinyinVCharType;
import net.sourceforge.pinyin4j.format.exception.BadHanyuPinyinOutputFormatCombination;
import org.apache.logging.log4j.util.Strings;

import java.util.Locale;
import java.util.Objects;

public class PinyinUtil {

    private final static HanyuPinyinOutputFormat format = new HanyuPinyinOutputFormat();

    static {
        format.setCaseType(HanyuPinyinCaseType.LOWERCASE);
        format.setToneType(HanyuPinyinToneType.WITHOUT_TONE);
        format.setVCharType(HanyuPinyinVCharType.WITH_V);
    }

    public static String removeSpecialChar(String con) {
        if (Strings.isEmpty(con)){
            return "";
        }

        StringBuilder sb = new StringBuilder();
        char[] temp = con.toCharArray();

        if (Character.isJavaIdentifierStart(temp[0])){
            sb.append(temp[0]);
        }else{
            return removeSpecialChar(con.substring(1));
        }

        for (int i = 1; i < temp.length; i++) {
            char c = temp[i];
            if (Character.isJavaIdentifierPart(c)){
                sb.append(c);
            }
        }

        return sb.toString();
    }
    /**
     * 将字符串中的中文转化为拼音, 英文字符不变
     */
    public static String getPingYin(String inputString) {
        StringBuilder output = new StringBuilder();

        if (Objects.isNull(inputString)) {
            return "*";
        }

        char[] input = inputString.trim().toCharArray();
        try {
            for (char c : input) {
                if (Character.toString(c).matches(
                        "[\\u4E00-\\u9FA5]+")) {
                    String[] temp = PinyinHelper.toHanyuPinyinStringArray(
                            c, format);
                    output.append(temp[0]);
                } else {
                    output.append(c);
                }
            }
        } catch (BadHanyuPinyinOutputFormatCombination e) {
            e.printStackTrace();
        }

        return output.toString();
    }

    /**
     * 用于数据库，文字拼音之间用下划线分隔。
     * 例如：字段1 => zi_duan_1
     * @param con
     * @return
     */
    public static String getDbPinYin(String con){
        StringBuilder output = new StringBuilder();

        if (Objects.isNull(con)) {
            return "*";
        }

        char[] input = con.trim().toCharArray();
        try {
            for (char c : input) {
                if (Character.toString(c).matches(
                        "[\\u4E00-\\u9FA5]+")) {
                    String[] temp = PinyinHelper.toHanyuPinyinStringArray(
                            c, format);
                    output.append(temp[0]);
                } else {
                    output.append(c);
                }

                output.append('_');
            }

            output.deleteCharAt(output.length() - 1);
        } catch (BadHanyuPinyinOutputFormatCombination e) {
            e.printStackTrace();
        }

        return output.toString();
    }

    /**
     * 获取代码使用的拼音，驼峰表示法。
     * 例如：字段 => ziDuan 或 ZiDuan
     *
     * @param con
     * @return
     */
    public static String getCodePinPin(String con){
        StringBuilder output = new StringBuilder();

        if (Objects.isNull(con)) {
            return "*";
        }

        char[] input = con.trim().toCharArray();
        try {
            for (char c : input) {
                if (Character.toString(c).matches("[\\u4E00-\\u9FA5]+")) {
                    String[] temp = PinyinHelper.toHanyuPinyinStringArray(c, format);

                    char[] cs = temp[0].toCharArray();
                    cs[0] = Character.toUpperCase(cs[0]);

                    output.append(cs);
                } else {
                    output.append(c);
                }
            }

        } catch (BadHanyuPinyinOutputFormatCombination e) {
            e.printStackTrace();
        }

        return output.toString();
    }

    public static void main(String[] args) {
        System.out.println(removeSpecialChar("245645OE456M(外购成品)"));
    }
}
