package com.fy.tool.toolmaker.core;

import lombok.Data;

/**
 * 数据库字段类
 */
@Data
public class DbColumn {
    /**
     * 字段名称
     **/
    private String name;

    /**
     * 字段类型
     **/
    private String type;

    /**
     * 字段注释
     **/
    private String comment;

    /**
     * 保存公式名称
     */
    private String formulaName;

    /**
     * 字段名 下划线->小骆驼峰
     **/
    private String changedName;

    /**
     * 在表格中显示的名字
     */
    private String showName;

    /**
     * 字段来自哪个表
     */
    private String parentTable;
}
