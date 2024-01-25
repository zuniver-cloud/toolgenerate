package com.fy.tool.toolmaker.core;

import com.fy.tool.toolmaker.vo.Classify;
import com.fy.tool.toolmaker.vo.ExcelTable;
import com.fy.tool.toolmaker.vo.SearchList;
import lombok.Data;

import java.util.List;

/**
 * 工具配置类
 */
@Data
public class ToolConfiguration {

    List<String> searchFields;

    /**
     * 工具名称
     */
    String toolName;

    /**
     * 工具名称拼音
     */
    String pinyinOfToolName;
    /**
     * 工具描述
     */
    String toolDescription;

    /**
     * 公司信息
     */
    String company;

    /**
     * 工具包名
     */
    String packageName;
    /**
     * 工具主类名
     */
    String className;

    /**
     * 工具对应的表
     */
    DbTable table;

    List<DbTable> tables;

    List<ExcelTable> excelTables;

    //改动
    /**
     * 分类和搜索的列表
     */
    List<Classify> classifyList;

    List<SearchList> searchList;

    //改动2
    /**
     * 分类对应的数据库字段
     */
    String classifyKey;

    /**
     * 调用工具
     */
    String  toolControlId;
    Boolean  hasToolControl;
    String  toolControlDes;

    /**
     * 非视图工具
     */
    Boolean nViewTool;

    /**
     * 导入功能
     */
    Boolean hasImport;

    /**
     * 导出功能
     */
    Boolean  hasExport;

    /**
     * 添加记录
     */
    Boolean hasAdd;

    /**
     * 删除功能
     */
    Boolean hasDeleteControl;

    /**
     * 修改功能
     */
    Boolean hasUpdateControl;

    /**
     * 查看功能
     */
    Boolean hasViewControl;

    /**
     * 是否来自数据库
     */
    Boolean isFromDatabase;

    /**
     * 连接条件
     */
    String connectCondition;
}
