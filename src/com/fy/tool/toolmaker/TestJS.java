package com.fy.tool.toolmaker;

import com.fy.tool.toolmaker.util.PinyinUtil;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import java.util.Map;
import java.util.Set;

public class TestJS {
    // 使用js引擎来执行代码
    private String resolveFormulaValue(String s, Map<String, String> values) throws ScriptException {
        // 替换公式s中的变量a1,a2...
        Set<String> columnNames = values.keySet();
        int flag = 1;
        for (String columnName :
                columnNames) {
            // 获取字段值
            String columnValue = values.get(columnName);
            s = s.replaceAll("a"+flag, columnValue); // 首先替换所有的a1，然后是替换所有的a2，依次下去
            flag++;
        }
        ScriptEngineManager scriptEngineManager = new ScriptEngineManager();
        ScriptEngine js = scriptEngineManager.getEngineByName("js");
        Object eval = js.eval(s);
        System.out.println(eval);
        return String.valueOf(eval);
    }

    public static void main(String[] args) {
        test();
    }
    public static void test() {
        String pingYin = PinyinUtil.getPingYin("fuzhigongju嗨喽");
        System.out.println(pingYin);
        System.out.println(System.currentTimeMillis());
    }
}
