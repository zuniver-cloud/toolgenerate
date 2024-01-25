package com.fy.tool.toolmaker.core;

import lombok.Data;

import java.util.List;
import java.util.Map;

/**
 * 数据库表类
 */
@Data
public class DbTable {

    /**
     * 表名
     */
    String name;

    String pinyinOfEntityName;

    String nameChinese;
    /**
     * 字段
     */
    List<DbColumn> columns;

    /**
     * 数据
     */
    List<Map<String, String>> data;
}
